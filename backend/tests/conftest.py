"""Shared pytest configuration for backend tests."""

from __future__ import annotations

import os
from collections.abc import Generator

import pytest

from app.core.config import get_settings

_QOSHNI_ENV_PREFIX = "QOSHNI_"


@pytest.fixture(autouse=True)
def _isolate_process_settings_env(monkeypatch: pytest.MonkeyPatch) -> Generator[None, None, None]:
    """Drop shell/runtime env vars so default-config tests stay isolated.

    Individual tests may still set ``QOSHNI_*`` via ``monkeypatch.setenv`` in
    fixtures or test bodies; those overrides apply after this cleanup.
    """

    for name in list(os.environ):
        if name.startswith(_QOSHNI_ENV_PREFIX) or name == "DATABASE_URL":
            monkeypatch.delenv(name, raising=False)
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()
