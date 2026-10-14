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
    database_pool_size: int = Field(default=5, ge=1)
    database_max_overflow: int = Field(default=10, ge=0)
    database_pool_timeout: int = Field(default=30, ge=1)
    database_pool_recycle: int = Field(default=1800, ge=0)
    database_echo: bool = Field(
        default=False,
        description="SQLAlchemy SQL echo for local debugging only; keep disabled in production.",
    )
    auth_otp_ttl_seconds: int = Field(default=300, ge=60, le=900)
    auth_otp_max_attempts: int = Field(default=5, ge=1, le=10)
    auth_otp_code_length: int = Field(default=6, ge=4, le=8)
    auth_access_token_ttl_seconds: int = Field(default=900, ge=60, le=3600)
    auth_refresh_token_ttl_seconds: int = Field(
        default=30 * 24 * 3600,
        ge=3600,
        le=90 * 24 * 3600,
    )
    auth_otp_request_max_per_window: int = Field(default=5, ge=1, le=20)
    auth_otp_request_window_seconds: int = Field(default=900, ge=60, le=86400)
    auth_secret_digest_key: SecretStr | None = Field(
        default=None,
        description=(
            "Server-only HMAC key for OTP and refresh-token digests. Required "
            "before authentication endpoints are enabled; never ship to clients."
        ),
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
