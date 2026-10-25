"""Search & discovery read-model vocabulary (Phase 16 WP3)."""

from enum import StrEnum


class SearchIndexEligibility(StrEnum):
    """Derived eligibility for public search — not a substitute for verification status."""

    ELIGIBLE = "eligible"
    SUSPENDED = "suspended"
    INELIGIBLE = "ineligible"


class SearchIndexRecordKind(StrEnum):
    BUSINESS = "business"
    CATEGORY = "category"


class SearchDiscoveryErrorCode(StrEnum):
    VALIDATION_FAILED = "validation_failed"
    INVALID_CURSOR = "invalid_cursor"
    AUTHENTICATION_REQUIRED = "authentication_required"
    SERVICE_UNAVAILABLE = "service_unavailable"


# Cursor signing domain (HMAC via auth digest key).
SEARCH_CURSOR_HMAC_DOMAIN = "search_cursor_v1"

SEARCH_MIN_PAGE_SIZE = 1
SEARCH_MAX_PAGE_SIZE = 20
SEARCH_DEFAULT_PAGE_SIZE = 8
SEARCH_QUERY_MAX_LENGTH = 120
