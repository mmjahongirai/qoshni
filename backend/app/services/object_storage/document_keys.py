"""Server-side onboarding document object key helpers."""

from __future__ import annotations

import re
import uuid

_ONBOARDING_DOCUMENT_KEY = re.compile(
    r"^private/onboarding/(?P<application_id>[0-9a-fA-F-]{36})/(?P<document_id>[0-9a-fA-F-]{36})$",
)


def parse_onboarding_document_object_key(key: str) -> tuple[uuid.UUID, uuid.UUID] | None:
    match = _ONBOARDING_DOCUMENT_KEY.fullmatch(key.strip())
    if match is None:
        return None
    try:
        return (
            uuid.UUID(match.group("application_id")),
            uuid.UUID(match.group("document_id")),
        )
    except ValueError:
        return None
