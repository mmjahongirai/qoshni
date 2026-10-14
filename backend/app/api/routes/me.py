"""Authenticated caller profile and preferences."""

from __future__ import annotations

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.profile_responses import profile_error_response
from app.api.schemas.profile import (
    ProfileErrorResponse,
    UserPreferencesUpdateRequest,
    UserPreferencesView,
    UserProfileUpdateRequest,
    UserProfileView,
)
from app.domain.profile import SupportedLocale
from app.core.database import get_db
from app.db.models.profile import UserPreferences, UserProfile
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.profile.profile_service import (
    ProfileServiceError,
    get_user_preferences,
    get_user_profile,
    update_user_preferences,
    update_user_profile,
)

router = APIRouter(prefix="/me", tags=["me"])


def _profile_view(row: UserProfile) -> UserProfileView:
    return UserProfileView(
        profile_id=row.id,
        display_name=row.display_name,
        avatar_storage_ref=row.avatar_storage_ref,
        created_at=row.created_at,
        updated_at=row.updated_at,
    )


def _preferences_view(row: UserPreferences) -> UserPreferencesView:
    return UserPreferencesView(
        preferences_id=row.id,
        preferred_language=SupportedLocale(row.preferred_language),
        personalization_enabled=row.personalization_enabled,
        created_at=row.created_at,
        updated_at=row.updated_at,
    )


@router.get("/profile", response_model=UserProfileView, responses={404: {"model": ProfileErrorResponse}})
def read_profile(
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> UserProfileView | JSONResponse:
    result = get_user_profile(db, principal.user_id)
    if isinstance(result, ProfileServiceError):
        return profile_error_response(result)
    return _profile_view(result)


@router.patch("/profile", response_model=UserProfileView, responses={404: {"model": ProfileErrorResponse}})
def patch_profile(
    payload: UserProfileUpdateRequest,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> UserProfileView | JSONResponse:
    result = update_user_profile(db, principal.user_id, payload)
    if isinstance(result, ProfileServiceError):
        return profile_error_response(result)
    db.commit()
    return _profile_view(result)


@router.get(
    "/preferences",
    response_model=UserPreferencesView,
    responses={404: {"model": ProfileErrorResponse}},
)
def read_preferences(
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> UserPreferencesView | JSONResponse:
    result = get_user_preferences(db, principal.user_id)
    if isinstance(result, ProfileServiceError):
        return profile_error_response(result)
    return _preferences_view(result)


@router.patch(
    "/preferences",
    response_model=UserPreferencesView,
    responses={404: {"model": ProfileErrorResponse}},
)
def patch_preferences(
    payload: UserPreferencesUpdateRequest,
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> UserPreferencesView | JSONResponse:
    result = update_user_preferences(db, principal.user_id, payload)
    if isinstance(result, ProfileServiceError):
        return profile_error_response(result)
    db.commit()
    return _preferences_view(result)
