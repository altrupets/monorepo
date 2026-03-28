"""Entry point for the altrupets agent-sidecar service.

Starts the gRPC server, Prometheus metrics endpoint, and health check HTTP server.
"""

from __future__ import annotations

import asyncio
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading

import structlog

from config.settings import get_settings

logger = structlog.get_logger(__name__)


def _start_metrics_server(port: int) -> None:
    """Start the Prometheus metrics HTTP server on a background thread."""
    try:
        from prometheus_client import start_http_server

        start_http_server(port)
        logger.info("metrics_server_started", port=port)
    except Exception:
        logger.exception("metrics_server_failed")


class _HealthHandler(BaseHTTPRequestHandler):
    """Minimal HTTP handler for liveness/readiness probes."""

    def do_GET(self):  # noqa: N802
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status":"ok"}')

    def log_message(self, format, *args):  # noqa: A002
        # Suppress default HTTP logging; we use structlog
        pass


def _start_health_server(port: int) -> None:
    """Start a basic HTTP health server on a background thread."""
    server = HTTPServer(("0.0.0.0", port), _HealthHandler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    logger.info("health_server_started", port=port)


async def main() -> None:
    """Initialize services and run the gRPC server."""
    settings = get_settings()

    logger.info(
        "sidecar_starting",
        grpc_port=settings.grpc_port,
        metrics_port=settings.metrics_port,
        health_port=settings.health_port,
    )

    # Start Prometheus metrics endpoint
    _start_metrics_server(settings.metrics_port)

    # Start health check endpoint
    _start_health_server(settings.health_port)

    # Start the gRPC server (blocks until shutdown signal)
    from grpc.server import serve

    await serve()


if __name__ == "__main__":
    asyncio.run(main())
