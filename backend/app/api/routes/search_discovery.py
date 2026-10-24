"""Authenticated search discovery endpoint."""

from __future__ import annotations

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.schemas.search_discovery import (
    SearchDiscoveryRequest,
    SearchDiscoveryResponse,
    SearchDiscoveryResultItem,
)
from app.api.search_discovery_responses import search_discovery_error_response
from app.core.config import Settings, get_settings
from app.core.database import get_db
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.search_discovery.execution_service import SearchExecutionError, execute_search

router = APIRouter(prefix="/search/discovery", tags=["search-discovery"])


@router.post("", response_model=SearchDiscoveryResponse)
def search_discovery(
    body: SearchDiscoveryRequest,
    session: Session = Depends(get_db),
    settings: Settings = Depends(get_settings),
    _principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> SearchDiscoveryResponse | JSONResponse:
    result = execute_search(
        session,
        settings,
        raw_query=body.query,
        page_size=body.page_size,
        cursor=body.cursor,
        category_scope=body.category_scope,
        only_open=body.only_open,
        max_distance_meters=body.max_distance_meters,
        search_latitude=body.search_latitude,
        search_longitude=body.search_longitude,
    )
    if isinstance(result, SearchExecutionError):
        return search_discovery_error_response(result)

    return SearchDiscoveryResponse(
        items=[
            SearchDiscoveryResultItem(
                stable_id=item.stable_id,
                kind=item.kind,
                title=item.title,
                is_sponsored=item.is_sponsored,
                branch_latitude=item.branch_latitude,
                branch_longitude=item.branch_longitude,
            )
            for item in result.items
        ],
        next_cursor=result.next_cursor,
        query_fingerprint=result.query_fingerprint,
        catalog_generation=result.catalog_generation,
    )
