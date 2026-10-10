"""Environment-based application configuration."""

from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


_ENV_FILE = Path(__file__).resolve().parents[2] / ".env"


class Settings(BaseSettings):
    """Runtime settings with safe, non-secret defaults."""

    app_name: str = "QO'SHNI Backend"
    service_name: str = "qoshni-backend"
    app_version: str = "0.1.0"
    api_v1_prefix: str = "/api/v1"
    environment: Literal["development", "staging", "production"] = "development"

    model_config = SettingsConfigDict(
        env_file=_ENV_FILE,
        env_prefix="QOSHNI_",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    """Return the cached application settings."""

    return Settings()
