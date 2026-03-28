"""gRPC server interceptors for cross-cutting concerns."""

from __future__ import annotations

import contextvars
from collections.abc import Callable
from typing import Any

import grpc
import structlog

logger = structlog.get_logger(__name__)

# Context variable for the current trace id
trace_id_var: contextvars.ContextVar[str | None] = contextvars.ContextVar(
    "trace_id", default=None
)


class TraceIdInterceptor(grpc.aio.ServerInterceptor):
    """Extract trace_id from gRPC metadata and set it in the context variable."""

    async def intercept_service(
        self,
        continuation: Callable,
        handler_call_details: grpc.HandlerCallDetails,
    ) -> Any:
        # Extract trace_id from invocation metadata
        metadata = dict(handler_call_details.invocation_metadata or [])
        incoming_trace_id = metadata.get("trace-id") or metadata.get("x-trace-id")

        if incoming_trace_id:
            trace_id_var.set(incoming_trace_id)
            logger.debug("trace_id_extracted", trace_id=incoming_trace_id)

        return await continuation(handler_call_details)
