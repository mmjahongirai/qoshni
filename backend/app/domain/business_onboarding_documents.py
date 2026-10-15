"""Private onboarding document vocabulary (Phase 07 Part 3).

Document bytes live in private object storage only. Database rows hold metadata
and opaque storage keys — never public URLs or file contents.
"""

from enum import StrEnum


class BusinessOnboardingDocumentType(StrEnum):
    """Controlled document categories for KYC onboarding."""

    REGISTRATION_CERTIFICATE = "registration_certificate"
    TAX_REGISTRATION = "tax_registration"
    AUTHORIZED_REPRESENTATIVE_ID = "authorized_representative_id"
    OTHER_SUPPORTING = "other_supporting"


class BusinessOnboardingDocumentLifecycle(StrEnum):
    """Document lifecycle states.

    Part 3 persists only ``awaiting_upload`` (metadata slot, no bytes verified).
    Later increments may transition rows after real upload, scanning and review.
    """

    AWAITING_UPLOAD = "awaiting_upload"
    UPLOADED_PENDING_VALIDATION = "uploaded_pending_validation"
    QUARANTINED = "quarantined"
    REJECTED = "rejected"
    ACCEPTED_FOR_REVIEW = "accepted_for_review"
    DELETED = "deleted"


STORAGE_OBJECT_KEY_MAX_LENGTH = 512
DECLARED_CONTENT_TYPE_MAX_LENGTH = 128
CHECKSUM_SHA256_HEX_LENGTH = 64
