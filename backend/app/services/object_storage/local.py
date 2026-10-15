"""Filesystem-backed private storage for development and automated tests only."""

from __future__ import annotations

import os
from pathlib import Path

from app.services.object_storage.errors import (
    StorageKeyInvalidError,
    StorageObjectAlreadyExistsError,
    StorageObjectNotFoundError,
    StorageOperationError,
)
from app.services.object_storage.keys import validate_storage_object_key
from app.services.object_storage.port import ObjectHead


class LocalFilesystemStorage:
    """Store objects under a private root directory (never web-served)."""

    def __init__(self, *, root_directory: Path, bucket: str | None = None) -> None:
        bucket_part = (bucket or "default").strip().strip("/")
        if not bucket_part or ".." in bucket_part.split("/"):
            raise StorageKeyInvalidError("Local storage bucket name is invalid.")
        self._root = (root_directory / bucket_part).resolve()
        self._root.mkdir(parents=True, exist_ok=True)

    def _object_path(self, key: str) -> Path:
        safe_key = validate_storage_object_key(key)
        candidate = (self._root / Path(*safe_key.split("/"))).resolve()
        root = self._root.resolve()
        if os.path.commonpath([str(root), str(candidate)]) != str(root):
            raise StorageKeyInvalidError("Storage object key escapes the private root.")
        return candidate

    def _meta_path(self, object_path: Path) -> Path:
        return object_path.with_suffix(object_path.suffix + ".meta")

    def put(
        self,
        key: str,
        data: bytes,
        *,
        content_type: str | None = None,
        overwrite: bool = False,
    ) -> None:
        destination = self._object_path(key)
        if destination.exists() and not overwrite:
            raise StorageObjectAlreadyExistsError("Storage object already exists.")

        destination.parent.mkdir(parents=True, exist_ok=True)
        temp_path = destination.with_name(f".{destination.name}.tmp-{os.getpid()}")
        try:
            with open(temp_path, "wb") as handle:
                handle.write(data)
                handle.flush()
                os.fsync(handle.fileno())
            os.replace(temp_path, destination)
            meta = self._meta_path(destination)
            if content_type:
                meta.write_text(content_type.strip(), encoding="utf-8")
            elif meta.exists():
                meta.unlink(missing_ok=True)
        except OSError as error:
            temp_path.unlink(missing_ok=True)
            raise StorageOperationError("Failed to store object.") from error

    def head(self, key: str) -> ObjectHead:
        destination = self._object_path(key)
        if not destination.is_file():
            raise StorageObjectNotFoundError("Storage object not found.")
        content_type = None
        meta = self._meta_path(destination)
        if meta.is_file():
            content_type = meta.read_text(encoding="utf-8").strip() or None
        return ObjectHead(byte_size=destination.stat().st_size, content_type=content_type)

    def read(self, key: str) -> bytes:
        destination = self._object_path(key)
        if not destination.is_file():
            raise StorageObjectNotFoundError("Storage object not found.")
        try:
            return destination.read_bytes()
        except OSError as error:
            raise StorageOperationError("Failed to read object.") from error

    def delete(self, key: str) -> None:
        try:
            destination = self._object_path(key)
        except StorageKeyInvalidError:
            return
        if destination.is_file():
            destination.unlink(missing_ok=True)
        meta = self._meta_path(destination)
        meta.unlink(missing_ok=True)
