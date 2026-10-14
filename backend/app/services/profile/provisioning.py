"""Idempotent profile and preferences provisioning for authenticated users."""

from __future__ import annotations

import uuid

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db.models.profile import UserPreferences, UserProfile


def ensure_user_profile_resources(session: Session, user_id: uuid.UUID) -> None:
    """Ensure one profile and one preferences row exist for ``user_id``.

    Safe to call multiple times and from concurrent sign-in attempts. Uses
    savepoints so a uniqueness race does not abort the outer transaction.
    """

    _ensure_row(
        session,
        model=UserProfile,
        user_id=user_id,
        factory=lambda: UserProfile(user_id=user_id),
    )
    _ensure_row(
        session,
        model=UserPreferences,
        user_id=user_id,
        factory=lambda: UserPreferences(user_id=user_id),
    )


def _ensure_row(
    session: Session,
    *,
    model: type[UserProfile] | type[UserPreferences],
    user_id: uuid.UUID,
    factory,
) -> None:
    existing = session.scalar(select(model).where(model.user_id == user_id).limit(1))
    if existing is not None:
        return

    nested = session.begin_nested()
    try:
        session.add(factory())
        session.flush()
    except IntegrityError:
        nested.rollback()
        if session.scalar(select(model).where(model.user_id == user_id).limit(1)) is None:
            raise
