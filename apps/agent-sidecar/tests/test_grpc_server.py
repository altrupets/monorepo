"""Tests for gRPC server handlers and servicer logic."""

from __future__ import annotations

from unittest.mock import AsyncMock, patch

import pytest

from grpc.handlers.find_rescuers import handle_find_rescuers
from grpc.handlers.record_outcome import handle_record_outcome


@pytest.mark.asyncio
@patch("grpc.handlers.find_rescuers.matching_graph")
async def test_handle_find_rescuers_returns_structure(mock_graph):
    """Handler should return dict with expected keys."""
    mock_graph.ainvoke = AsyncMock(
        return_value={
            "top_candidates": [],
            "total_evaluated": 0,
            "error": None,
        }
    )

    result = await handle_find_rescuers(
        rescue_alert_id="alert-001",
        latitude=19.43,
        longitude=-99.13,
        urgency="HIGH",
        animal_type="dog",
        max_candidates=5,
        trace_id="trace-abc",
    )

    assert "candidates" in result
    assert "total_evaluated" in result
    assert "duration_ms" in result
    assert "trace_id" in result
    assert result["trace_id"] == "trace-abc"


@pytest.mark.asyncio
@patch("grpc.handlers.record_outcome.get_settings")
async def test_handle_record_outcome_falkordb_unavailable(mock_settings):
    """When FalkorDB is unavailable, handler should return accepted=False gracefully."""
    mock_settings.return_value.falkordb_host = "nonexistent-host"
    mock_settings.return_value.falkordb_port = 9999

    result = await handle_record_outcome(
        rescue_alert_id="alert-001",
        rescuer_id="rescuer-1",
        animal_id="animal-1",
        successful=True,
        vet_id="vet-1",
        trace_id="trace-xyz",
    )

    assert result["accepted"] is False
