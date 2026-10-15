"""Resolve active platform role assignments from the database."""

from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.platform_roles import UserPlatformRoleAssignment
from app.domain.platform_roles import PlatformRole
from app.services.auth.time_utils import as_utc


def is_role_assignment_active(
    assignment: UserPlatformRoleAssignment,
    *,
    now: datetime,
) -> bool:
    if assignment.revoked_at is not None:
        return False
    if assignment.expires_at is not None and as_utc(assignment.expires_at) <= as_utc(now):
        return False
    return True


def get_active_role_assignment(
    session: Session,
    *,
    user_id: uuid.UUID,
    role: PlatformRole,
    now: datetime,
) -> UserPlatformRoleAssignment | None:
    """Return the current non-revoked, non-expired assignment for ``role``, if any."""

    rows = session.scalars(
        select(UserPlatformRoleAssignment)
        .where(
            UserPlatformRoleAssignment.user_id == user_id,
            UserPlatformRoleAssignment.role == role.value,
            UserPlatformRoleAssignment.revoked_at.is_(None),
        )
        .order_by(UserPlatformRoleAssignment.granted_at.desc()),
    ).all()
    for assignment in rows:
        if is_role_assignment_active(assignment, now=now):
            return assignment
    return None
