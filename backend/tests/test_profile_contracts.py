"""Profile API contract shapes (no live endpoints)."""

import uuid
from datetime import UTC, datetime

import pytest
from pydantic import ValidationError

from app.api.schemas.profile import (
    PROFILE_ENDPOINT_CONTRACTS,
    UserPreferencesUpdateRequest,
    UserPreferencesView,
    UserProfileUpdateRequest,
    UserProfileView,
)
from app.domain.profile import SupportedLocale


def test_profile_contracts_are_implemented() -> None:
    assert len(PROFILE_ENDPOINT_CONTRACTS) == 4
    assert all(contract.implemented for contract in PROFILE_ENDPOINT_CONTRACTS)
    paths = {contract.path for contract in PROFILE_ENDPOINT_CONTRACTS}
    assert paths == {"/me/profile", "/me/preferences"}


def test_profile_update_rejects_user_id_claims() -> None:
    with pytest.raises(ValidationError):
        UserProfileUpdateRequest(display_name="Ada", user_id=uuid.uuid4())  # type: ignore[call-arg]


def test_preferences_update_accepts_supported_locales() -> None:
    request = UserPreferencesUpdateRequest(preferred_language=SupportedLocale.UZBEK)
    assert request.preferred_language == SupportedLocale.UZBEK


def test_profile_view_excludes_phone_fields() -> None:
    now = datetime.now(UTC)
    view = UserProfileView(
        profile_id=uuid.uuid4(),
        display_name="Demo",
        created_at=now,
        updated_at=now,
    )
    payload = view.model_dump()
    assert "phone" not in payload
    assert "phone_e164" not in payload
    assert "user_id" not in payload
