"""SQLAlchemy engine and session lifecycle for optional database access."""

import threading
from collections.abc import Generator
from typing import Annotated

from fastapi import Depends
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import Settings, get_settings

_init_lock = threading.RLock()
_engine: Engine | None = None
_session_factory: sessionmaker[Session] | None = None
_engine_fingerprint: tuple[object, ...] | None = None


class DatabaseNotConfiguredError(RuntimeError):
    """Raised when database access is requested without configuration."""


class DatabaseConfigurationConflictError(RuntimeError):
    """Raised when database settings conflict with an initialized engine."""


def _database_engine_fingerprint(settings: Settings) -> tuple[object, ...]:
    if settings.database_url is None:
        raise DatabaseNotConfiguredError("Database URL is not configured.")

    return (
        settings.database_url.get_secret_value(),
        settings.database_pool_size,
        settings.database_max_overflow,
        settings.database_pool_timeout,
        settings.database_pool_recycle,
        settings.database_echo,
    )


def _validate_engine_settings(resolved_settings: Settings) -> None:
    if _engine is None or _engine_fingerprint is None:
        return

    fingerprint = _database_engine_fingerprint(resolved_settings)
    if fingerprint != _engine_fingerprint:
        raise DatabaseConfigurationConflictError(
            "Database engine is already initialized with different settings. "
            "Call dispose_engine() before applying new database configuration.",
        )


def create_engine_from_settings(settings: Settings) -> Engine:
    """Build a synchronous SQLAlchemy engine from application settings."""

    if settings.database_url is None:
        raise DatabaseNotConfiguredError("Database URL is not configured.")

    return create_engine(
        settings.database_url.get_secret_value(),
        pool_pre_ping=True,
        pool_size=settings.database_pool_size,
        max_overflow=settings.database_max_overflow,
        pool_timeout=settings.database_pool_timeout,
        pool_recycle=settings.database_pool_recycle,
        echo=settings.database_echo,
    )


def get_engine(*, settings: Settings | None = None) -> Engine | None:
    """Return a cached engine, or ``None`` when no database URL is configured."""

    global _engine, _engine_fingerprint

    resolved_settings = settings or get_settings()
    if not resolved_settings.database_configured:
        return None

    with _init_lock:
        _validate_engine_settings(resolved_settings)
        if _engine is None:
            _engine = create_engine_from_settings(resolved_settings)
            _engine_fingerprint = _database_engine_fingerprint(resolved_settings)

        return _engine


def get_session_factory(
    *,
    settings: Settings | None = None,
) -> sessionmaker[Session] | None:
    """Return a cached session factory bound to the application engine."""

    global _session_factory

    with _init_lock:
        engine = get_engine(settings=settings)
        if engine is None:
            return None

        if _session_factory is None:
            _session_factory = sessionmaker(
                bind=engine,
                autoflush=False,
                autocommit=False,
                expire_on_commit=False,
            )

        return _session_factory


def get_db_session(
    *,
    settings: Settings | None = None,
) -> Generator[Session, None, None]:
    """Yield a database session and always close it afterward."""

    session_factory = get_session_factory(settings=settings)
    if session_factory is None:
        raise DatabaseNotConfiguredError("Database URL is not configured.")

    session = session_factory()
    try:
        yield session
    finally:
        session.close()


def get_db() -> Generator[Session, None, None]:
    """FastAPI dependency that provides a request-scoped database session."""

    yield from get_db_session()


DbSession = Annotated[Session, Depends(get_db)]


def dispose_engine() -> None:
    """Dispose the cached engine and reset session factory state."""

    global _engine, _session_factory, _engine_fingerprint

    with _init_lock:
        if _engine is not None:
            _engine.dispose()
            _engine = None

        _session_factory = None
        _engine_fingerprint = None


def reset_database_state() -> None:
    """Reset cached engine state (intended for tests)."""

    dispose_engine()
