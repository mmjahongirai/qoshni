"""Filesystem-backed private storage for development and automated tests only."""

from __future__ import annotations

import os
import secrets
import threading
import time
from dataclasses import dataclass, field
from pathlib import Path

from app.services.object_storage.errors import (
    StorageKeyInvalidError,
    StorageObjectAlreadyExistsError,
    StorageObjectNotFoundError,
    StorageOperationError,
)
from app.services.object_storage.keys import validate_storage_object_key
from app.services.object_storage.port import ListPrefixPage, ObjectHead

_LISTING_TTL_SECONDS = 900
_MAX_ACTIVE_LISTINGS = 32


@dataclass
class _ListingSession:
    token: str
    prefix: str
    created_at: float
    dir_stack: list[str]
    pending_files: list[str] = field(default_factory=list)
    current_relative_dir: str | None = None
    lock: threading.Lock = field(default_factory=threading.Lock)


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
        self._listing_sessions: dict[str, _ListingSession] = {}
        self._listing_sessions_lock = threading.Lock()
        self.listing_scandir_calls = 0

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

    def _purge_listing_sessions(self) -> None:
        now = time.monotonic()
        with self._listing_sessions_lock:
            expired = [
                token
                for token, session in self._listing_sessions.items()
                if now - session.created_at > _LISTING_TTL_SECONDS
            ]
            for token in expired:
                del self._listing_sessions[token]
            while len(self._listing_sessions) > _MAX_ACTIVE_LISTINGS:
                oldest = min(self._listing_sessions.values(), key=lambda item: item.created_at)
                del self._listing_sessions[oldest.token]

    def _resolve_prefix_directory(self, prefix: str) -> str | None:
        safe_prefix = validate_storage_object_key(prefix.rstrip("/"))
        prefix_segments = [segment for segment in safe_prefix.split("/") if segment]
        current = self._root
        for segment in prefix_segments:
            current = current / segment
            if current.is_symlink():
                raise StorageKeyInvalidError("Storage object path must not include a symbolic link.")
            if not current.is_dir():
                return None
        return safe_prefix

    def _scandir_sorted(self, directory: Path) -> list[os.DirEntry]:
        self.listing_scandir_calls += 1
        try:
            return sorted(os.scandir(directory), key=lambda entry: entry.name)
        except OSError as error:
            raise StorageOperationError("Failed to list storage objects.") from error

    def _maybe_object_key(self, relative_dir: str, filename: str) -> str | None:
        if filename.endswith(".meta"):
            return None
        if filename.startswith(".") and ".tmp-" in filename:
            return None
        key = f"{relative_dir}/{filename}" if relative_dir else filename
        object_path = self._root / Path(*key.split("/"))
        if object_path.is_symlink() or not object_path.is_file():
            return None
        try:
            return validate_storage_object_key(key)
        except StorageKeyInvalidError:
            return None

    def _listing_session_for_request(
        self,
        *,
        prefix: str,
        cursor: str | None,
    ) -> _ListingSession:
        self._purge_listing_sessions()
        if cursor is None:
            start_prefix = self._resolve_prefix_directory(prefix)
            if start_prefix is None:
                token = secrets.token_urlsafe(32)
                session = _ListingSession(
                    token=token,
                    prefix=prefix.rstrip("/"),
                    created_at=time.monotonic(),
                    dir_stack=[],
                )
                with self._listing_sessions_lock:
                    self._listing_sessions[token] = session
                return session
            token = secrets.token_urlsafe(32)
            session = _ListingSession(
                token=token,
                prefix=prefix.rstrip("/"),
                created_at=time.monotonic(),
                dir_stack=[start_prefix],
            )
            with self._listing_sessions_lock:
                self._listing_sessions[token] = session
            return session

        with self._listing_sessions_lock:
            session = self._listing_sessions.get(cursor)
        if session is None:
            raise StorageOperationError("Listing cursor is invalid or expired.")
        if session.prefix != prefix.rstrip("/"):
            raise StorageOperationError("Listing cursor is invalid or expired.")
        if time.monotonic() - session.created_at > _LISTING_TTL_SECONDS:
            with self._listing_sessions_lock:
                self._listing_sessions.pop(cursor, None)
            raise StorageOperationError("Listing cursor is invalid or expired.")
        return session

    def _collect_listing_page(self, session: _ListingSession, *, limit: int) -> tuple[tuple[str, ...], bool]:
        keys: list[str] = []
        with session.lock:
            while len(keys) < limit:
                if session.pending_files:
                    filename = session.pending_files.pop(0)
                    parent = session.current_relative_dir or session.prefix
                    key = self._maybe_object_key(parent, filename)
                    if key is not None:
                        keys.append(key)
                    if not session.pending_files:
                        session.current_relative_dir = None
                    continue

                if not session.dir_stack:
                    return tuple(keys), True

                relative_dir = session.dir_stack.pop()
                directory = self._root / Path(*relative_dir.split("/"))
                if directory.is_symlink() or not directory.is_dir():
                    continue

                entries = self._scandir_sorted(directory)
                subdirectories: list[str] = []
                files: list[str] = []
                for entry in entries:
                    if entry.is_symlink():
                        continue
                    if entry.is_dir(follow_symlinks=False):
                        if entry.name == self._SCRATCH_DIR_NAME:
                            continue
                        subdirectories.append(entry.name)
                    elif entry.is_file(follow_symlinks=False):
                        files.append(entry.name)

                for name in reversed(subdirectories):
                    session.dir_stack.append(f"{relative_dir}/{name}")

                if files:
                    session.current_relative_dir = relative_dir
                    session.pending_files = files
                    filename = session.pending_files.pop(0)
                    key = self._maybe_object_key(relative_dir, filename)
                    if key is not None:
                        keys.append(key)
                    if not session.pending_files:
                        session.current_relative_dir = None

            return tuple(keys), False

    def list_prefix(
        self,
        prefix: str,
        *,
        limit: int = 500,
        cursor: str | None = None,
    ) -> ListPrefixPage:
        if limit < 1:
            raise StorageKeyInvalidError("Listing limit must be positive.")

        session = self._listing_session_for_request(prefix=prefix, cursor=cursor)
        if cursor is None:
            resolved = self._resolve_prefix_directory(prefix)
            if resolved is None:
                with self._listing_sessions_lock:
                    self._listing_sessions.pop(session.token, None)
                return ListPrefixPage(keys=(), next_cursor=None)

        page_keys, exhausted = self._collect_listing_page(session, limit=limit)
        if exhausted:
            with self._listing_sessions_lock:
                self._listing_sessions.pop(session.token, None)
            return ListPrefixPage(keys=page_keys, next_cursor=None)

        session.created_at = time.monotonic()
        return ListPrefixPage(keys=page_keys, next_cursor=session.token)
