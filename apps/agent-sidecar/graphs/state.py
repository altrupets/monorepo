"""State definitions for the rescuer matching LangGraph."""

from typing import TypedDict

from pydantic import BaseModel


class AnimalInfo(BaseModel):
    """Information about the animal in need of rescue."""

    rescue_alert_id: str
    latitude: float
    longitude: float
    urgency: str  # LOW, MEDIUM, HIGH, CRITICAL
    animal_type: str | None = None


class CandidateData(BaseModel):
    """Data for a single rescuer candidate throughout the matching pipeline."""

    user_id: str
    name: str
    distance_km: float
    available_capacity: int
    roles: list[str]
    # Enrichment fields (filled by enrich_from_graph)
    rescue_count: int = 0
    species_specializations: list[str] = []
    vet_network_size: int = 0
    endorsement_count: int = 0
    # Scoring fields (filled by score_candidates)
    score: float = 0.0
    score_breakdown: dict[str, float] = {}
    explanation: str = ""


class MatchingState(TypedDict):
    """Top-level state flowing through the matching graph."""

    animal_info: AnimalInfo
    candidates: list[CandidateData]
    top_candidates: list[CandidateData]
    total_evaluated: int
    error: str | None
