"""Authenticated caller identity (authentication only, not authorization)."""

from __future__ import annotations

import uuid
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class AuthenticatedPrincipal:
    """Minimal principal resolved from a valid access token."""

    user_id: uuid.UUID
    session_id: uuid.UUID
