"""Environment-based application configuration."""

from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic import AliasChoices, Field, SecretStr, field_validator, model_validator
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
    object_storage_provider: Literal["local", "s3"] | None = None
    object_storage_bucket: str | None = None
    object_storage_region: str | None = None
    object_storage_endpoint: str | None = None
    object_storage_access_key_id: SecretStr | None = None
    object_storage_secret_access_key: SecretStr | None = None
    onboarding_document_max_bytes: int = Field(default=10 * 1024 * 1024, ge=1)
    onboarding_document_upload_url_ttl_seconds: int = Field(default=900, ge=60)
    object_storage_local_root: Path | None = None

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

    @model_validator(mode="after")
    def validate_object_storage_policy(self) -> "Settings":
        if self.object_storage_provider == "local" and self.environment == "production":
            raise ValueError(
                "Local object storage cannot be enabled when QOSHNI_ENVIRONMENT is production.",
            )
        if self.object_storage_provider == "s3":
            raise ValueError(
                "S3 object storage provider is configured but no adapter is available yet.",
            )
        return self

    @property
    def database_configured(self) -> bool:
        return self.database_url is not None


@lru_cache
def get_settings() -> Settings:
    """Return the cached application settings."""

    return Settings()
