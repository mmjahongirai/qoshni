"""Explicit permission scopes for ``business_onboarding_reviewer`` (server-owned).

Review decision HTTP routes remain unimplemented; this mapping documents the
intended least-privilege boundary for future privileged workflows.
"""

from enum import StrEnum

from app.domain.platform_roles import PlatformRole


class BusinessOnboardingReviewerPermission(StrEnum):
    READ_SUBMITTED_APPLICATIONS = "onboarding.read_submitted_applications"
    READ_PRIVATE_VERIFICATION_METADATA = "onboarding.read_private_verification_metadata"
    READ_PRIVATE_DOCUMENT_METADATA = "onboarding.read_private_document_metadata"
    RECORD_REVIEW_DECISION = "onboarding.record_review_decision"


BUSINESS_ONBOARDING_REVIEWER_PERMISSIONS: frozenset[BusinessOnboardingReviewerPermission] = (
    frozenset(
        {
            BusinessOnboardingReviewerPermission.READ_SUBMITTED_APPLICATIONS,
            BusinessOnboardingReviewerPermission.READ_PRIVATE_VERIFICATION_METADATA,
            BusinessOnboardingReviewerPermission.READ_PRIVATE_DOCUMENT_METADATA,
            BusinessOnboardingReviewerPermission.RECORD_REVIEW_DECISION,
        },
    )
)

ROLE_PERMISSIONS: dict[PlatformRole, frozenset[BusinessOnboardingReviewerPermission]] = {
    PlatformRole.BUSINESS_ONBOARDING_REVIEWER: BUSINESS_ONBOARDING_REVIEWER_PERMISSIONS,
}
