"""Tests for optional database configuration."""

import pytest
from pydantic import ValidationError

from app.core.config import Settings, get_settings, redact_database_url


@pytest.fixture(autouse=True)
def clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def test_database_url_defaults_to_none(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("QOSHNI_DATABASE_URL", raising=False)
    monkeypatch.delenv("DATABASE_URL", raising=False)

    settings = Settings()

    assert settings.database_url is None
    assert settings.database_configured is False


def test_database_url_reads_from_qoshni_environment(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    sample_url = (
        "postgresql+psycopg://postgres:secret-pass@db.example.supabase.co:5432/postgres"
    )
    monkeypatch.setenv("QOSHNI_DATABASE_URL", sample_url)

    settings = Settings()

    assert settings.database_configured is True
    assert settings.database_url is not None
    assert settings.database_url.get_secret_value() == sample_url


def test_database_url_reads_from_database_url_alias(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    sample_url = "postgresql+psycopg://postgres:secret-pass@localhost:5432/qoshni"
    monkeypatch.delenv("QOSHNI_DATABASE_URL", raising=False)
    monkeypatch.setenv("DATABASE_URL", sample_url)

    settings = Settings()

    assert settings.database_url is not None
    assert settings.database_url.get_secret_value() == sample_url


def test_invalid_database_url_error_does_not_expose_password(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("QOSHNI_DATABASE_URL", "postgres:super-secret@not-a-url")

    with pytest.raises(ValidationError) as exc_info:
        Settings()

    error_text = str(exc_info.value)
    assert "super-secret" not in error_text


def test_redact_database_url_masks_password() -> None:
    redacted = redact_database_url(
        "postgresql+psycopg://postgres:super-secret@db.example.supabase.co:5432/postgres",
    )

    assert "super-secret" not in redacted
    assert "postgres:***" in redacted or ":***@" in redacted
