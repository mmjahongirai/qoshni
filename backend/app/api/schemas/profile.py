"""Profile and preferences API contracts for ``/api/v1/me/*`` routes.

Shapes mirror ``user_profiles`` and ``user_preferences`` and forbid
client-supplied ownership fields such as ``user_id``.
"""

import uuid
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum

from pydantic import BaseModel, ConfigDict, StringConstraints
from typing_extensions import Annotated

from app.domain.profile import (
    AVATAR_STORAGE_REF_MAX_LENGTH,
    PROFILE_DISPLAY_NAME_MAX_LENGTH,
    SupportedLocale,
)


class _Request(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


class _Response(BaseModel):
    model_config = ConfigDict(extra="forbid")


DisplayName = Annotated[
    str,
    StringConstraints(
        min_length=1,
        max_length=PROFILE_DISPLAY_NAME_MAX_LENGTH,
        strip_whitespace=True,
    ),
]

AvatarStorageRef = Annotated[
    str,
    StringConstraints(
        min_length=1,
        max_length=AVATAR_STORAGE_REF_MAX_LENGTH,
        strip_whitespace=True,
    ),
]


class UserProfileView(_Response):
    profile_id: uuid.UUID
    display_name: str | None = None
    avatar_storage_ref: str | None = None
    created_at: datetime
    updated_at: datetime


class UserProfileUpdateRequest(_Request):
    """Patchable profile fields only."""

    display_name: DisplayName | None = None
    avatar_storage_ref: AvatarStorageRef | None = None
    clear_display_name: bool = False
    clear_avatar_storage_ref: bool = False


class UserPreferencesView(_Response):
    preferences_id: uuid.UUID
    preferred_language: SupportedLocale
    personalization_enabled: bool
    created_at: datetime
    updated_at: datetime


class UserPreferencesUpdateRequest(_Request):
    preferred_language: SupportedLocale | None = None
    personalization_enabled: bool | None = None


class ProfileErrorCode(StrEnum):
    PROFILE_NOT_FOUND = "profile_not_found"
    PREFERENCES_NOT_FOUND = "preferences_not_found"


class ProfileErrorDetail(_Response):
    code: ProfileErrorCode
    message: str


class ProfileErrorResponse(_Response):
    error: ProfileErrorDetail


@dataclass(frozen=True)
class ProfileEndpointContract:
    method: str
    path: str
    summary: str
    request_model: type[BaseModel] | None
    response_model: type[BaseModel] | None
    success_status: int
    requires_access_token: bool
    implemented: bool = False


PROFILE_ENDPOINT_CONTRACTS: tuple[ProfileEndpointContract, ...] = (
    ProfileEndpointContract(
        "GET",
        "/me/profile",
        "Return the caller's profile.",
        None,
        UserProfileView,
        200,
        requires_access_token=True,
        implemented=True,
    ),
    ProfileEndpointContract(
        "PATCH",
        "/me/profile",
        "Update display name or avatar storage reference.",
        UserProfileUpdateRequest,
        UserProfileView,
        200,
        requires_access_token=True,
        implemented=True,
    ),
    ProfileEndpointContract(
        "GET",
        "/me/preferences",
        "Return the caller's explicit preferences.",
        None,
        UserPreferencesView,
        200,
        requires_access_token=True,
        implemented=True,
    ),
    ProfileEndpointContract(
        "PATCH",
        "/me/preferences",
        "Update language or personalization opt-in.",
        UserPreferencesUpdateRequest,
        UserPreferencesView,
        200,
        requires_access_token=True,
        implemented=True,
    ),
)
