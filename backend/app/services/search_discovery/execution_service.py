"""Execute authenticated search against the derived index."""

from __future__ import annotations

from dataclasses import dataclass

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.db.models.search_discovery import SearchIndexRecord
from app.domain.location_search import (
    MAX_LATITUDE,
    MAX_LONGITUDE,
    MIN_LATITUDE,
    MIN_LONGITUDE,
    SEARCH_MAX_RADIUS_METERS,
    SEARCH_MIN_RADIUS_METERS,
)
from app.domain.search_discovery import (
    SEARCH_DEFAULT_PAGE_SIZE,
    SEARCH_MAX_PAGE_SIZE,
    SEARCH_MIN_PAGE_SIZE,
    SEARCH_QUERY_MAX_LENGTH,
    SearchDiscoveryErrorCode,
)
from app.services.search_discovery.spatial import coordinates_are_valid, haversine_meters
from app.services.search_discovery.cursor import (
    CURSOR_VERSION,
    RankedRowLike,
    SearchCursorPayload,
    cursor_is_after_row,
    decode_signed_cursor,
    encode_signed_cursor,
)
from app.services.search_discovery.metadata import get_catalog_generation
from app.services.search_discovery.ranking import RankedSearchRow, rank_records
from app.services.search_discovery.text_normalizer import normalize_query_text


@dataclass(frozen=True, slots=True)
class SearchResultItem:
    stable_id: str
    kind: str
    title: str
    is_sponsored: bool
    branch_latitude: float | None = None
    branch_longitude: float | None = None


@dataclass(frozen=True, slots=True)
class SearchExecutionResult:
    items: tuple[SearchResultItem, ...]
    next_cursor: str | None
    query_fingerprint: str
    catalog_generation: int


@dataclass(frozen=True, slots=True)
class SearchExecutionError:
    code: SearchDiscoveryErrorCode
    message: str


def _query_fingerprint(
    raw_query: str,
    category_scope: str | None,
    only_open: bool,
    *,
    max_distance_meters: int | None,
    search_latitude: float | None,
    search_longitude: float | None,
) -> str:
    normalized = normalize_query_text(raw_query)
    location_part = (
        f"{search_latitude}:{search_longitude}"
        if search_latitude is not None and search_longitude is not None
        else ""
    )
    return "|".join(
        [
            normalized,
            category_scope or "",
            "open" if only_open else "",
            str(max_distance_meters) if max_distance_meters is not None else "",
            location_part,
        ]
    )


def _validate_location_params(
    *,
    search_latitude: float | None,
    search_longitude: float | None,
    max_distance_meters: int | None,
) -> SearchExecutionError | None:
    has_lat = search_latitude is not None
    has_lng = search_longitude is not None
    if has_lat != has_lng:
        return SearchExecutionError(
            code=SearchDiscoveryErrorCode.VALIDATION_FAILED,
            message="Search latitude and longitude must be provided together.",
        )
    if has_lat and search_latitude is not None and search_longitude is not None:
        if not (
            MIN_LATITUDE <= search_latitude <= MAX_LATITUDE
            and MIN_LONGITUDE <= search_longitude <= MAX_LONGITUDE
        ):
            return SearchExecutionError(
                code=SearchDiscoveryErrorCode.VALIDATION_FAILED,
                message="Search coordinates are out of range.",
            )
    if max_distance_meters is not None:
        if max_distance_meters < SEARCH_MIN_RADIUS_METERS:
            return SearchExecutionError(
                code=SearchDiscoveryErrorCode.VALIDATION_FAILED,
                message="Search radius is below the minimum bound.",
            )
        if max_distance_meters > SEARCH_MAX_RADIUS_METERS:
            return SearchExecutionError(
                code=SearchDiscoveryErrorCode.VALIDATION_FAILED,
                message="Search radius exceeds the maximum bound.",
            )
        if not has_lat:
            return SearchExecutionError(
                code=SearchDiscoveryErrorCode.VALIDATION_FAILED,
                message="Distance filter requires search coordinates.",
            )
    return None


