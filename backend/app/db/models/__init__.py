"""Import ORM models so they register on Base.metadata for autogenerate."""

from app.db.models.identity import AuthAuditEvent, AuthSession, OtpChallenge, User
from app.db.models.profile import UserPreferences, UserProfile

__all__ = [
    "AuthAuditEvent",
    "AuthSession",
    "OtpChallenge",
    "User",
    "UserPreferences",
    "UserProfile",
]
