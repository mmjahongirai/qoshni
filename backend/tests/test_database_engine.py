"""Tests for SQLAlchemy engine and session lifecycle (no live database)."""

import threading
from collections.abc import Generator
from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.database import (
    DatabaseConfigurationConflictError,
    DatabaseNotConfiguredError,
    create_engine_from_settings,
    dispose_engine,
    get_db_session,
    get_engine,
    get_session_factory,
    reset_database_state,
)


@pytest.fixture(autouse=True)
def reset_state() -> Generator[None, None, None]:
    get_settings.cache_clear()
    reset_database_state()
    yield
    get_settings.cache_clear()
    reset_database_state()


def test_application_startup_does_not_create_engine() -> None:
    with patch("app.core.database.create_engine") as create_engine_mock:
        from app.main import create_app

        application = create_app()
        assert application is not None
        create_engine_mock.assert_not_called()


def test_get_engine_returns_none_when_database_is_not_configured() -> None:
    settings = Settings()

    assert get_engine(settings=settings) is None
    assert get_session_factory(settings=settings) is None


def test_create_engine_from_settings_raises_when_url_missing() -> None:
    settings = Settings()

    with pytest.raises(DatabaseNotConfiguredError):
        create_engine_from_settings(settings)


def test_get_engine_uses_settings_and_caches_engine(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    sample_url = "postgresql+psycopg://postgres:secret-pass@localhost:5432/qoshni"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", sample_url)
    settings = Settings()
    mock_engine = MagicMock(name="engine")

    with patch(
        "app.core.database.create_engine",
        return_value=mock_engine,
    ) as create_engine_mock:
        first = get_engine(settings=settings)
        second = get_engine(settings=settings)

    assert first is mock_engine
    assert second is mock_engine
    create_engine_mock.assert_called_once()
    _args, kwargs = create_engine_mock.call_args
    assert kwargs["pool_pre_ping"] is True
    assert kwargs["pool_size"] == settings.database_pool_size
    assert "secret-pass" not in str(create_engine_mock.call_args)


def test_get_engine_rejects_conflicting_settings_without_exposing_credentials(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    first_url = "postgresql+psycopg://postgres:secret-pass@localhost:5432/qoshni"
    second_url = "postgresql+psycopg://postgres:other-pass@localhost:5432/other"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", first_url)
    first_settings = Settings()
    monkeypatch.setenv("QOSHNI_DATABASE_URL", second_url)
    second_settings = Settings()
    mock_engine = MagicMock(name="engine")

    with patch("app.core.database.create_engine", return_value=mock_engine):
        get_engine(settings=first_settings)
        with pytest.raises(DatabaseConfigurationConflictError) as exc_info:
            get_engine(settings=second_settings)

    error_text = str(exc_info.value)
    assert "secret-pass" not in error_text
    assert "other-pass" not in error_text
    assert "dispose_engine()" in error_text


def test_get_engine_allows_reconfiguration_after_dispose(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    first_url = "postgresql+psycopg://postgres:secret-pass@localhost:5432/qoshni"
    second_url = "postgresql+psycopg://postgres:other-pass@localhost:5432/other"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", first_url)
    first_settings = Settings()
    monkeypatch.setenv("QOSHNI_DATABASE_URL", second_url)
    second_settings = Settings()
    first_engine = MagicMock(name="engine-one")
    second_engine = MagicMock(name="engine-two")

    with patch(
        "app.core.database.create_engine",
        side_effect=[first_engine, second_engine],
    ) as create_engine_mock:
        assert get_engine(settings=first_settings) is first_engine
        dispose_engine()
        assert get_engine(settings=second_settings) is second_engine

    assert create_engine_mock.call_count == 2


def test_concurrent_get_engine_initializes_once(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    sample_url = "postgresql+psycopg://postgres:secret-pass@localhost:5432/qoshni"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", sample_url)
    settings = Settings()
    mock_engine = MagicMock(name="engine")
    barrier = threading.Barrier(2)
    engines: list[object] = []

    def worker() -> None:
        barrier.wait()
        engines.append(get_engine(settings=settings))

    with patch("app.core.database.create_engine", return_value=mock_engine) as create_engine_mock:
        threads = [threading.Thread(target=worker) for _ in range(2)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()

    assert len(engines) == 2
    assert engines[0] is mock_engine
    assert engines[1] is mock_engine
    create_engine_mock.assert_called_once()


def test_get_db_session_closes_session(monkeypatch: pytest.MonkeyPatch) -> None:
    sample_url = "postgresql+psycopg://postgres:secret-pass@localhost:5432/qoshni"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", sample_url)
    settings = Settings()

    mock_session = MagicMock(spec=Session)
    mock_factory = MagicMock(return_value=mock_session)

    with patch("app.core.database.get_session_factory", return_value=mock_factory):
        generator = get_db_session(settings=settings)
        session = next(generator)
        generator.close()

    assert session is mock_session
    mock_factory.assert_called_once()
    mock_session.close.assert_called_once()


def test_get_db_session_closes_session_when_consumer_raises(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    sample_url = "postgresql+psycopg://postgres:secret-pass@localhost:5432/qoshni"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", sample_url)
    settings = Settings()

    mock_session = MagicMock(spec=Session)
    mock_factory = MagicMock(return_value=mock_session)

    with patch("app.core.database.get_session_factory", return_value=mock_factory):
        generator = get_db_session(settings=settings)
        next(generator)
        with pytest.raises(RuntimeError, match="consumer failed"):
            generator.throw(RuntimeError("consumer failed"))

    mock_session.close.assert_called_once()


def test_get_db_session_raises_when_database_not_configured() -> None:
    settings = Settings()
    generator = get_db_session(settings=settings)

    with pytest.raises(DatabaseNotConfiguredError):
        next(generator)


def test_dispose_engine_resets_cached_state(monkeypatch: pytest.MonkeyPatch) -> None:
    sample_url = "postgresql+psycopg://postgres:secret-pass@localhost:5432/qoshni"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", sample_url)
    settings = Settings()
    first_engine = MagicMock(name="engine-one")
    second_engine = MagicMock(name="engine-two")

    with patch(
        "app.core.database.create_engine",
        side_effect=[first_engine, second_engine],
    ) as create_engine_mock:
        assert get_engine(settings=settings) is first_engine
        dispose_engine()
        assert get_engine(settings=settings) is second_engine

    first_engine.dispose.assert_called_once()
    assert create_engine_mock.call_count == 2


def test_lifespan_shutdown_disposes_engine_without_creating_on_startup() -> None:
    with patch("app.core.database.create_engine") as create_engine_mock:
        with patch("app.main.dispose_engine") as dispose_engine_mock:
            from app.main import create_app

            application = create_app()
            with TestClient(application):
                pass

    create_engine_mock.assert_not_called()
    dispose_engine_mock.assert_called_once()
