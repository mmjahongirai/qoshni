"""Tests for Alembic environment helpers without live database access."""

from unittest.mock import patch

import pytest

from app.core.config import Settings, get_settings
from app.db.base import Base
from app.db.migration import get_migration_database_url


@pytest.fixture(autouse=True)
def clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def test_get_migration_database_url_exits_without_credentials_when_missing(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.delenv("QOSHNI_DATABASE_URL", raising=False)
    monkeypatch.delenv("DATABASE_URL", raising=False)

    with pytest.raises(SystemExit) as exc_info:
        get_migration_database_url()

    message = str(exc_info.value)
    assert "QOSHNI_DATABASE_URL" in message
    assert "secret" not in message.lower()
    assert "password" not in message.lower()


def test_get_migration_database_url_returns_configured_url(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    sample_url = "postgresql+psycopg://postgres:secret-pass@localhost:5432/qoshni"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", sample_url)

    resolved_url = get_migration_database_url()

    assert resolved_url == Settings().database_url.get_secret_value()


def test_db_metadata_import_does_not_create_engine() -> None:
    with patch("sqlalchemy.create_engine") as create_engine_mock:
        import app.db.base  # noqa: F401
        import app.db.models  # noqa: F401

    create_engine_mock.assert_not_called()
    assert Base.metadata is not None
