"""Helpers for Alembic migration commands."""

from app.core.config import get_settings


def get_migration_database_url() -> str:
    """Return the configured database URL for Alembic CLI commands."""

    settings = get_settings()
    if not settings.database_configured or settings.database_url is None:
        raise SystemExit(
            "Database URL is not configured. Set QOSHNI_DATABASE_URL before "
            "running Alembic.",
        )

    return settings.database_url.get_secret_value()
