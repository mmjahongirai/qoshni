"""Private object storage dependency."""

from __future__ import annotations

from fastapi import Depends, HTTPException

from app.core.config import Settings, get_settings
from app.services.object_storage.errors import StorageConfigurationError
from app.services.object_storage.factory import create_object_storage
from app.services.object_storage.port import StoragePort


def get_object_storage(settings: Settings = Depends(get_settings)) -> StoragePort:
    try:
        return create_object_storage(settings)
    except StorageConfigurationError as error:
        raise HTTPException(status_code=503, detail="Object storage is unavailable.") from error
