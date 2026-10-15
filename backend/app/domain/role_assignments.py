"""Role assignment grant and revocation vocabulary."""

from enum import StrEnum


class RoleAssignmentGrantSource(StrEnum):
    """How an assignment was created. Does not identify an unverified human actor."""

    OPERATOR_CONTROL_PLANE = "operator_control_plane"
    ROLE_ADMIN_API = "role_admin_api"


class RoleAssignmentRevocationReason(StrEnum):
    """Why an assignment was revoked (append-only history)."""

    OPERATOR_REVOCATION = "operator_revocation"
    SUPERSEDED_BY_NEW_GRANT = "superseded_by_new_grant"
    SECURITY_ACTION = "security_action"
    ROLE_ADMIN_API = "role_admin_api"


GRANT_REFERENCE_MAX_LENGTH = 128

ACTIVE_PLATFORM_ROLE_UNIQUE_INDEX = "uq_user_platform_role_assignment_active"
