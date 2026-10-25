"""Deterministic query normalization (aligned with Flutter WP1)."""

from __future__ import annotations

import re

_WHITESPACE = re.compile(r"\s+")


def normalize_query_text(raw: str) -> str:
    trimmed = raw.strip()
    if not trimmed:
        return ""
    return _WHITESPACE.sub(" ", trimmed).lower()
