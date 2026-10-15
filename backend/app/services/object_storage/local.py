"""Filesystem-backed private storage for development and automated tests only."""

from __future__ import annotations

import os
import secrets
from pathlib import Path

from app.services.object_storage.errors import (
    StorageKeyInvalidError,
    StorageObjectAlreadyExistsError,
    StorageObjectNotFoundError,
    StorageOperationError,
)
from app.services.object_storage.keys import validate_storage_object_key
from app.services.object_storage.port import ListPrefixPage, ObjectHead


class LocalFilesystemStorage:
    """Store objects under a private root directory (never web-served)."""

    _SCRATCH_DIR_NAME = ".part-uploads"

    def __init__(self, *, root_directory: Path, bucket: str | None = None) -> None:
        bucket_part = (bucket or "default").strip().strip("/")
        if not bucket_part or ".." in bucket_part.split("/"):
            raise StorageKeyInvalidError("Local storage bucket name is invalid.")
        self._root = (root_directory / bucket_part).resolve()
        self._root.mkdir(parents=True, exist_ok=True)
        self._scratch_dir = self._root / self._SCRATCH_DIR_NAME
        self._scratch_dir.mkdir(exist_ok=True)

    def _object_path(self, key: str) -> Path:
        safe_key = validate_storage_object_key(key)
        root = self._root
        segments = [segment for segment in safe_key.split("/") if segment]
        if not segments:
            raise StorageKeyInvalidError("Storage object key must be non-empty and trimmed.")

        current = root
        last_index = len(segments) - 1
        for index, segment in enumerate(segments):
            if segment in (".", ".."):
                raise StorageKeyInvalidError("Storage object key must not contain parent segments.")
            current = current / segment
            if current.is_symlink():
                raise StorageKeyInvalidError("Storage object path must not include a symbolic link.")
            if current.exists() and not current.is_dir() and index != last_index:
                raise StorageKeyInvalidError("Storage object key is not a valid path.")

        try:
            current.relative_to(root)
        except ValueError as error:
            raise StorageKeyInvalidError("Storage object key escapes the private root.") from error
        return current

    def _meta_path(self, object_path: Path) -> Path:
        return object_path.with_suffix(object_path.suffix + ".meta")

    def _ensure_parent_directories(self, destination: Path) -> None:
        root = self._root
        if destination.parent == root:
            return
        relative_parent = destination.parent.relative_to(root)
        current = root
        for segment in relative_parent.parts:
            current = current / segment
            if current.is_symlink():
                raise StorageKeyInvalidError("Storage object path must not include a symbolic link.")
            if not current.exists():
                current.mkdir(mode=0o700, exist_ok=False)

    def _assert_regular_object_file(self, path: Path) -> None:
        if path.is_symlink():
            raise StorageObjectNotFoundError("Storage object not found.")
        if not path.is_file():
            raise StorageObjectNotFoundError("Storage object not found.")

    def _read_meta_content_type(self, object_path: Path) -> str | None:
        meta = self._meta_path(object_path)
        if meta.is_symlink() or not meta.is_file():
            return None
        try:
            return meta.read_text(encoding="utf-8").strip() or None
        except OSError as error:
            raise StorageOperationError("Failed to read object metadata.") from error

    def _write_meta_content_type(self, object_path: Path, content_type: str | None) -> None:
        meta = self._meta_path(object_path)
        if meta.is_symlink():
            raise StorageOperationError("Failed to store object metadata.")
        try:
            if content_type:
                meta.write_text(content_type.strip(), encoding="utf-8")
            elif meta.exists():
                meta.unlink(missing_ok=True)
        except OSError as error:
            raise StorageOperationError("Failed to store object metadata.") from error

    def put(
        self,
        key: str,
        data: bytes,
        *,
        content_type: str | None = None,
        overwrite: bool = False,
    ) -> None:
        destination = self._object_path(key)
        if destination.exists():
            if destination.is_symlink():
                raise StorageKeyInvalidError("Storage object path must not include a symbolic link.")
            if not overwrite:
                raise StorageObjectAlreadyExistsError("Storage object already exists.")

        self._ensure_parent_directories(destination)
        temp_path = self._scratch_dir / f".{os.getpid()}.{secrets.token_hex(16)}.part"
        try:
            with open(temp_path, "xb") as handle:
                handle.write(data)
                handle.flush()
                os.fsync(handle.fileno())
            destination = self._object_path(key)
            if destination.exists() and destination.is_symlink():
                raise StorageKeyInvalidError("Storage object path must not include a symbolic link.")
            if destination.exists() and not overwrite:
                raise StorageObjectAlreadyExistsError("Storage object already exists.")
            os.replace(temp_path, destination)
            self._write_meta_content_type(destination, content_type)
        except FileExistsError as error:
            temp_path.unlink(missing_ok=True)
            raise StorageObjectAlreadyExistsError("Storage object already exists.") from error
        except OSError as error:
            temp_path.unlink(missing_ok=True)
            raise StorageOperationError("Failed to store object.") from error

    def head(self, key: str) -> ObjectHead:
        destination = self._object_path(key)
        self._assert_regular_object_file(destination)
        content_type = self._read_meta_content_type(destination)
        try:
            byte_size = destination.stat().st_size
        except OSError as error:
            raise StorageOperationError("Failed to read object metadata.") from error
        return ObjectHead(byte_size=byte_size, content_type=content_type)

    def read(self, key: str) -> bytes:
        destination = self._object_path(key)
        self._assert_regular_object_file(destination)
        try:
            with open(destination, "rb") as handle:
                return handle.read()
        except OSError as error:
            raise StorageOperationError("Failed to read object.") from error

    def delete(self, key: str) -> None:
        try:
            destination = self._object_path(key)
        except StorageKeyInvalidError:
            return
        if destination.is_symlink():
            destination.unlink(missing_ok=True)
            return
        if destination.is_file():
            destination.unlink(missing_ok=True)
        meta = self._meta_path(destination)
        if meta.is_symlink() or meta.is_file():
            meta.unlink(missing_ok=True)

    def list_prefix(
        self,
        prefix: str,
        *,
        limit: int = 500,
        cursor: str | None = None,
    ) -> ListPrefixPage:
        safe_prefix = validate_storage_object_key(prefix.rstrip("/"))
        prefix_segments = [segment for segment in safe_prefix.split("/") if segment]
        current = self._root
        for segment in prefix_segments:
            current = current / segment
            if current.is_symlink():
                raise StorageKeyInvalidError("Storage object path must not include a symbolic link.")
            if not current.is_dir():
                return ListPrefixPage(keys=(), next_cursor=None)

        discovered: list[str] = []
        for dirpath, dirnames, filenames in os.walk(current, topdown=True, followlinks=False):
            dirnames[:] = [name for name in dirnames if name != self._SCRATCH_DIR_NAME]
            relative_dir = Path(dirpath).relative_to(self._root)
            for filename in filenames:
                if filename.endswith(".meta"):
                    continue
                if filename.startswith(".") and ".tmp-" in filename:
                    continue
                object_path = self._root / relative_dir / filename
                if object_path.is_symlink() or not object_path.is_file():
                    continue
                key_segments = (*relative_dir.parts, filename)
                key = "/".join(key_segments)
                try:
                    validate_storage_object_key(key)
                except StorageKeyInvalidError:
                    continue
                discovered.append(key)

        discovered.sort()
        start_index = 0
        if cursor:
            while start_index < len(discovered) and discovered[start_index] <= cursor:
                start_index += 1
        page = discovered[start_index : start_index + limit]
        next_cursor = None
        if page and start_index + limit < len(discovered):
            next_cursor = page[-1]
        return ListPrefixPage(keys=tuple(page), next_cursor=next_cursor)
