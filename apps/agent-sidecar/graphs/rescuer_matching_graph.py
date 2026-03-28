"""LangGraph definition for the rescuer matching pipeline."""

from langgraph.graph import END, START, StateGraph

from graphs.nodes.enrich_from_graph import enrich_from_graph
from graphs.nodes.fetch_candidates import fetch_candidates
from graphs.nodes.rank_and_explain import rank_and_explain
from graphs.nodes.score_candidates import score_candidates
from graphs.state import MatchingState

# Build the graph: four sequential nodes
builder = StateGraph(MatchingState)

builder.add_node("fetch_candidates", fetch_candidates)
builder.add_node("enrich_from_graph", enrich_from_graph)
builder.add_node("score_candidates", score_candidates)
builder.add_node("rank_and_explain", rank_and_explain)

builder.add_edge(START, "fetch_candidates")
builder.add_edge("fetch_candidates", "enrich_from_graph")
builder.add_edge("enrich_from_graph", "score_candidates")
builder.add_edge("score_candidates", "rank_and_explain")
builder.add_edge("rank_and_explain", END)

matching_graph = builder.compile()
