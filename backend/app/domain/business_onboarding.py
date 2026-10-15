"""Business onboarding, verification status, and audit vocabulary (Phase 07).

Persisted values are stored as strings and guarded by database CHECK constraints.
Renaming or removing a member requires a migration.
"""

from enum import StrEnum


class BusinessServiceCategory(StrEnum):
    """Marketplace category aligned with Flutter ``ServiceCategoryId`` names."""

    GROCERIES = "groceries"
    RESTAURANTS = "restaurants"
    PHARMACY = "pharmacy"
    SHOPS = "shops"
    MASTERS = "masters"
    RENT = "rent"


class VerificationStatus(StrEnum):
    """Server-owned verification lifecycle for one onboarding application."""

    DRAFT = "draft"
    SUBMITTED = "submitted"
    UNDER_REVIEW = "under_review"
    VERIFIED = "verified"
    REJECTED = "rejected"
    SUSPENDED = "suspended"


class OnboardingRejectionReasonCode(StrEnum):
    """Client-safe rejection codes. Does not expose internal reviewer notes."""

    INCOMPLETE_INFORMATION = "incomplete_information"
    REGISTRATION_MISMATCH = "registration_mismatch"
    JURISDICTION_UNSUPPORTED = "jurisdiction_unsupported"
    POLICY_VIOLATION = "policy_violation"
    OTHER = "other"


class OnboardingAuditEventType(StrEnum):
    """Append-only onboarding audit events (no document bytes or tax identifiers)."""

    APPLICATION_CREATED = "application_created"
    DRAFT_UPDATED = "draft_updated"
    SUBMITTED = "submitted"
    STATUS_CHANGED = "status_changed"
    REINSTATEMENT_REQUESTED = "reinstatement_requested"
    DOCUMENT_REGISTERED = "document_registered"
    DOCUMENT_UPLOAD_COMPLETED = "document_upload_completed"
    DOCUMENT_UPLOAD_FAILED = "document_upload_failed"
    DOCUMENT_DELETED = "document_deleted"
    DOCUMENT_RECONCILIATION_DETECTED = "document_reconciliation_detected"
    DOCUMENT_RECONCILIATION_RESOLVED = "document_reconciliation_resolved"


class OnboardingAuditActorRole(StrEnum):
    """Who performed an auditable action. Owners cannot assert ``reviewer``."""

    OWNER = "owner"
    REVIEWER = "reviewer"
    SYSTEM = "system"


LEGAL_BUSINESS_NAME_MAX_LENGTH = 256
TRADE_DISPLAY_NAME_MAX_LENGTH = 128
REGISTRATION_JURISDICTION_LENGTH = 2
REGISTRATION_IDENTIFIER_MAX_LENGTH = 64
TAX_IDENTIFIER_MAX_LENGTH = 64
BUSINESS_CONTACT_EMAIL_MAX_LENGTH = 320

# ISO 3166-1 alpha-2; Phase 07 Part 1 focuses on Uzbekistan registrations.
DEFAULT_REGISTRATION_JURISDICTION = "UZ"

ACTIVE_REGISTRATION_UNIQUE_INDEX = "uq_business_onboarding_active_registration"

ACTIVE_REGISTRATION_DUPLICATE_STATUSES: tuple[VerificationStatus, ...] = (
    VerificationStatus.SUBMITTED,
    VerificationStatus.UNDER_REVIEW,
    VerificationStatus.VERIFIED,
    VerificationStatus.SUSPENDED,
)

ACTIVE_REGISTRATION_DUPLICATE_STATUS_VALUES: tuple[str, ...] = tuple(
    status.value for status in ACTIVE_REGISTRATION_DUPLICATE_STATUSES
)

DUPLICATE_REGISTRATION_MESSAGE = (
    "An application with this registration identifier is already in review."
)


def normalize_registration_identifier(raw: str | None) -> str | None:
    """Persist registration identifiers without leading/trailing whitespace."""

    if raw is None:
        return None
    stripped = raw.strip()
    return stripped if stripped else None


_OWNER_TRANSITIONS: frozenset[tuple[VerificationStatus, VerificationStatus]] = frozenset(
    {
        (VerificationStatus.DRAFT, VerificationStatus.SUBMITTED),
    },
)

_PRIVILEGED_TRANSITIONS: frozenset[tuple[VerificationStatus, VerificationStatus]] = frozenset(
    {
        (VerificationStatus.SUBMITTED, VerificationStatus.UNDER_REVIEW),
        (VerificationStatus.UNDER_REVIEW, VerificationStatus.VERIFIED),
        (VerificationStatus.UNDER_REVIEW, VerificationStatus.REJECTED),
        (VerificationStatus.VERIFIED, VerificationStatus.SUSPENDED),
        (VerificationStatus.SUSPENDED, VerificationStatus.UNDER_REVIEW),
        (VerificationStatus.SUSPENDED, VerificationStatus.VERIFIED),
        (VerificationStatus.REJECTED, VerificationStatus.DRAFT),
    },
)


def is_status_transition_permitted(
    *,
    from_status: VerificationStatus,
    to_status: VerificationStatus,
    actor_role: OnboardingAuditActorRole,
) -> bool:
    """Pure transition guard for services (not enforced by SQL in Part 1).

    Owners may submit drafts only. ``verified``, ``rejected``, ``suspended``, and
    reinstatement transitions require privileged reviewer/system actors in Part 2.
    """

    if from_status == to_status:
        return False
    if to_status == VerificationStatus.VERIFIED and actor_role == OnboardingAuditActorRole.OWNER:
        return False
    if actor_role == OnboardingAuditActorRole.OWNER:
        return (from_status, to_status) in _OWNER_TRANSITIONS
    if actor_role in {OnboardingAuditActorRole.REVIEWER, OnboardingAuditActorRole.SYSTEM}:
        return (from_status, to_status) in _PRIVILEGED_TRANSITIONS
    return False


def owner_may_edit_draft_fields(status: VerificationStatus) -> bool:
    """Draft field PATCH is limited to ``draft`` (and rejected rework in Part 2)."""

    return status == VerificationStatus.DRAFT
