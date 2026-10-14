"""User-facing profile and explicit preferences.

Profile data is separate from authentication identity (`User`). Phone numbers,
tokens, and verification state remain on `users` and auth tables only.
"""

import uuid
from datetime import datetime

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    String,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.domain.profile import (
    AVATAR_STORAGE_REF_MAX_LENGTH,
    PROFILE_DISPLAY_NAME_MAX_LENGTH,
    SupportedLocale,
)


def _locale_values() -> str:
    values = ", ".join(f"'{member.value}'" for member in SupportedLocale)
    return f"preferred_language IN ({values})"


class UserProfile(Base):
    """Optional display identity for one authenticated user."""

    __tablename__ = "user_profiles"
    __table_args__ = (
        CheckConstraint(
            "display_name IS NULL OR length(trim(display_name)) > 0",
            name="display_name_not_blank",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    display_name: Mapped[str | None] = mapped_column(
        String(PROFILE_DISPLAY_NAME_MAX_LENGTH),
        nullable=True,
    )
    avatar_storage_ref: Mapped[str | None] = mapped_column(
        String(AVATAR_STORAGE_REF_MAX_LENGTH),
        nullable=True,
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

    def __repr__(self) -> str:
        return f"UserProfile(id={self.id!r}, user_id={self.user_id!r})"


class UserPreferences(Base):
    """Explicit, typed personalization settings for one user."""

    __tablename__ = "user_preferences"
    __table_args__ = (CheckConstraint(_locale_values(), name="preferred_language_valid"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    preferred_language: Mapped[str] = mapped_column(
        String(8),
        nullable=False,
        default=SupportedLocale.ENGLISH.value,
        server_default=SupportedLocale.ENGLISH.value,
    )
    personalization_enabled: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=False,
        server_default="0",
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

    def __repr__(self) -> str:
        return f"UserPreferences(id={self.id!r}, user_id={self.user_id!r})"
