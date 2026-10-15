"""Local filesystem object storage adapter tests."""

from __future__ import annotations

from pathlib import Path

import pytest

from app.services.object_storage.errors import (
    StorageKeyInvalidError,
    StorageObjectAlreadyExistsError,
    StorageObjectNotFoundError,
    StorageOperationError,
)
from app.services.object_storage.keys import validate_storage_object_key
from app.services.object_storage.local import LocalFilesystemStorage


@pytest.fixture
def storage(tmp_path: Path) -> LocalFilesystemStorage:
    return LocalFilesystemStorage(root_directory=tmp_path, bucket="onboarding-private")


def test_put_read_head_delete_round_trip(storage: LocalFilesystemStorage) -> None:
    key = "private/onboarding/app/doc/file.bin"
    payload = b"pdf-bytes-not-logged"
    storage.put(key, payload, content_type="application/pdf")
    assert storage.head(key).byte_size == len(payload)
    assert storage.head(key).content_type == "application/pdf"
    assert storage.read(key) == payload
    storage.delete(key)
    with pytest.raises(StorageObjectNotFoundError):
        storage.head(key)


def test_delete_is_idempotent(storage: LocalFilesystemStorage) -> None:
    key = "private/onboarding/missing"
    storage.delete(key)
    storage.delete(key)


def test_put_refuses_overwrite_by_default(storage: LocalFilesystemStorage) -> None:
    key = "private/onboarding/duplicate"
    storage.put(key, b"a")
    with pytest.raises(StorageObjectAlreadyExistsError):
        storage.put(key, b"b")


def test_put_overwrite_replaces_bytes(storage: LocalFilesystemStorage) -> None:
    key = "private/onboarding/replace"
    storage.put(key, b"old")
    storage.put(key, b"new", overwrite=True)
    assert storage.read(key) == b"new"


def test_rejects_path_traversal_keys(storage: LocalFilesystemStorage) -> None:
    with pytest.raises(StorageKeyInvalidError):
        storage.put("../etc/passwd", b"x")
    with pytest.raises(StorageKeyInvalidError):
        storage.put("private/../escape", b"x")
    with pytest.raises(StorageKeyInvalidError):
        validate_storage_object_key("/absolute/key")


def test_atomic_write_leaves_no_partial_file_on_failure(
    storage: LocalFilesystemStorage,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    key = "private/onboarding/partial"

    def _fail_replace(*args, **kwargs):
        raise OSError("disk full")

    monkeypatch.setattr("app.services.object_storage.local.os.replace", _fail_replace)
    with pytest.raises(StorageOperationError):
        storage.put(key, b"payload")
    with pytest.raises(StorageObjectNotFoundError):
        storage.head(key)


def test_storage_root_is_outside_web_static(tmp_path: Path) -> None:
    root = tmp_path / "var" / "qoshni-object-store"
    store = LocalFilesystemStorage(root_directory=root, bucket="docs")
    key = "private/onboarding/123/object"
    store.put(key, b"secret")
    object_path = root / "docs" / "private/onboarding/123/object"
    assert object_path.is_file()
    assert "static" not in str(object_path).lower()
