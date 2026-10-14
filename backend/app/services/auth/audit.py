"""Append-only authentication audit helpers."""

from __future__ import annotations

import uuid
from typing import Any

from sqlalchemy.orm import Session

from app.db.models.identity import AuthAuditEvent
from app.domain.identity import AuthAuditEventType


def record_auth_event(
    session: Session,
    *,
    event_type: AuthAuditEventType,
    user_id: uuid.UUID | None = None,
    target_type: str | None = None,
    target_id: uuid.UUID | None = None,
    correlation_id: str | None = None,
    details: dict[str, Any] | None = None,
) -> None:
    safe_details = _sanitize_details(details)
    session.add(
        AuthAuditEvent(
            event_type=event_type.value,
            user_id=user_id,
            target_type=target_type,
            target_id=target_id,
            correlation_id=correlation_id,
            details=safe_details,
        ),
    )


_FORBIDDEN_DETAIL_KEYS = frozenset(
    {
        "phone",
        "phone_e164",
        "code",
        "otp",
        "access_token",
        "refresh_token",
        "token",
        "digest",
        "code_digest",
    },
)


def _sanitize_details(details: dict[str, Any] | None) -> dict[str, Any] | None:
    if not details:
        return None
    filtered = {
        key: value
        for key, value in details.items()
        if key.lower() not in _FORBIDDEN_DETAIL_KEYS
    }
    return filtered or None
