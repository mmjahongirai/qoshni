"""Verify pytest isolates process env from default Settings() tests."""

from app.core.config import Settings


def test_process_env_isolated_for_default_settings() -> None:
    """Autouse conftest fixture clears shell ``QOSHNI_*`` before each test."""

    settings = Settings()
    assert settings.database_configured is False
    assert settings.auth_secret_digest_key is None
    assert settings.object_storage_provider is None
    assert settings.malware_scanner_provider is None
