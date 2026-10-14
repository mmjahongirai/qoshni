"""Read and update profile and preferences for the authenticated owner."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from enum import StrEnum

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.schemas.profile import UserPreferencesUpdateRequest, UserProfileUpdateRequest
from app.db.models.profile import UserPreferences, UserProfile


class ProfileServiceErrorCode(StrEnum):
    PROFILE_NOT_FOUND = "profile_not_found"
    PREFERENCES_NOT_FOUND = "preferences_not_found"


@dataclass(frozen=True, slots=True)
class ProfileServiceError:
    code: ProfileServiceErrorCode
    message: str


def get_user_profile(session: Session, user_id: uuid.UUID) -> UserProfile | ProfileServiceError:
    profile = session.scalar(select(UserProfile).where(UserProfile.user_id == user_id))
    if profile is None:
        return ProfileServiceError(
            code=ProfileServiceErrorCode.PROFILE_NOT_FOUND,
            message="Profile not found.",
        )
    return profile


def get_user_preferences(session: Session, user_id: uuid.UUID) -> UserPreferences | ProfileServiceError:
    preferences = session.scalar(select(UserPreferences).where(UserPreferences.user_id == user_id))
    if preferences is None:
        return ProfileServiceError(
            code=ProfileServiceErrorCode.PREFERENCES_NOT_FOUND,
            message="Preferences not found.",
        )
    return preferences


def update_user_profile(
    session: Session,
    user_id: uuid.UUID,
    payload: UserProfileUpdateRequest,
) -> UserProfile | ProfileServiceError:
    profile = get_user_profile(session, user_id)
    if isinstance(profile, ProfileServiceError):
        return profile

    fields_set = payload.model_fields_set

    if payload.clear_display_name:
        profile.display_name = None
    elif "display_name" in fields_set:
        profile.display_name = payload.display_name

    if payload.clear_avatar_storage_ref:
        profile.avatar_storage_ref = None
    elif "avatar_storage_ref" in fields_set:
        profile.avatar_storage_ref = payload.avatar_storage_ref

    session.flush()
    return profile


def update_user_preferences(
    session: Session,
    user_id: uuid.UUID,
    payload: UserPreferencesUpdateRequest,
) -> UserPreferences | ProfileServiceError:
    preferences = get_user_preferences(session, user_id)
    if isinstance(preferences, ProfileServiceError):
        return preferences

    if "preferred_language" in payload.model_fields_set and payload.preferred_language is not None:
        preferences.preferred_language = payload.preferred_language.value

    if (
        "personalization_enabled" in payload.model_fields_set
        and payload.personalization_enabled is not None
    ):
        preferences.personalization_enabled = payload.personalization_enabled

    session.flush()
    return preferences
