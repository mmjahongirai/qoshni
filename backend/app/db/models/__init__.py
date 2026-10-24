"""Import ORM models so they register on Base.metadata for autogenerate."""

from app.db.models.branch_coordinates import BusinessOnboardingBranchCoordinate
from app.db.models.business_onboarding import (
    BusinessOnboardingApplication,
    BusinessOnboardingAuditEvent,
    BusinessOnboardingDocument,
)
from app.db.models.identity import AuthAuditEvent, AuthSession, OtpChallenge, User
from app.db.models.platform_roles import UserPlatformRoleAssignment
from app.db.models.profile import UserPreferences, UserProfile
from app.db.models.saved_places import UserSavedPlace
from app.db.models.search_discovery import (
    SearchIndexMetadata,
    SearchIndexProjectionReceipt,
    SearchIndexRecord,
)

__all__ = [
    "AuthAuditEvent",
    "AuthSession",
    "BusinessOnboardingBranchCoordinate",
    "BusinessOnboardingApplication",
    "BusinessOnboardingAuditEvent",
    "BusinessOnboardingDocument",
    "OtpChallenge",
    "User",
    "UserPlatformRoleAssignment",
    "UserPreferences",
    "UserProfile",
    "SearchIndexMetadata",
    "SearchIndexProjectionReceipt",
    "SearchIndexRecord",
    "UserSavedPlace",
]
