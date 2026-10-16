"""Database-backed platform role assignments (authorization, not authentication)."""

import uuid
from datetime import datetime

from sqlalchemy import (
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    String,
    Uuid,
    func,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.domain.platform_roles import PlatformRole
from app.domain.role_assignments import (
    ACTIVE_PLATFORM_ROLE_UNIQUE_INDEX,
    GRANT_REFERENCE_MAX_LENGTH,
    RoleAssignmentGrantSource,
    RoleAssignmentRevocationReason,
)


def _in_values(column: str, enum_type: type) -> str:
    from enum import StrEnum

    assert issubclass(enum_type, StrEnum)
    values = ", ".join(f"'{member.value}'" for member in enum_type)
    return f"{column} IN ({values})"


_ACTIVE_ASSIGNMENT_WHERE = "revoked_at IS NULL"


class UserPlatformRoleAssignment(Base):
    """Historical grant of one platform role to one user.

    At most one non-revoked row per (user_id, role) is enforced by a partial
    unique index. Expiry is evaluated at authorization time.
    """

    __tablename__ = "user_platform_role_assignments"
    __table_args__ = (
        CheckConstraint(
            _in_values("role", PlatformRole),
            name="role_valid",
        ),
        CheckConstraint(
            _in_values("grant_source", RoleAssignmentGrantSource),
            name="grant_source_valid",
        ),
        CheckConstraint(
            f"revocation_reason IS NULL OR {_in_values('revocation_reason', RoleAssignmentRevocationReason)}",
            name="revocation_reason_valid",
        ),
        CheckConstraint(
            "(revoked_at IS NULL) = (revocation_reason IS NULL)",
            name="revocation_consistent",
        ),
        CheckConstraint(
            "expires_at IS NULL OR expires_at >= granted_at",
            name="expires_at_not_before_granted_at",
        ),
        CheckConstraint(
            "revoked_at IS NULL OR revoked_at >= granted_at",
            name="revoked_at_not_before_granted_at",
        ),
        CheckConstraint(
            "grant_reference IS NULL OR length(trim(grant_reference)) > 0",
            name="grant_reference_not_blank",
        ),
        CheckConstraint(
            "grant_reference IS NULL OR grant_reference = trim(grant_reference)",
            name="grant_reference_trimmed",
        ),
        Index(
            "ix_user_platform_role_assignments_user_id_role_granted_at",
            "user_id",
            "role",
            "granted_at",
        ),
        Index(
            ACTIVE_PLATFORM_ROLE_UNIQUE_INDEX,
            "user_id",
            "role",
            unique=True,
            sqlite_where=text(_ACTIVE_ASSIGNMENT_WHERE),
            postgresql_where=text(_ACTIVE_ASSIGNMENT_WHERE),
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    role: Mapped[str] = mapped_column(String(48), nullable=False)
    granted_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revocation_reason: Mapped[str | None] = mapped_column(String(48), nullable=True)
    granted_by_user_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid,
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    grant_source: Mapped[str] = mapped_column(String(48), nullable=False)
    grant_reference: Mapped[str | None] = mapped_column(
        String(GRANT_REFERENCE_MAX_LENGTH),
        nullable=True,
    )

    def __repr__(self) -> str:
        return (
            f"UserPlatformRoleAssignment(id={self.id!r}, user_id={self.user_id!r}, role={self.role!r})"
        )
