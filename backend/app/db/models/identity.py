"""Identity, OTP challenge, session, and authentication audit records.

Secrets are never stored in plaintext: OTP codes and refresh tokens are kept
only as keyed digests. Phone numbers are stored normalized to E.164 and are
never used as public resource identifiers.
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
    Integer,
    String,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.domain.identity import (
    AccountStatus,
    AuthAuditEventType,
    DevicePlatform,
    OtpPurpose,
    SessionRevocationReason,
)

PHONE_E164_MAX_LENGTH = 16
SECRET_DIGEST_MAX_LENGTH = 128


def _in_values(column: str, enum_type: type[StrEnum]) -> str:
    values = ", ".join(f"'{member.value}'" for member in enum_type)
    return f"{column} IN ({values})"


class User(Base):
    """Phone-first identity. Holds no roles, profile, or business ownership."""

    __tablename__ = "users"
    __table_args__ = (
        CheckConstraint(_in_values("status", AccountStatus), name="status_valid"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    phone_e164: Mapped[str] = mapped_column(
        String(PHONE_E164_MAX_LENGTH),
        unique=True,
        nullable=False,
    )
    phone_verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    status: Mapped[str] = mapped_column(
        String(16),
        nullable=False,
        default=AccountStatus.PENDING.value,
        server_default=AccountStatus.PENDING.value,
    )
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


class OtpChallenge(Base):
    """One-time code challenge bound to a phone, not to a user record.

    Binding to the phone lets sign-in and first registration share one flow
    without revealing whether the phone already belongs to an identity.
    """

    __tablename__ = "otp_challenges"
    __table_args__ = (
        CheckConstraint(_in_values("purpose", OtpPurpose), name="purpose_valid"),
        CheckConstraint("attempt_count >= 0", name="attempt_count_non_negative"),
        CheckConstraint("max_attempts > 0", name="max_attempts_positive"),
        CheckConstraint("attempt_count <= max_attempts", name="attempts_within_limit"),
        Index(None, "phone_e164", "purpose", "created_at"),
        Index(None, "expires_at"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    phone_e164: Mapped[str] = mapped_column(String(PHONE_E164_MAX_LENGTH), nullable=False)
    purpose: Mapped[str] = mapped_column(String(32), nullable=False)
    code_digest: Mapped[str] = mapped_column(
        String(SECRET_DIGEST_MAX_LENGTH),
        nullable=False,
    )
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    attempt_count: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=0,
        server_default="0",
    )
    max_attempts: Mapped[int] = mapped_column(Integer, nullable=False)
    consumed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )

    def __repr__(self) -> str:
        return f"OtpChallenge(id={self.id!r}, purpose={self.purpose!r})"


class AuthSession(Base):
    """Refresh-token session for one signed-in client installation.

    ``installation_id`` is a random, app-generated value reported by the
    client. It groups sessions for display and is never proof of device trust.
    """

    __tablename__ = "auth_sessions"
    __table_args__ = (
        CheckConstraint(
            f"device_platform IS NULL OR {_in_values('device_platform', DevicePlatform)}",
            name="device_platform_valid",
        ),
        CheckConstraint(
            f"revoked_reason IS NULL OR {_in_values('revoked_reason', SessionRevocationReason)}",
            name="revoked_reason_valid",
        ),
        CheckConstraint(
            "(revoked_at IS NULL) = (revoked_reason IS NULL)",
            name="revocation_consistent",
        ),
        Index(None, "user_id", "revoked_at"),
        Index(None, "expires_at"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    access_token_digest: Mapped[str] = mapped_column(
        String(SECRET_DIGEST_MAX_LENGTH),
        unique=True,
        nullable=False,
    )
    access_token_expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
    )
    refresh_token_digest: Mapped[str] = mapped_column(
        String(SECRET_DIGEST_MAX_LENGTH),
        unique=True,
        nullable=False,
    )
    installation_id: Mapped[str | None] = mapped_column(String(64))
    device_label: Mapped[str | None] = mapped_column(String(64))
    device_platform: Mapped[str | None] = mapped_column(String(16))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoked_reason: Mapped[str | None] = mapped_column(String(32))

    def __repr__(self) -> str:
        return f"AuthSession(id={self.id!r}, user_id={self.user_id!r})"


class AuthAuditEvent(Base):
    """Append-only security event. Must not contain phones, codes, or tokens."""

    __tablename__ = "auth_audit_events"
    __table_args__ = (
        CheckConstraint(_in_values("event_type", AuthAuditEventType), name="event_type_valid"),
        Index(None, "user_id", "occurred_at"),
        Index(None, "event_type", "occurred_at"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    event_type: Mapped[str] = mapped_column(String(48), nullable=False)
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid,
        ForeignKey("users.id", ondelete="SET NULL"),
    )
    target_type: Mapped[str | None] = mapped_column(String(32))
    target_id: Mapped[uuid.UUID | None] = mapped_column(Uuid)
    correlation_id: Mapped[str | None] = mapped_column(String(64))
    details: Mapped[dict[str, Any] | None] = mapped_column(JSON)
    occurred_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
