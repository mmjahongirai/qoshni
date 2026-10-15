"""Construct a ``StoragePort`` from application settings."""

from __future__ import annotations

from pathlib import Path

from app.core.config import Settings
from app.services.object_storage.errors import StorageConfigurationError
from app.services.object_storage.local import LocalFilesystemStorage
from app.services.object_storage.port import StoragePort


def create_object_storage(settings: Settings) -> StoragePort:
    """Return a configured storage backend or raise ``StorageConfigurationError``."""

    provider = settings.object_storage_provider
    if provider is None:
        raise StorageConfigurationError("Object storage provider is not configured.")

    if provider == "s3":
        raise StorageConfigurationError(
            "S3-compatible object storage is not implemented in this release.",
        )

    if provider == "local":
        if settings.environment == "production":
            raise StorageConfigurationError(
                "Local filesystem object storage is not permitted in production.",
            )
        root = settings.object_storage_local_root
        if root is None:
            raise StorageConfigurationError(
                "Local object storage requires QOSHNI_OBJECT_STORAGE_LOCAL_ROOT.",
            )
        return LocalFilesystemStorage(
            root_directory=Path(root),
            bucket=settings.object_storage_bucket,
        )

    raise StorageConfigurationError("Unknown object storage provider.")
