"""Handler for the FindBestRescuers RPC."""

from __future__ import annotations

import time

import structlog

from graphs.rescuer_matching_graph import matching_graph
from graphs.state import AnimalInfo, MatchingState

logger = structlog.get_logger(__name__)


async def handle_find_rescuers(
    rescue_alert_id: str,
    latitude: float,
    longitude: float,
    urgency: str,
    animal_type: str,
    max_candidates: int,
    trace_id: str,
) -> dict:
    """Run the matching graph and return results as a plain dict.

    Returns a dict with keys: candidates, total_evaluated, duration_ms, trace_id.
    """
    start = time.perf_counter()

    animal_info = AnimalInfo(
        rescue_alert_id=rescue_alert_id,
        latitude=latitude,
        longitude=longitude,
        urgency=urgency,
        animal_type=animal_type or None,
    )

    initial_state: MatchingState = {
        "animal_info": animal_info,
        "candidates": [],
        "top_candidates": [],
        "total_evaluated": 0,
        "error": None,
    }

    logger.info(
        "find_rescuers_start",
        rescue_alert_id=rescue_alert_id,
        urgency=urgency,
        trace_id=trace_id,
    )

    result = await matching_graph.ainvoke(initial_state)

    duration_ms = (time.perf_counter() - start) * 1000

    top = result.get("top_candidates", [])

    candidates_out = []
    for c in top[:max_candidates] if max_candidates > 0 else top:
        candidates_out.append(
            {
                "user_id": c.user_id,
                "name": c.name,
                "distance_km": c.distance_km,
                "available_capacity": c.available_capacity,
                "score": c.score,
                "explanation": c.explanation,
                "score_breakdown": c.score_breakdown,
            }
        )

    logger.info(
        "find_rescuers_complete",
        rescue_alert_id=rescue_alert_id,
        candidates_returned=len(candidates_out),
        duration_ms=round(duration_ms, 2),
        trace_id=trace_id,
    )

    return {
        "candidates": candidates_out,
        "total_evaluated": result.get("total_evaluated", 0),
        "duration_ms": round(duration_ms, 2),
        "trace_id": trace_id,
    }
