"""Import ORM models so they register on Base.metadata for autogenerate."""

from app.db.models.business_onboarding import (
    BusinessOnboardingApplication,
    BusinessOnboardingAuditEvent,
    BusinessOnboardingDocument,
)
from app.db.models.identity import AuthAuditEvent, AuthSession, OtpChallenge, User
from app.db.models.profile import UserPreferences, UserProfile

__all__ = [
    "AuthAuditEvent",
    "AuthSession",
    "BusinessOnboardingApplication",
    "BusinessOnboardingAuditEvent",
    "BusinessOnboardingDocument",
    "OtpChallenge",
    "User",
    "UserPreferences",
    "UserProfile",
]
