"""Construct a ``StoragePort`` from application settings."""

from __future__ import annotations

from pathlib import Path

from app.core.config import Settings
from app.services.object_storage.errors import StorageConfigurationError
from app.services.object_storage.local import LocalFilesystemStorage
from app.services.object_storage.port import StoragePort
from app.services.object_storage.s3 import S3ObjectStorage


def create_object_storage(settings: Settings) -> StoragePort:
    """Return a configured storage backend or raise ``StorageConfigurationError``."""

    provider = settings.object_storage_provider
    if provider is None:
        raise StorageConfigurationError("Object storage provider is not configured.")

    if provider == "s3":
        bucket = settings.object_storage_bucket
        if not bucket or not bucket.strip():
            raise StorageConfigurationError("S3 object storage requires QOSHNI_OBJECT_STORAGE_BUCKET.")
        access_key = settings.object_storage_access_key_id
        secret_key = settings.object_storage_secret_access_key
        if access_key is None or secret_key is None:
            raise StorageConfigurationError(
                "S3 object storage requires access key credentials.",
            )
        region = settings.object_storage_region
        if not region or not region.strip():
            raise StorageConfigurationError("S3 object storage requires QOSHNI_OBJECT_STORAGE_REGION.")

        try:
            import boto3
            from botocore.config import Config
        except ImportError as error:
            raise StorageConfigurationError("S3 object storage dependencies are unavailable.") from error

        session = boto3.session.Session(
            aws_access_key_id=access_key.get_secret_value(),
            aws_secret_access_key=secret_key.get_secret_value(),
            region_name=region.strip(),
        )
        client = session.client(
            "s3",
            endpoint_url=settings.object_storage_endpoint,
            config=Config(
                connect_timeout=10,
                read_timeout=60,
                retries={"max_attempts": 2, "mode": "standard"},
            ),
        )
        return S3ObjectStorage(client=client, bucket=bucket.strip())

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
