"""Heuristic scoring for rescuer candidates (no LLM call for MVP)."""

from __future__ import annotations

import structlog

from graphs.nodes.fetch_candidates import URGENCY_RADIUS
from graphs.state import MatchingState

logger = structlog.get_logger(__name__)

# Weight configuration
_W_DISTANCE = 0.30
_W_CAPACITY = 0.25
_W_REPUTATION = 0.25
_W_SPECIALIZATION = 0.20


async def score_candidates(state: MatchingState) -> MatchingState:
    """Score each candidate using a weighted heuristic.

    Factors:
    - distance_score = max(0, 1 - (distance_km / max_radius)) * 0.30
    - capacity_score = min(capacity / 5, 1) * 0.25
    - reputation_score = min(rescue_count / 20, 1) * 0.25
    - specialization_score = (1 if animal_type in specializations else 0.3) * 0.20
    """
    animal = state["animal_info"]
    max_radius = URGENCY_RADIUS.get(animal.urgency, 25.0)
    scored = []

    for candidate in state["candidates"]:
        distance_score = max(0.0, 1.0 - (candidate.distance_km / max_radius)) * _W_DISTANCE
        capacity_score = min(candidate.available_capacity / 5.0, 1.0) * _W_CAPACITY
        reputation_score = min(candidate.rescue_count / 20.0, 1.0) * _W_REPUTATION

        has_specialization = (
            animal.animal_type is not None
            and animal.animal_type.lower()
            in [s.lower() for s in candidate.species_specializations]
        )
        specialization_score = (1.0 if has_specialization else 0.3) * _W_SPECIALIZATION

        total = distance_score + capacity_score + reputation_score + specialization_score

        breakdown = {
            "distance": round(distance_score, 4),
            "capacity": round(capacity_score, 4),
            "reputation": round(reputation_score, 4),
            "specialization": round(specialization_score, 4),
        }

        scored.append(
            candidate.model_copy(
                update={
                    "score": round(total, 4),
                    "score_breakdown": breakdown,
                }
            )
        )

    logger.info("scoring_complete", candidates_scored=len(scored))
    return {**state, "candidates": scored}
