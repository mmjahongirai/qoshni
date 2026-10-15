"""Validation for opaque storage object keys (not filesystem paths from clients)."""

from __future__ import annotations

import re

from app.services.object_storage.errors import StorageKeyInvalidError

_KEY_PATTERN = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._/-]{0,511}$")

_FORBIDDEN_SUBSTRINGS = ("..", "\\", "\0")


def validate_storage_object_key(key: str) -> str:
    """Return a trimmed key or raise ``StorageKeyInvalidError``."""

    trimmed = key.strip()
    if not trimmed or trimmed != key:
        raise StorageKeyInvalidError("Storage object key must be non-empty and trimmed.")
    if trimmed.startswith("/") or trimmed.startswith("./"):
        raise StorageKeyInvalidError("Storage object key must be relative and opaque.")
    if "\\" in trimmed or "\0" in trimmed:
        raise StorageKeyInvalidError("Storage object key contains forbidden characters.")
    if ".." in trimmed.split("/"):
        raise StorageKeyInvalidError("Storage object key must not contain parent segments.")
    if not _KEY_PATTERN.fullmatch(trimmed):
        raise StorageKeyInvalidError("Storage object key has an invalid format.")
    return trimmed
