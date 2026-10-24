"""Search discovery API schemas."""

from __future__ import annotations

from pydantic import BaseModel, Field

from app.domain.search_discovery import SEARCH_DEFAULT_PAGE_SIZE, SEARCH_MAX_PAGE_SIZE


class SearchDiscoveryRequest(BaseModel):
    query: str = Field(min_length=1, max_length=120)
    cursor: str | None = None
    page_size: int = Field(default=SEARCH_DEFAULT_PAGE_SIZE, ge=1, le=SEARCH_MAX_PAGE_SIZE)
    only_open: bool = False
    max_distance_meters: int | None = Field(default=None, ge=0)
    category_scope: str | None = None
    search_latitude: float | None = None
    search_longitude: float | None = None


class SearchDiscoveryResultItem(BaseModel):
    stable_id: str
    kind: str
    title: str
    is_sponsored: bool


class SearchDiscoveryResponse(BaseModel):
    items: list[SearchDiscoveryResultItem]
    next_cursor: str | None = None
    query_fingerprint: str | None = None
    catalog_generation: int | None = None


class SearchDiscoveryErrorDetail(BaseModel):
    code: str
    message: str


class SearchDiscoveryErrorResponse(BaseModel):
    error: SearchDiscoveryErrorDetail
