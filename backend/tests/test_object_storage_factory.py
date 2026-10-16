"""Object storage settings and factory tests."""

from __future__ import annotations

from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest
from pydantic import ValidationError

from app.core.config import Settings, get_settings
from app.services.object_storage.errors import StorageConfigurationError
from app.services.object_storage.factory import create_object_storage
from app.services.object_storage.local import LocalFilesystemStorage
from app.services.object_storage.s3 import S3ObjectStorage


@pytest.fixture(autouse=True)
def _clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def test_factory_requires_provider(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("QOSHNI_OBJECT_STORAGE_PROVIDER", raising=False)
    settings = Settings()
    with pytest.raises(StorageConfigurationError):
        create_object_storage(settings)


def test_s3_provider_requires_bucket_and_credentials(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_PROVIDER", "s3")
    with pytest.raises(ValidationError):
        Settings()


def test_s3_factory_creates_adapter_with_mock_boto(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_PROVIDER", "s3")
    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_BUCKET", "docs")
    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_REGION", "auto")
    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_ACCESS_KEY_ID", "AKIAEXAMPLE")
    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_SECRET_ACCESS_KEY", "secret-value")
    settings = Settings()

    mock_client = MagicMock()
    mock_session = MagicMock()
    mock_session.client.return_value = mock_client
    with patch("boto3.session.Session", return_value=mock_session):
        backend = create_object_storage(settings)
    assert isinstance(backend, S3ObjectStorage)
    mock_session.client.assert_called_once()


def test_s3_factory_fail_closed_without_credentials(monkeypatch: pytest.MonkeyPatch) -> None:
    settings = Settings.model_construct(
        object_storage_provider="s3",
        object_storage_bucket="docs",
        object_storage_region="auto",
        environment="development",
    )
    with pytest.raises(StorageConfigurationError, match="credentials"):
        create_object_storage(settings)


def test_local_storage_in_production_rejected(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_PROVIDER", "local")
    monkeypatch.setenv("QOSHNI_ENVIRONMENT", "production")
    with pytest.raises(ValidationError):
        Settings()


def test_local_storage_requires_root(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_PROVIDER", "local")
    monkeypatch.setenv("QOSHNI_ENVIRONMENT", "development")
    settings = Settings()
    with pytest.raises(StorageConfigurationError, match="LOCAL_ROOT"):
        create_object_storage(settings)

    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_LOCAL_ROOT", str(tmp_path))
    get_settings.cache_clear()
    settings = Settings()
    backend = create_object_storage(settings)
    assert isinstance(backend, LocalFilesystemStorage)


def test_secrets_not_exposed_in_settings_repr(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_ACCESS_KEY_ID", "AKIAEXAMPLE")
    monkeypatch.setenv("QOSHNI_OBJECT_STORAGE_SECRET_ACCESS_KEY", "super-secret-value")
    settings = Settings()
    assert settings.object_storage_access_key_id is not None
    assert settings.object_storage_secret_access_key is not None
    text = repr(settings.object_storage_secret_access_key)
    assert "super-secret-value" not in text


def test_default_settings_unaffected_without_storage_env(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("QOSHNI_OBJECT_STORAGE_PROVIDER", raising=False)
    settings = Settings()
    assert settings.object_storage_provider is None
    assert settings.onboarding_document_max_bytes == 10 * 1024 * 1024
