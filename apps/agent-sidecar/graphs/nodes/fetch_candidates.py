"""Fetch rescuer candidates from PostgreSQL within a radius determined by urgency."""

from __future__ import annotations

import math

import asyncpg
import structlog

from config.settings import get_settings
from graphs.state import CandidateData, MatchingState

logger = structlog.get_logger(__name__)

# Radius in km per urgency level
URGENCY_RADIUS: dict[str, float] = {
    "LOW": 15.0,
    "MEDIUM": 25.0,
    "HIGH": 50.0,
    "CRITICAL": 100.0,
}

# Earth radius in km for Haversine
_EARTH_RADIUS_KM = 6371.0


def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Return distance in km between two lat/lng points using the Haversine formula."""
    rlat1, rlon1, rlat2, rlon2 = (
        math.radians(lat1),
        math.radians(lon1),
        math.radians(lat2),
        math.radians(lon2),
    )
    dlat = rlat2 - rlat1
    dlon = rlon2 - rlon1
    a = math.sin(dlat / 2) ** 2 + math.cos(rlat1) * math.cos(rlat2) * math.sin(dlon / 2) ** 2
    return 2 * _EARTH_RADIUS_KM * math.asin(math.sqrt(a))


async def fetch_candidates(state: MatchingState) -> MatchingState:
    """Query PostgreSQL for users with RESCUER or HELPER role within the urgency-based radius.

    Filters:
    - Active users only
    - Role is RESCUER or HELPER
    - Not currently assigned to an active (non-completed) rescue
    - Within Haversine distance of the alert coordinates
    """
    settings = get_settings()
    animal = state["animal_info"]
    max_radius = URGENCY_RADIUS.get(animal.urgency, 25.0)

    logger.info(
        "fetching_candidates",
        rescue_alert_id=animal.rescue_alert_id,
        urgency=animal.urgency,
        max_radius_km=max_radius,
    )

    try:
        conn: asyncpg.Connection = await asyncpg.connect(settings.database_url)
    except Exception:
        logger.exception("database_connection_failed")
        return {**state, "candidates": [], "total_evaluated": 0, "error": "database_connection_failed"}

    try:
        # Fetch active users with RESCUER or HELPER roles who are not on an active rescue.
        # AltruPets schema: roles is a postgres array column on users table,
        # rescue_alerts tracks active rescues (auxiliarId/rescuerId columns).
        query = """
            SELECT
                u.id,
                COALESCE(u."firstName", u.username) AS name,
                u.latitude,
                u.longitude,
                u.roles
            FROM users u
            WHERE u."isActive" = true
              AND (u.roles && ARRAY['RESCUER', 'HELPER']::varchar[])
              AND u.latitude IS NOT NULL
              AND u.longitude IS NOT NULL
              AND u.id NOT IN (
                  SELECT COALESCE(ra."auxiliarId", ra."rescuerId")
                  FROM rescue_alerts ra
                  WHERE ra.status NOT IN ('COMPLETED', 'CANCELLED', 'REJECTED', 'EXPIRED')
                    AND (ra."auxiliarId" IS NOT NULL OR ra."rescuerId" IS NOT NULL)
              )
        """
        rows = await conn.fetch(query)

        candidates: list[CandidateData] = []
        for row in rows:
            dist = _haversine(animal.latitude, animal.longitude, float(row["latitude"]), float(row["longitude"]))
            if dist <= max_radius:
                candidates.append(
                    CandidateData(
                        user_id=str(row["id"]),
                        name=row["name"] or "Unknown",
                        distance_km=round(dist, 2),
                        available_capacity=0,  # enriched later from casa_cuna data
                        roles=list(row["roles"]) if row["roles"] else [],
                    )
                )

        logger.info("candidates_fetched", count=len(candidates), total_rows=len(rows))
        return {**state, "candidates": candidates, "total_evaluated": len(candidates)}

    except Exception:
        logger.exception("fetch_candidates_query_failed")
        return {**state, "candidates": [], "total_evaluated": 0, "error": "fetch_candidates_query_failed"}
    finally:
        await conn.close()
