"""gRPC server implementing the MatchingService."""

from __future__ import annotations

import asyncio
import signal
from concurrent import futures

import grpc
import structlog

from config.settings import get_settings
from grpc.handlers.find_rescuers import handle_find_rescuers
from grpc.handlers.record_outcome import handle_record_outcome
from grpc.interceptors import TraceIdInterceptor

logger = structlog.get_logger(__name__)


class MatchingServiceServicer:
    """Implements MatchingService RPCs.

    Note: This servicer operates against the handler functions directly,
    returning plain dicts. When generated proto stubs are available,
    responses should be constructed from the proto message classes.
    """

    async def FindBestRescuers(self, request, context):  # noqa: N802
        """Find the best rescuer candidates for a rescue alert."""
        result = await handle_find_rescuers(
            rescue_alert_id=request.rescue_alert_id,
            latitude=request.latitude,
            longitude=request.longitude,
            urgency=request.urgency,
            animal_type=request.animal_type,
            max_candidates=request.max_candidates,
            trace_id=request.trace_id,
        )
        return result

    async def RecordRescueOutcome(self, request, context):  # noqa: N802
        """Record the outcome of a rescue operation."""
        result = await handle_record_outcome(
            rescue_alert_id=request.rescue_alert_id,
            rescuer_id=request.rescuer_id,
            animal_id=request.animal_id,
            successful=request.successful,
            vet_id=request.vet_id,
            trace_id=request.trace_id,
        )
        return result

    async def HealthCheck(self, request, context):  # noqa: N802
        """Return health status and dependency connectivity."""
        settings = get_settings()
        dependencies: dict[str, str] = {}

        # Check PostgreSQL
        try:
            import asyncpg

            conn = await asyncpg.connect(settings.database_url)
            await conn.fetchval("SELECT 1")
            await conn.close()
            dependencies["postgresql"] = "OK"
        except Exception:
            dependencies["postgresql"] = "UNAVAILABLE"

        # Check FalkorDB
        try:
            from falkordb import FalkorDB

            db = FalkorDB(host=settings.falkordb_host, port=settings.falkordb_port)
            db.select_graph("altrupets")
            dependencies["falkordb"] = "OK"
        except Exception:
            dependencies["falkordb"] = "UNAVAILABLE"

        all_ok = all(v == "OK" for v in dependencies.values())
        status = "SERVING" if all_ok else "NOT_SERVING"

        return {"status": status, "dependencies": dependencies}


async def serve() -> None:
    """Start the gRPC server with interceptors and graceful shutdown."""
    settings = get_settings()

    server = grpc.aio.server(
        futures.ThreadPoolExecutor(max_workers=10),
        interceptors=[TraceIdInterceptor()],
    )

    # Register the servicer.
    # When generated stubs are available, use:
    #   matching_pb2_grpc.add_MatchingServiceServicer_to_server(
    #       MatchingServiceServicer(), server
    #   )
    # For now, we hold a reference for testing.
    servicer = MatchingServiceServicer()
    _ = servicer  # Will be registered once proto stubs are generated

    listen_addr = f"[::]:{settings.grpc_port}"
    server.add_insecure_port(listen_addr)

    logger.info("grpc_server_starting", address=listen_addr)
    await server.start()
    logger.info("grpc_server_started", address=listen_addr)

    # Graceful shutdown on SIGTERM / SIGINT
    loop = asyncio.get_running_loop()
    shutdown_event = asyncio.Event()

    def _signal_handler():
        logger.info("shutdown_signal_received")
        shutdown_event.set()

    for sig in (signal.SIGTERM, signal.SIGINT):
        loop.add_signal_handler(sig, _signal_handler)

    await shutdown_event.wait()

    logger.info("grpc_server_shutting_down")
    await server.stop(grace=5)
    logger.info("grpc_server_stopped")
