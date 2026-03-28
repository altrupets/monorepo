"""Enrich candidates with rescue history and social graph data from FalkorDB."""

from __future__ import annotations

import structlog

from config.settings import get_settings
from graphs.state import MatchingState

logger = structlog.get_logger(__name__)


async def _query_falkordb(graph, user_id: str) -> dict:
    """Run Cypher queries against FalkorDB to fetch enrichment data for one candidate."""

    # Rescue count
    result = graph.query(
        "MATCH (r:Rescuer {id: $id})-[:RESCUED]->(a:Animal) RETURN count(a) AS cnt",
        params={"id": user_id},
    )
    rescue_count = result.result_set[0][0] if result.result_set else 0

    # Species specializations
    result = graph.query(
        "MATCH (r:Rescuer {id: $id})-[:RESCUED]->(a:Animal) "
        "RETURN DISTINCT a.species AS species",
        params={"id": user_id},
    )
    specializations = [row[0] for row in result.result_set] if result.result_set else []

    # Vet network size
    result = graph.query(
        "MATCH (r:Rescuer {id: $id})-[:KNOWS]->(v:Vet) RETURN count(v) AS cnt",
        params={"id": user_id},
    )
    vet_network_size = result.result_set[0][0] if result.result_set else 0

    # Endorsements
    result = graph.query(
        "MATCH (r:Rescuer {id: $id})<-[:ENDORSED]-(u) RETURN count(u) AS cnt",
        params={"id": user_id},
    )
    endorsement_count = result.result_set[0][0] if result.result_set else 0

    return {
        "rescue_count": rescue_count,
        "species_specializations": specializations,
        "vet_network_size": vet_network_size,
        "endorsement_count": endorsement_count,
    }


async def enrich_from_graph(state: MatchingState) -> MatchingState:
    """Enrich each candidate with data from FalkorDB.

    If FalkorDB is unavailable, candidates keep their defaults (0 counts, empty lists).
    """
    settings = get_settings()
    candidates = state["candidates"]

    if not candidates:
        return state

    try:
        from falkordb import FalkorDB

        db = FalkorDB(host=settings.falkordb_host, port=settings.falkordb_port)
        graph = db.select_graph("altrupets")
    except Exception:
        logger.warning("falkordb_unavailable", msg="Using default enrichment values")
        return state

    enriched = []
    for candidate in candidates:
        try:
            data = await _query_falkordb(graph, candidate.user_id)
            enriched.append(
                candidate.model_copy(update=data)
            )
        except Exception:
            logger.warning(
                "enrichment_failed_for_candidate",
                user_id=candidate.user_id,
            )
            enriched.append(candidate)

    logger.info("enrichment_complete", enriched_count=len(enriched))
    return {**state, "candidates": enriched}
