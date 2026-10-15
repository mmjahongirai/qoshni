"""Reviewer authorization guards for onboarding (decision routes deferred)."""

from __future__ import annotations

import uuid
from enum import StrEnum

_REVIEW_FORBIDDEN_MESSAGE = "You do not have permission to perform this action."


class ReviewAuthorizationErrorCode(StrEnum):
    FORBIDDEN = "forbidden"


class ReviewAuthorizationError(Exception):
    """Raised when a reviewer is not permitted to act on an application."""

    def __init__(
        self,
        *,
        code: ReviewAuthorizationErrorCode,
        message: str,
    ) -> None:
        self.code = code
        self.message = message
        super().__init__(message)


def assert_reviewer_not_application_owner(
    *,
    reviewer_user_id: uuid.UUID,
    owner_user_id: uuid.UUID,
) -> None:
    """Reject self-review. Does not disclose application or review details."""

    if reviewer_user_id == owner_user_id:
        raise ReviewAuthorizationError(
            code=ReviewAuthorizationErrorCode.FORBIDDEN,
            message=_REVIEW_FORBIDDEN_MESSAGE,
        )
