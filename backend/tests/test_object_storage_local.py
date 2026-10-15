"""Local filesystem object storage adapter tests."""

from __future__ import annotations

import os
import tempfile
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
    with pytest.raises(StorageKeyInvalidError):
        validate_storage_object_key("private/./nested")
    with pytest.raises(StorageKeyInvalidError):
        validate_storage_object_key("")


def _symlinks_supported() -> bool:
    with tempfile.TemporaryDirectory() as directory:
        probe_root = Path(directory)
        target = probe_root / "target.txt"
        link = probe_root / "link.txt"
        target.write_text("probe", encoding="utf-8")
        try:
            os.symlink(target, link)
            link.unlink()
            return True
        except OSError:
            return False


symlink_required = pytest.mark.skipif(
    not _symlinks_supported(),
    reason="Platform cannot create symbolic links (common on Windows without Developer Mode).",
)


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


@symlink_required
def test_rejects_directory_symlink_escaping_root(tmp_path: Path) -> None:
    external_dir = tmp_path / "outside"
    external_dir.mkdir()
    secret = external_dir / "secret.txt"
    secret.write_bytes(b"OUTSIDE-SECRET")

    store = LocalFilesystemStorage(root_directory=tmp_path / "store", bucket="private")
    trap = store._root / "trap"
    trap.parent.mkdir(parents=True, exist_ok=True)
    os.symlink(external_dir, trap, target_is_directory=True)

    with pytest.raises(StorageKeyInvalidError):
        store.put("trap/secret.txt", b"evil")
    with pytest.raises(StorageKeyInvalidError):
        store.read("trap/secret.txt")
    assert secret.read_bytes() == b"OUTSIDE-SECRET"


@symlink_required
def test_rejects_file_symlink_to_outside_path(tmp_path: Path) -> None:
    external = tmp_path / "outside.txt"
    external.write_bytes(b"OUTSIDE-SECRET")

    store = LocalFilesystemStorage(root_directory=tmp_path / "store", bucket="private")
    link_path = store._root / "linked-object"
    os.symlink(external, link_path)

    with pytest.raises(StorageKeyInvalidError):
        store.read("linked-object")
    with pytest.raises(StorageKeyInvalidError):
        store.put("linked-object", b"overwrite", overwrite=True)
    assert external.read_bytes() == b"OUTSIDE-SECRET"


@symlink_required
def test_meta_symlink_does_not_expose_external_content(tmp_path: Path) -> None:
    external = tmp_path / "outside-meta.txt"
    external.write_text("text/secret-outside", encoding="utf-8")

    store = LocalFilesystemStorage(root_directory=tmp_path / "store", bucket="private")
    key = "private/onboarding/doc.pdf"
    store.put(key, b"%PDF", content_type="application/pdf")

    object_path = store._root / Path(*key.split("/"))
    meta_path = store._meta_path(object_path)
    meta_path.unlink()
    os.symlink(external, meta_path)

    head = store.head(key)
    assert head.byte_size == 4
    assert head.content_type is None
    assert external.read_text(encoding="utf-8") == "text/secret-outside"


@symlink_required
def test_put_rejects_writing_through_symlink_leaf(tmp_path: Path) -> None:
    external = tmp_path / "outside.bin"
    external.write_bytes(b"ORIGINAL")

    store = LocalFilesystemStorage(root_directory=tmp_path / "store", bucket="private")
    os.symlink(external, store._root / "payload")

    with pytest.raises(StorageKeyInvalidError):
        store.put("payload", b"NEW", overwrite=True)
    assert external.read_bytes() == b"ORIGINAL"


def test_storage_root_is_outside_web_static(tmp_path: Path) -> None:
    root = tmp_path / "var" / "qoshni-object-store"
    store = LocalFilesystemStorage(root_directory=root, bucket="docs")
    key = "private/onboarding/123/object"
    store.put(key, b"secret")
    object_path = root / "docs" / "private/onboarding/123/object"
    assert object_path.is_file()
    assert "static" not in str(object_path).lower()
