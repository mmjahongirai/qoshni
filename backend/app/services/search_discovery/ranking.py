"""Deterministic ranking aligned with Flutter WP2 demo policy."""

from __future__ import annotations

from dataclasses import dataclass

from app.db.models.search_discovery import SearchIndexRecord
from app.domain.search_discovery import SearchIndexEligibility
from app.services.search_discovery.text_normalizer import normalize_query_text
from app.services.search_discovery.vocabulary import expand_query_terms


@dataclass(frozen=True, slots=True)
class RankedSearchRow:
    record: SearchIndexRecord
    relevance_score: float
    total_score: float


def _title_prefix_match(title: str, query: str) -> bool:
    if not query:
        return False
    return title.startswith(query) or f" {query}" in title


def rank_row(
    record: SearchIndexRecord,
    *,
    normalized_query: str,
    match_terms: set[str],
    implied_categories: set[str],
) -> RankedSearchRow | None:
    if record.eligibility_status != SearchIndexEligibility.ELIGIBLE.value:
        return None

    title = normalize_query_text(record.title)
    haystack = normalize_query_text(f"{record.title} {record.subtitle} {record.category_scope or ''}")

    relevance = 0.0
    if normalized_query and title == normalized_query:
        relevance = 1.0
    elif normalized_query and _title_prefix_match(title, normalized_query):
        relevance = 0.78
    else:
        for term in match_terms:
            if not term:
                continue
            if term in title:
                relevance = max(relevance, 0.85)
            elif term in haystack:
                relevance = max(relevance, 0.62)

    if record.category_scope and record.category_scope in implied_categories:
        relevance = max(relevance, 0.55)

    if relevance <= 0.0:
        return None

    total = relevance
    return RankedSearchRow(record=record, relevance_score=relevance, total_score=total)


def rank_records(
    records: list[SearchIndexRecord],
    *,
    raw_query: str,
) -> list[RankedSearchRow]:
    normalized = normalize_query_text(raw_query)
    if not normalized:
        return []
    match_terms, implied = expand_query_terms(normalized)
    implied_values = {c.value for c in implied}
    ranked: list[RankedSearchRow] = []
    for record in records:
        row = rank_row(
            record,
            normalized_query=normalized,
            match_terms=match_terms,
            implied_categories=implied_values,
        )
        if row is not None:
            ranked.append(row)
    ranked.sort(key=lambda row: (-row.relevance_score, -row.total_score, row.record.stable_id))
    return ranked
