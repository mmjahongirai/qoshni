"""Platform reviewer authorization dependencies."""

from __future__ import annotations

from fastapi import Depends
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.core.database import get_db
from app.db.models.identity import User
from app.domain.identity import AccountStatus
from app.domain.platform_roles import PlatformRole
from app.services.auth.principal import (
    AuthenticatedPrincipal,
    BusinessOnboardingReviewerPrincipal,
)
from app.services.auth.time_utils import utc_now
from app.services.authorization.errors import (
    AuthorizationDenied,
    AuthorizationError,
    AuthorizationErrorCode,
)
from app.services.authorization.role_assignments import get_active_role_assignment

_ALLOWED_ACCOUNT_STATUSES = frozenset({AccountStatus.ACTIVE.value})


def require_business_onboarding_reviewer(
    db: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> BusinessOnboardingReviewerPrincipal:
    """Require a valid session and an active database role assignment."""

    user = db.get(User, principal.user_id)
    if user is None or user.status not in _ALLOWED_ACCOUNT_STATUSES:
        raise AuthorizationDenied()

    now = utc_now()
    assignment = get_active_role_assignment(
        db,
        user_id=principal.user_id,
        role=PlatformRole.BUSINESS_ONBOARDING_REVIEWER,
        now=now,
    )
    if assignment is None:
        raise AuthorizationDenied(
            AuthorizationError(
                code=AuthorizationErrorCode.AUTHORIZATION_DENIED,
                message="You do not have permission to perform this action.",
            ),
        )

    return BusinessOnboardingReviewerPrincipal(
        user_id=principal.user_id,
        session_id=principal.session_id,
        role_assignment_id=assignment.id,
    )
