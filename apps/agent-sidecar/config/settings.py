"""Application settings loaded from environment variables with SIDECAR_ prefix."""

from __future__ import annotations

from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Configuration for the agent-sidecar service."""

    model_config = {"env_prefix": "SIDECAR_"}

    # Database
    database_url: str = Field(
        default="postgresql://localhost:5432/altrupets",
        description="PostgreSQL connection URL",
    )

    # FalkorDB
    falkordb_host: str = Field(default="localhost", description="FalkorDB hostname")
    falkordb_port: int = Field(default=6379, description="FalkorDB port")

    # gRPC
    grpc_port: int = Field(default=50051, description="gRPC server listen port")

    # Observability
    metrics_port: int = Field(default=9090, description="Prometheus metrics port")
    health_port: int = Field(default=8080, description="Health check HTTP port")

    # Matching
    max_candidates: int = Field(default=5, description="Max candidates to return")

    # Radius overrides per urgency (km)
    radius_low: float = Field(default=15.0, description="Search radius for LOW urgency")
    radius_medium: float = Field(default=25.0, description="Search radius for MEDIUM urgency")
    radius_high: float = Field(default=50.0, description="Search radius for HIGH urgency")
    radius_critical: float = Field(default=100.0, description="Search radius for CRITICAL urgency")


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return a cached singleton of the application settings."""
    return Settings()
