"""Server-owned platform role identifiers (Phase 07 Part 4).

Roles are granted through ``user_platform_role_assignments`` only — never via
tokens, profile fields, or client claims.
"""

from enum import StrEnum


class PlatformRole(StrEnum):
    """Narrow platform roles. Expand only with migrations and explicit scopes."""

    BUSINESS_ONBOARDING_REVIEWER = "business_onboarding_reviewer"
