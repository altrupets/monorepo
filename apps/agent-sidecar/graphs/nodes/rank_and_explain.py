"""Rank scored candidates and generate human-readable explanations."""

from __future__ import annotations

import structlog

from config.settings import get_settings
from graphs.state import MatchingState

logger = structlog.get_logger(__name__)


async def rank_and_explain(state: MatchingState) -> MatchingState:
    """Sort candidates by score descending, take top N, and generate explanations."""
    settings = get_settings()
    max_candidates = settings.max_candidates

    sorted_candidates = sorted(state["candidates"], key=lambda c: c.score, reverse=True)
    top = sorted_candidates[:max_candidates]

    explained = []
    for candidate in top:
        explanation = (
            f"Distance: {candidate.distance_km}km | "
            f"Capacity: {candidate.available_capacity} | "
            f"Rescues: {candidate.rescue_count} | "
            f"Score: {candidate.score:.2f}"
        )
        explained.append(candidate.model_copy(update={"explanation": explanation}))

    logger.info(
        "ranking_complete",
        total_candidates=len(state["candidates"]),
        top_returned=len(explained),
    )
    return {**state, "top_candidates": explained}
