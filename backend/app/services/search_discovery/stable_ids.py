"""Stable search index identifiers (no service-layer imports)."""

from __future__ import annotations

import uuid

_APPLICATION_STABLE_ID_PREFIX = "business:onboarding:"


def stable_id_for_application(application_id: uuid.UUID) -> str:
    return f"{_APPLICATION_STABLE_ID_PREFIX}{application_id}"


def application_id_from_stable_id(stable_id: str) -> uuid.UUID | None:
    """Inverse of :func:`stable_id_for_application`; ``None`` for any other shape."""
    if not stable_id.startswith(_APPLICATION_STABLE_ID_PREFIX):
        return None
    try:
        parsed = uuid.UUID(stable_id[len(_APPLICATION_STABLE_ID_PREFIX) :])
    except ValueError:
        return None
    if stable_id_for_application(parsed) != stable_id:
        return None
    return parsed
