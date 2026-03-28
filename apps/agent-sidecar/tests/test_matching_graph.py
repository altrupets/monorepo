"""Tests for the rescuer matching graph and individual nodes."""

from __future__ import annotations

import pytest

from graphs.state import AnimalInfo, CandidateData, MatchingState
from graphs.nodes.score_candidates import score_candidates
from graphs.nodes.rank_and_explain import rank_and_explain


def _make_state(
    candidates: list[CandidateData] | None = None,
    urgency: str = "MEDIUM",
    animal_type: str | None = "dog",
) -> MatchingState:
    """Build a minimal MatchingState for testing."""
    return {
        "animal_info": AnimalInfo(
            rescue_alert_id="alert-001",
            latitude=19.4326,
            longitude=-99.1332,
            urgency=urgency,
            animal_type=animal_type,
        ),
        "candidates": candidates or [],
        "top_candidates": [],
        "total_evaluated": len(candidates or []),
        "error": None,
    }


def _make_candidate(**overrides) -> CandidateData:
    """Build a CandidateData with sensible defaults."""
    defaults = {
        "user_id": "user-1",
        "name": "Test Rescuer",
        "distance_km": 5.0,
        "available_capacity": 3,
        "roles": ["RESCUER"],
        "rescue_count": 10,
        "species_specializations": ["dog", "cat"],
        "vet_network_size": 2,
        "endorsement_count": 5,
    }
    defaults.update(overrides)
    return CandidateData(**defaults)


@pytest.mark.asyncio
async def test_score_candidates_basic():
    """Scoring should produce non-zero scores for valid candidates."""
    candidates = [
        _make_candidate(user_id="u1", distance_km=5.0, available_capacity=3, rescue_count=10),
        _make_candidate(user_id="u2", distance_km=20.0, available_capacity=1, rescue_count=2),
    ]
    state = _make_state(candidates=candidates, urgency="MEDIUM")
    result = await score_candidates(state)
    scored = result["candidates"]

    assert len(scored) == 2
    assert scored[0].score > 0
    assert scored[1].score > 0
    # Closer candidate with more capacity and rescues should score higher
    assert scored[0].score > scored[1].score


@pytest.mark.asyncio
async def test_score_candidates_empty():
    """Scoring an empty candidate list should return an empty list."""
    state = _make_state(candidates=[])
    result = await score_candidates(state)
    assert result["candidates"] == []


@pytest.mark.asyncio
async def test_score_breakdown_keys():
    """Score breakdown should contain the four expected factor keys."""
    candidates = [_make_candidate()]
    state = _make_state(candidates=candidates)
    result = await score_candidates(state)
    breakdown = result["candidates"][0].score_breakdown
    assert set(breakdown.keys()) == {"distance", "capacity", "reputation", "specialization"}


@pytest.mark.asyncio
async def test_rank_and_explain_ordering():
    """Candidates should be returned in descending score order."""
    candidates = [
        _make_candidate(user_id="low", score=0.3),
        _make_candidate(user_id="high", score=0.9),
        _make_candidate(user_id="mid", score=0.6),
    ]
    state = _make_state(candidates=candidates)
    result = await rank_and_explain(state)
    top = result["top_candidates"]

    assert top[0].user_id == "high"
    assert top[1].user_id == "mid"
    assert top[2].user_id == "low"


@pytest.mark.asyncio
async def test_rank_and_explain_generates_explanation():
    """Each top candidate should have a non-empty explanation string."""
    candidates = [_make_candidate(score=0.75)]
    state = _make_state(candidates=candidates)
    result = await rank_and_explain(state)
    explanation = result["top_candidates"][0].explanation

    assert "Distance:" in explanation
    assert "Capacity:" in explanation
    assert "Rescues:" in explanation
    assert "Score:" in explanation