def _validate_request(
    *,
    raw_query: str,
    page_size: int,
    only_open: bool,
    max_distance_meters: int | None,
    search_latitude: float | None,
    search_longitude: float | None,
) -> SearchExecutionError | None:
    normalized = normalize_query_text(raw_query)
    if not normalized:
        return SearchExecutionError(
            code=SearchDiscoveryErrorCode.VALIDATION_FAILED,
            message="Query is required.",
        )
    if len(raw_query) > SEARCH_QUERY_MAX_LENGTH:
        return SearchExecutionError(
            code=SearchDiscoveryErrorCode.VALIDATION_FAILED,
            message="Query is too long.",
        )
    if page_size < SEARCH_MIN_PAGE_SIZE or page_size > SEARCH_MAX_PAGE_SIZE:
        return SearchExecutionError(
            code=SearchDiscoveryErrorCode.VALIDATION_FAILED,
            message="Page size is out of bounds.",
        )
    location_validation = _validate_location_params(
        search_latitude=search_latitude,
        search_longitude=search_longitude,
        max_distance_meters=max_distance_meters,
    )
    if location_validation is not None:
        return location_validation
    if only_open:
        return SearchExecutionError(
            code=SearchDiscoveryErrorCode.VALIDATION_FAILED,
            message="Open-now filter is not supported on the backend index yet.",
        )
    return None


def _apply_location_filter(
    records: list[SearchIndexRecord],
    *,
    search_latitude: float,
    search_longitude: float,
    max_distance_meters: int,
) -> list[SearchIndexRecord]:
    filtered: list[SearchIndexRecord] = []
    for record in records:
        if not coordinates_are_valid(record.branch_latitude, record.branch_longitude):
            continue
        assert record.branch_latitude is not None
        assert record.branch_longitude is not None
        distance = haversine_meters(
            origin_latitude=search_latitude,
            origin_longitude=search_longitude,
            target_latitude=record.branch_latitude,
            target_longitude=record.branch_longitude,
        )
        if distance <= max_distance_meters:
            filtered.append(record)
    return filtered


def execute_search(
    session: Session,
    settings: Settings,
    *,
    raw_query: str,
    page_size: int = SEARCH_DEFAULT_PAGE_SIZE,
    cursor: str | None = None,
    category_scope: str | None = None,
    only_open: bool = False,
    max_distance_meters: int | None = None,
    search_latitude: float | None = None,
    search_longitude: float | None = None,
) -> SearchExecutionResult | SearchExecutionError:
    validation = _validate_request(
        raw_query=raw_query,
        page_size=page_size,
        only_open=only_open,
        max_distance_meters=max_distance_meters,
        search_latitude=search_latitude,
        search_longitude=search_longitude,
    )
    if validation is not None:
        return validation

    fingerprint = _query_fingerprint(
        raw_query,
        category_scope,
        only_open,
        max_distance_meters=max_distance_meters,
        search_latitude=search_latitude,
        search_longitude=search_longitude,
    )
    generation = get_catalog_generation(session)

    cursor_payload: SearchCursorPayload | None = None
    if cursor:
        cursor_payload = decode_signed_cursor(settings, cursor)
        if cursor_payload is None:
            return SearchExecutionError(
                code=SearchDiscoveryErrorCode.INVALID_CURSOR,
                message="Cursor is invalid or tampered.",
            )
        if (
            cursor_payload.query_fingerprint != fingerprint
            or cursor_payload.catalog_generation != generation
        ):
            return SearchExecutionError(
                code=SearchDiscoveryErrorCode.INVALID_CURSOR,
                message="Cursor does not match the current query or catalog generation.",
            )

    records = list(session.scalars(select(SearchIndexRecord)).all())
    if category_scope:
        records = [r for r in records if r.category_scope == category_scope]

    if (
        search_latitude is not None
        and search_longitude is not None
        and max_distance_meters is not None
    ):
        records = _apply_location_filter(
            records,
            search_latitude=search_latitude,
            search_longitude=search_longitude,
            max_distance_meters=max_distance_meters,
        )

    ranked = rank_records(records, raw_query=raw_query)
    window: list[RankedSearchRow] = ranked
    if cursor_payload is not None:
        window = [
            row
            for row in ranked
            if cursor_is_after_row(
                cursor_payload,
                RankedRowLike(
                    stable_id=row.record.stable_id,
                    total_score=row.total_score,
                    relevance_score=row.relevance_score,
                ),
            )
        ]

    page = window[:page_size]
    items = tuple(
        SearchResultItem(
            stable_id=row.record.stable_id,
            kind=row.record.kind,
            title=row.record.title,
            is_sponsored=False,
            branch_latitude=row.record.branch_latitude,
            branch_longitude=row.record.branch_longitude,
        )
        for row in page
    )

    next_cursor: str | None = None
    if len(window) > page_size and page:
        last = page[-1]
        next_cursor = encode_signed_cursor(
            settings,
            SearchCursorPayload(
                version=CURSOR_VERSION,
                query_fingerprint=fingerprint,
                catalog_generation=generation,
                after_total_score=last.total_score,
                after_relevance_score=last.relevance_score,
                after_stable_id=last.record.stable_id,
            ),
        )

    return SearchExecutionResult(
        items=items,
        next_cursor=next_cursor,
        query_fingerprint=fingerprint,
        catalog_generation=generation,
    )
