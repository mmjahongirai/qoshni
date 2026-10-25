"""Stable search index identifiers (no service-layer imports)."""

from __future__ import annotations

import uuid


def stable_id_for_application(application_id: uuid.UUID) -> str:
    return f"business:onboarding:{application_id}"
