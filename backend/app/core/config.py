"""Environment-based application configuration."""

from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic import AliasChoices, Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic_core import PydanticCustomError
from sqlalchemy.engine import make_url


_ENV_FILE = Path(__file__).resolve().parents[2] / ".env"


def redact_database_url(url: str) -> str:
    """Return a database URL with credentials masked for logs and errors."""

    try:
        parsed = make_url(url)
        if parsed.password is not None:
            return str(parsed.set(password="***"))
        return str(parsed)
    except Exception:
        if "@" in url and "://" in url:
            scheme, remainder = url.split("://", maxsplit=1)
            if "@" in remainder and ":" in remainder.split("@", maxsplit=1)[0]:
                userinfo, hostpart = remainder.rsplit("@", maxsplit=1)
                user = userinfo.split(":", maxsplit=1)[0]
                return f"{scheme}://{user}:***@{hostpart}"
        return "<redacted-database-url>"


class Settings(BaseSettings):
    """Runtime settings with safe, non-secret defaults."""

    app_name: str = "QO'SHNI Backend"
    service_name: str = "qoshni-backend"
    app_version: str = "0.1.0"
    api_v1_prefix: str = "/api/v1"
    environment: Literal["development", "staging", "production"] = "development"
    database_url: SecretStr | None = Field(
        default=None,
        validation_alias=AliasChoices("QOSHNI_DATABASE_URL", "DATABASE_URL"),
    )

    model_config = SettingsConfigDict(
        env_file=_ENV_FILE,
        env_prefix="QOSHNI_",
        extra="ignore",
        populate_by_name=True,
        hide_input_in_errors=True,
    )

    @field_validator("database_url", mode="before")
    @classmethod
    def validate_database_url(cls, value: object) -> SecretStr | None:
        if value is None or value == "":
            return None
        if isinstance(value, SecretStr):
            raw = value.get_secret_value()
        else:
            raw = str(value)

        try:
            make_url(raw)
        except Exception:
            raise PydanticCustomError(
                "database_url_invalid",
                "Invalid database URL format: {safe_url}",
                {"safe_url": redact_database_url(raw)},
            )

        return SecretStr(raw)

    @property
    def database_configured(self) -> bool:
        return self.database_url is not None


@lru_cache
def get_settings() -> Settings:
    """Return the cached application settings."""

    return Settings()
