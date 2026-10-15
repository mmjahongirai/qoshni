"""Business onboarding applications and verification audit events.

Distinct from Flutter Business Center demo drafts and from future public
``BusinessProfile`` listings (Phase 08). Ownership references ``users.id`` only.
"""

import uuid
from datetime import datetime
from enum import StrEnum
from typing import Any

from sqlalchemy import (
    JSON,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    String,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.domain.business_onboarding import (
    BusinessServiceCategory,
    OnboardingAuditActorRole,
    OnboardingAuditEventType,
    OnboardingRejectionReasonCode,
    VerificationStatus,
)


def _in_values(column: str, enum_type: type[StrEnum]) -> str:
    values = ", ".join(f"'{member.value}'" for member in enum_type)
    return f"{column} IN ({values})"


class BusinessOnboardingApplication(Base):
    """One verifiable business registration attempt owned by an authenticated user."""

    __tablename__ = "business_onboarding_applications"
    __table_args__ = (
        CheckConstraint(
            f"service_category IS NULL OR {_in_values('service_category', BusinessServiceCategory)}",
            name="service_category_valid",
        ),
        CheckConstraint(
            _in_values("verification_status", VerificationStatus),
            name="verification_status_valid",
        ),
        CheckConstraint(
            f"rejection_reason_code IS NULL OR {_in_values('rejection_reason_code', OnboardingRejectionReasonCode)}",
            name="rejection_reason_code_valid",
        ),
        CheckConstraint(
            "length(registration_jurisdiction) = 2",
            name="registration_jurisdiction_iso_alpha2",
        ),
        CheckConstraint(
            "legal_business_name IS NULL OR length(trim(legal_business_name)) > 0",
            name="legal_business_name_not_blank",
        ),
        CheckConstraint(
            "trade_display_name IS NULL OR length(trim(trade_display_name)) > 0",
            name="trade_display_name_not_blank",
        ),
        CheckConstraint(
            "registration_identifier IS NULL OR length(trim(registration_identifier)) > 0",
            name="registration_identifier_not_blank",
        ),
        CheckConstraint(
            "tax_identifier IS NULL OR length(trim(tax_identifier)) > 0",
            name="tax_identifier_not_blank",
        ),
        CheckConstraint(
            "business_contact_email IS NULL OR length(trim(business_contact_email)) > 0",
            name="business_contact_email_not_blank",
        ),
        CheckConstraint(
            "(verification_status != 'rejected') OR (rejection_reason_code IS NOT NULL)",
            name="rejected_requires_reason_code",
        ),
        CheckConstraint(
            "(verification_status = 'rejected') OR (rejection_reason_code IS NULL)",
            name="reason_code_only_when_rejected",
        ),
        CheckConstraint(
            "(verification_status = 'draft') OR (submitted_at IS NOT NULL)",
            name="submitted_timestamp_when_not_draft",
        ),
        Index(
            "ix_business_onboarding_applications_owner_user_id_created_at",
            "owner_user_id",
            "created_at",
        ),
        Index(
            "ix_business_onboarding_applications_verification_status_updated_at",
            "verification_status",
            "updated_at",
        ),
        Index(
            "ix_business_onboarding_applications_registration_jurisdiction_registration_identifier",
            "registration_jurisdiction",
            "registration_identifier",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    owner_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    legal_business_name: Mapped[str | None] = mapped_column(String(256), nullable=True)
    trade_display_name: Mapped[str | None] = mapped_column(String(128), nullable=True)
    service_category: Mapped[str | None] = mapped_column(String(32), nullable=True)
    registration_jurisdiction: Mapped[str] = mapped_column(
        String(2),
        nullable=False,
        default="UZ",
        server_default="UZ",
    )
    registration_identifier: Mapped[str | None] = mapped_column(String(64), nullable=True)
    tax_identifier: Mapped[str | None] = mapped_column(String(64), nullable=True)
    business_contact_email: Mapped[str | None] = mapped_column(String(320), nullable=True)
    verification_status: Mapped[str] = mapped_column(
        String(32),
        nullable=False,
        default=VerificationStatus.DRAFT.value,
        server_default=VerificationStatus.DRAFT.value,
    )
    rejection_reason_code: Mapped[str | None] = mapped_column(String(48), nullable=True)
    submitted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    def __repr__(self) -> str:
        return (
            f"BusinessOnboardingApplication(id={self.id!r}, "
            f"owner_user_id={self.owner_user_id!r}, "
            f"verification_status={self.verification_status!r})"
        )


class BusinessOnboardingAuditEvent(Base):
    """Append-only verification audit trail for onboarding applications."""

    __tablename__ = "business_onboarding_audit_events"
    __table_args__ = (
        CheckConstraint(
            _in_values("event_type", OnboardingAuditEventType),
            name="event_type_valid",
        ),
        CheckConstraint(
            f"actor_role IS NULL OR {_in_values('actor_role', OnboardingAuditActorRole)}",
            name="actor_role_valid",
        ),
        CheckConstraint(
            f"from_status IS NULL OR {_in_values('from_status', VerificationStatus)}",
            name="from_status_valid",
        ),
        CheckConstraint(
            f"to_status IS NULL OR {_in_values('to_status', VerificationStatus)}",
            name="to_status_valid",
        ),
        Index(
            "ix_business_onboarding_audit_events_application_id_occurred_at",
            "application_id",
            "occurred_at",
        ),
        Index(
            "ix_business_onboarding_audit_events_event_type_occurred_at",
            "event_type",
            "occurred_at",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    application_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("business_onboarding_applications.id", ondelete="CASCADE"),
        nullable=False,
    )
    event_type: Mapped[str] = mapped_column(String(48), nullable=False)
    from_status: Mapped[str | None] = mapped_column(String(32), nullable=True)
    to_status: Mapped[str | None] = mapped_column(String(32), nullable=True)
    actor_role: Mapped[str | None] = mapped_column(String(16), nullable=True)
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid,
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    correlation_id: Mapped[str | None] = mapped_column(String(64), nullable=True)
    details: Mapped[dict[str, Any] | None] = mapped_column(JSON)
    occurred_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )

    def __repr__(self) -> str:
        return f"BusinessOnboardingAuditEvent(id={self.id!r}, event_type={self.event_type!r})"
