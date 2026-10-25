"""Authenticated saved-place CRUD."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse, Response
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.saved_places_responses import saved_place_error_response
from app.api.schemas.saved_places import (
    SavedPlaceCreateRequest,
    SavedPlaceUpdateRequest,
    SavedPlaceView,
)
from app.core.database import get_db
from app.db.models.saved_places import UserSavedPlace
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.saved_places.saved_place_service import (
    SavedPlaceServiceError,
    create_saved_place,
    delete_saved_place,
    list_saved_places,
    update_saved_place,
)

router = APIRouter(prefix="/saved-places", tags=["saved-places"])


def _view(row: UserSavedPlace) -> SavedPlaceView:
    return SavedPlaceView(
        id=row.id,
        label=row.label,
        latitude=row.latitude,
        longitude=row.longitude,
        address_description=row.address_description,
        created_at=row.created_at,
        updated_at=row.updated_at,
    )


@router.get("", response_model=list[SavedPlaceView])
def read_saved_places(
    session: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> list[SavedPlaceView]:
    rows = list_saved_places(session, principal.user_id)
    return [_view(row) for row in rows]


@router.post("", response_model=SavedPlaceView, status_code=201)
def create_saved_place_route(
    body: SavedPlaceCreateRequest,
    session: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> SavedPlaceView | JSONResponse:
    result = create_saved_place(
        session,
        principal.user_id,
        label=body.label,
        latitude=body.latitude,
        longitude=body.longitude,
        address_description=body.address_description,
    )
    if isinstance(result, SavedPlaceServiceError):
        return saved_place_error_response(result)
    session.commit()
    return _view(result)


@router.patch("/{place_id}", response_model=SavedPlaceView)
def patch_saved_place(
    place_id: uuid.UUID,
    body: SavedPlaceUpdateRequest,
    session: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> SavedPlaceView | JSONResponse:
    result = update_saved_place(
        session,
        principal.user_id,
        place_id,
        label=body.label,
        latitude=body.latitude,
        longitude=body.longitude,
        address_description=body.address_description,
        clear_address_description=body.clear_address_description,
    )
    if isinstance(result, SavedPlaceServiceError):
        return saved_place_error_response(result)
    session.commit()
    return _view(result)


@router.delete(
    "/{place_id}",
    responses={204: {"description": "Saved place deleted."}},
)
def remove_saved_place(
    place_id: uuid.UUID,
    session: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
):
    result = delete_saved_place(session, principal.user_id, place_id)
    if isinstance(result, SavedPlaceServiceError):
        return saved_place_error_response(result)
    session.commit()
    return Response(status_code=204)
