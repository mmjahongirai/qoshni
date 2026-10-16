"""Object storage errors (provider-independent)."""

from __future__ import annotations


class StorageError(Exception):
    """Base class for private object storage failures."""


class StorageConfigurationError(StorageError):
    """Storage is misconfigured or unavailable for this environment."""


class StorageKeyInvalidError(StorageError):
    """Rejected storage object key (unsafe or malformed)."""


class StorageObjectNotFoundError(StorageError):
    """No object exists for the given key."""


class StorageObjectAlreadyExistsError(StorageError):
    """Put refused because the key is already occupied (when overwrite is disabled)."""


class StorageOperationError(StorageError):
    """Unexpected storage backend failure."""
