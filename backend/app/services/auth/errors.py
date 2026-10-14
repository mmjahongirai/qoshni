"""Authentication service outcomes mapped to HTTP responses."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum
import uuid


class AuthServiceErrorCode(StrEnum):
    CHALLENGE_INVALID = "challenge_invalid"
    CHALLENGE_EXPIRED = "challenge_expired"
    CHALLENGE_CONSUMED = "challenge_consumed"
    CHALLENGE_LOCKED = "challenge_locked"
    CODE_INCORRECT = "code_incorrect"
    RATE_LIMITED = "rate_limited"
    FEATURE_NOT_AVAILABLE = "feature_not_available"
    SERVICE_UNAVAILABLE = "service_unavailable"
    ACCOUNT_UNAVAILABLE = "account_unavailable"
    SESSION_INVALID = "session_invalid"
    SESSION_NOT_FOUND = "session_not_found"
    AUTHENTICATION_REQUIRED = "authentication_required"


@dataclass(frozen=True, slots=True)
class AuthServiceError:
    code: AuthServiceErrorCode
    message: str
    retry_after_seconds: int | None = None
    attempts_remaining: int | None = None


@dataclass(frozen=True, slots=True)
class OtpChallengeCreated:
    challenge_id: uuid.UUID
    expires_at: datetime
    code_length: int


@dataclass(frozen=True, slots=True)
class SessionIssued:
    access_token: str
    access_token_expires_at: datetime
    refresh_token: str
    refresh_token_expires_at: datetime
    user_id: uuid.UUID
    session_id: uuid.UUID
    session_created_at: datetime
    session_expires_at: datetime
    device_label: str | None
    device_platform: str | None
