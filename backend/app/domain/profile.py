"""User profile and personalization vocabulary (Phase 06).

Values are persisted as strings and guarded by database CHECK constraints.
Renaming or removing a member requires a migration.
"""

from enum import StrEnum


class SupportedLocale(StrEnum):
    """Application UI locales aligned with Flutter ``AppLocalizations``."""

    ENGLISH = "en"
    RUSSIAN = "ru"
    UZBEK = "uz"


PROFILE_DISPLAY_NAME_MAX_LENGTH = 64
AVATAR_STORAGE_REF_MAX_LENGTH = 512
