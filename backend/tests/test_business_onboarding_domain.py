"""Verification status transition guards (pure domain)."""

import pytest

from app.domain.business_onboarding import (
    OnboardingAuditActorRole,
    VerificationStatus,
    is_status_transition_permitted,
    owner_may_edit_draft_fields,
)


@pytest.mark.parametrize(
    ("from_status", "to_status"),
    [
        (VerificationStatus.DRAFT, VerificationStatus.SUBMITTED),
    ],
)
def test_owner_may_submit_draft_only(
    from_status: VerificationStatus,
    to_status: VerificationStatus,
) -> None:
    assert is_status_transition_permitted(
        from_status=from_status,
        to_status=to_status,
        actor_role=OnboardingAuditActorRole.OWNER,
    )


def test_owner_cannot_self_verify() -> None:
    assert not is_status_transition_permitted(
        from_status=VerificationStatus.UNDER_REVIEW,
        to_status=VerificationStatus.VERIFIED,
        actor_role=OnboardingAuditActorRole.OWNER,
    )


def test_reviewer_may_verify_after_review() -> None:
    assert is_status_transition_permitted(
        from_status=VerificationStatus.UNDER_REVIEW,
        to_status=VerificationStatus.VERIFIED,
        actor_role=OnboardingAuditActorRole.REVIEWER,
    )


def test_suspended_operations_require_privileged_actor() -> None:
    assert not is_status_transition_permitted(
        from_status=VerificationStatus.VERIFIED,
        to_status=VerificationStatus.SUSPENDED,
        actor_role=OnboardingAuditActorRole.OWNER,
    )
    assert is_status_transition_permitted(
        from_status=VerificationStatus.VERIFIED,
        to_status=VerificationStatus.SUSPENDED,
        actor_role=OnboardingAuditActorRole.REVIEWER,
    )


def test_owner_edits_limited_to_draft() -> None:
    assert owner_may_edit_draft_fields(VerificationStatus.DRAFT)
    assert not owner_may_edit_draft_fields(VerificationStatus.SUBMITTED)
    assert not owner_may_edit_draft_fields(VerificationStatus.VERIFIED)
