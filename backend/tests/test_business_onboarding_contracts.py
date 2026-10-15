"""Onboarding API contract metadata (no live routes)."""

import uuid

import pytest
from pydantic import ValidationError

from app.api.schemas.business_onboarding import (
    ONBOARDING_ENDPOINT_CONTRACTS,
    OnboardingApplicationDraftUpdateRequest,
    OwnerOnboardingApplicationView,
)
from app.domain.business_onboarding import VerificationStatus


def test_owner_contracts_implemented_privileged_deferred() -> None:
    assert len(ONBOARDING_ENDPOINT_CONTRACTS) >= 6
    owner = [c for c in ONBOARDING_ENDPOINT_CONTRACTS if c.owner_accessible]
    privileged = [c for c in ONBOARDING_ENDPOINT_CONTRACTS if not c.owner_accessible]
    assert owner
    assert all(contract.implemented for contract in owner)
    assert privileged
    assert all(not contract.implemented for contract in privileged)


def test_owner_and_privileged_routes_are_distinguished() -> None:
    owner_paths = {
        contract.path
        for contract in ONBOARDING_ENDPOINT_CONTRACTS
        if contract.owner_accessible
    }
    privileged_paths = {
        contract.path
        for contract in ONBOARDING_ENDPOINT_CONTRACTS
        if not contract.owner_accessible
    }
    assert any("/internal/" in path for path in privileged_paths)
    assert not any("/internal/" in path for path in owner_paths)


def test_draft_update_rejects_owner_user_id_claims() -> None:
    with pytest.raises(ValidationError):
        OnboardingApplicationDraftUpdateRequest(
            legal_business_name="Ada",
            owner_user_id=uuid.uuid4(),  # type: ignore[call-arg]
        )


def test_owner_view_excludes_owner_user_id() -> None:
    from datetime import UTC, datetime

    now = datetime.now(UTC)
    view = OwnerOnboardingApplicationView(
        application_id=uuid.uuid4(),
        registration_jurisdiction="UZ",
        verification_status=VerificationStatus.DRAFT,
        created_at=now,
        updated_at=now,
    )
    payload = view.model_dump()
    assert "owner_user_id" not in payload
    assert "user_id" not in payload
