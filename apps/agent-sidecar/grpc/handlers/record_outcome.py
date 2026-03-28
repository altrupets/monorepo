"""Handler for the RecordRescueOutcome RPC."""

from __future__ import annotations

import structlog

from config.settings import get_settings

logger = structlog.get_logger(__name__)


async def handle_record_outcome(
    rescue_alert_id: str,
    rescuer_id: str,
    animal_id: str,
    successful: bool,
    vet_id: str,
    trace_id: str,
) -> dict:
    """Record a rescue outcome in FalkorDB and update specialization scores.

    Creates or updates the RESCUED relationship between Rescuer and Animal nodes.

    Returns a dict with key: accepted (bool).
    """
    settings = get_settings()

    logger.info(
        "record_outcome_start",
        rescue_alert_id=rescue_alert_id,
        rescuer_id=rescuer_id,
        animal_id=animal_id,
        successful=successful,
        trace_id=trace_id,
    )

    try:
        from falkordb import FalkorDB

        db = FalkorDB(host=settings.falkordb_host, port=settings.falkordb_port)
        graph = db.select_graph("altrupets")

        # Create or update RESCUED relationship
        graph.query(
            "MERGE (r:Rescuer {id: $rescuer_id}) "
            "MERGE (a:Animal {id: $animal_id}) "
            "MERGE (r)-[rel:RESCUED]->(a) "
            "SET rel.rescue_alert_id = $rescue_alert_id, "
            "    rel.successful = $successful, "
            "    rel.timestamp = timestamp()",
            params={
                "rescuer_id": rescuer_id,
                "animal_id": animal_id,
                "rescue_alert_id": rescue_alert_id,
                "successful": successful,
            },
        )

        # If a vet was involved, record the relationship
        if vet_id:
            graph.query(
                "MERGE (r:Rescuer {id: $rescuer_id}) "
                "MERGE (v:Vet {id: $vet_id}) "
                "MERGE (r)-[:KNOWS]->(v)",
                params={"rescuer_id": rescuer_id, "vet_id": vet_id},
            )

        # Recalculate species specialization count for the rescuer
        result = graph.query(
            "MATCH (r:Rescuer {id: $rescuer_id})-[:RESCUED]->(a:Animal) "
            "RETURN DISTINCT a.species AS species, count(*) AS cnt",
            params={"rescuer_id": rescuer_id},
        )
        specializations = {row[0]: row[1] for row in result.result_set} if result.result_set else {}

        logger.info(
            "record_outcome_complete",
            rescuer_id=rescuer_id,
            specializations=specializations,
            trace_id=trace_id,
        )

        return {"accepted": True}

    except Exception:
        logger.exception("record_outcome_failed", trace_id=trace_id)
        return {"accepted": False}
