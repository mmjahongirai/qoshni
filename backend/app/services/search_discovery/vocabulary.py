"""Static demo synonym vocabulary mirrored from Flutter WP1 (not ML)."""

from __future__ import annotations

from dataclasses import dataclass

from app.domain.business_onboarding import BusinessServiceCategory
from app.services.search_discovery.text_normalizer import normalize_query_text


@dataclass(frozen=True, slots=True)
class SearchVocabularyTerm:
    normalized_forms: tuple[str, ...]
    category: BusinessServiceCategory | None
    synonym_variants: tuple[str, ...] = ()


def build_search_demo_vocabulary() -> tuple[SearchVocabularyTerm, ...]:
    def term(
        forms: list[str],
        category: BusinessServiceCategory | None = None,
        synonyms: list[str] | None = None,
    ) -> SearchVocabularyTerm:
        normalized = tuple({normalize_query_text(f) for f in forms if f.strip()})
        syns = tuple({normalize_query_text(s) for s in (synonyms or forms) if s.strip()})
        return SearchVocabularyTerm(normalized_forms=normalized, category=category, synonym_variants=syns)

    pharmacy = term(
        ["dorixona", "dori xona", "apteka", "дорихона", "аптека", "фармация"],
        BusinessServiceCategory.PHARMACY,
    )
    restaurant = term(
        ["restoran", "ресторан", "oshxona", "ошхона"],
        BusinessServiceCategory.RESTAURANTS,
    )
    groceries = term(
        ["bozor", "магазин", "groceries", "supermarket"],
        BusinessServiceCategory.GROCERIES,
    )
    return (pharmacy, restaurant, groceries)


def expand_query_terms(normalized_query: str) -> tuple[set[str], set[BusinessServiceCategory]]:
    if not normalized_query:
        return set(), set()
    match_terms: set[str] = {normalized_query}
    implied: set[BusinessServiceCategory] = set()
    for entry in build_search_demo_vocabulary():
        if normalized_query in entry.normalized_forms:
            match_terms.update(entry.normalized_forms)
            match_terms.update(entry.synonym_variants)
            if entry.category is not None:
                implied.add(entry.category)
        for variant in entry.synonym_variants:
            if normalized_query in variant or variant in normalized_query:
                match_terms.update(entry.synonym_variants)
                if entry.category is not None:
                    implied.add(entry.category)
    return match_terms, implied
