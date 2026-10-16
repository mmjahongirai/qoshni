"""Storage list_prefix tests."""

from __future__ import annotations

import os
import time
import uuid
from pathlib import Path

import pytest

from app.services.object_storage.errors import StorageOperationError
from app.services.object_storage.local import LocalFilesystemStorage
from tests.support.memory_object_storage import MemoryObjectStorage


def _collect_all_local_keys(
    store: LocalFilesystemStorage,
    prefix: str,
    *,
    limit: int = 500,
) -> set[str]:
    keys: set[str] = set()
    cursor: str | None = None
    while True:
        page = store.list_prefix(prefix, limit=limit, cursor=cursor)
        keys.update(page.keys)
        if page.next_cursor is None:
            break
        cursor = page.next_cursor
    return keys


def test_memory_list_prefix_paginates() -> None:
    storage = MemoryObjectStorage()
    storage.put("private/onboarding/a/b", b"1")
    storage.put("private/onboarding/a/c", b"2")
    storage.put("private/onboarding/z/y", b"3")

    first = storage.list_prefix("private/onboarding", limit=1)
    assert len(first.keys) == 1
    second = storage.list_prefix("private/onboarding", limit=10, cursor=first.next_cursor)
    assert len(second.keys) >= 1


def test_local_list_prefix_skips_meta_and_scratch(tmp_path: Path) -> None:
    store = LocalFilesystemStorage(root_directory=tmp_path, bucket="docs")
    key = f"private/onboarding/{uuid.uuid4()}/{uuid.uuid4()}"
    store.put(key, b"payload", content_type="application/pdf")

    scratch = store._scratch_dir / "orphan.part"
    scratch.write_bytes(b"x")
    object_path = store._object_path(key)
    meta_path = store._meta_path(object_path)
    assert meta_path.is_file()

    page = store.list_prefix("private/onboarding", limit=100)
    assert key in page.keys
    assert not any(name.endswith(".meta") for name in page.keys)
    assert not any(".part-uploads" in name for name in page.keys)


@pytest.mark.skipif(not hasattr(os, "symlink"), reason="Symlinks unavailable.")
def test_local_list_prefix_skips_symlink_targets_outside_root(tmp_path: Path) -> None:
    outside = tmp_path / "outside.txt"
    outside.write_bytes(b"secret")
    store = LocalFilesystemStorage(root_directory=tmp_path / "store", bucket="docs")
    link_dir = store._root / "private/onboarding/link"
    link_dir.parent.mkdir(parents=True, exist_ok=True)
    try:
        os.symlink(outside, link_dir / "file")
    except OSError:
        pytest.skip("Cannot create symlinks on this host.")
    page = store.list_prefix("private/onboarding", limit=100)
    assert "private/onboarding/link/file" not in page.keys


def test_local_list_prefix_multipage_collects_all_objects(tmp_path: Path) -> None:
    store = LocalFilesystemStorage(root_directory=tmp_path, bucket="docs")
    expected: set[str] = set()
    for index in range(12):
        key = f"private/onboarding/app-{index:02d}/doc-{index}"
        store.put(key, b"x")
        expected.add(key)

    collected = _collect_all_local_keys(store, "private/onboarding", limit=3)
    assert collected == expected


def test_local_list_prefix_pagination_two_thousand_objects(tmp_path: Path) -> None:
    store = LocalFilesystemStorage(root_directory=tmp_path, bucket="docs")
    expected: set[str] = set()
    for index in range(2000):
        key = f"private/onboarding/{index:04d}/object"
        store.put(key, b"payload")
        expected.add(key)

    collected = _collect_all_local_keys(store, "private/onboarding", limit=500)
    assert len(collected) == 2000
    assert collected == expected


def test_local_list_prefix_incremental_avoids_full_rescan(tmp_path: Path) -> None:
    store = LocalFilesystemStorage(root_directory=tmp_path, bucket="docs")
    for index in range(2000):
        store.put(f"private/onboarding/{index:04d}/object", b"x")

    first = store.list_prefix("private/onboarding", limit=500)
    assert first.next_cursor is not None
    scandir_after_first = store.listing_scandir_calls

    second = store.list_prefix("private/onboarding", limit=500, cursor=first.next_cursor)
    scandir_after_second = store.listing_scandir_calls
    delta_second_page = scandir_after_second - scandir_after_first

    assert scandir_after_first > 0
    assert delta_second_page < scandir_after_first
    assert delta_second_page < 2000


def test_local_list_prefix_no_snapshot_between_pages(tmp_path: Path) -> None:
    store = LocalFilesystemStorage(root_directory=tmp_path, bucket="docs")
    for index in range(10):
        store.put(f"private/onboarding/static/{index}", b"x")

    first = store.list_prefix("private/onboarding", limit=5)
    assert first.next_cursor is not None

    store.put("private/onboarding/inserted/mid-run", b"new")
    store.delete("private/onboarding/static/0")

    second = store.list_prefix("private/onboarding", limit=20, cursor=first.next_cursor)
    tail = _collect_all_local_keys(store, "private/onboarding", limit=20)
    assert "private/onboarding/inserted/mid-run" in tail or "private/onboarding/inserted/mid-run" in second.keys


def test_local_list_prefix_invalid_or_expired_cursor(tmp_path: Path) -> None:
    store = LocalFilesystemStorage(root_directory=tmp_path, bucket="docs")
    store.put("private/onboarding/a/file", b"x")

    with pytest.raises(StorageOperationError, match="invalid or expired"):
        store.list_prefix("private/onboarding", limit=10, cursor="not-a-real-token")

    store.put("private/onboarding/b/second", b"y")
    page = store.list_prefix("private/onboarding", limit=1)
    assert page.next_cursor is not None
    token = page.next_cursor

    import app.services.object_storage.local as local_module

    original_monotonic = time.monotonic
    try:
        start = original_monotonic()
        local_module.time.monotonic = lambda: start + local_module._LISTING_TTL_SECONDS + 1
        with pytest.raises(StorageOperationError, match="invalid or expired"):
            store.list_prefix("private/onboarding", limit=10, cursor=token)
    finally:
        local_module.time.monotonic = original_monotonic


def test_local_list_prefix_cursor_wrong_prefix(tmp_path: Path) -> None:
    store = LocalFilesystemStorage(root_directory=tmp_path, bucket="docs")
    store.put("private/onboarding/a/file", b"x")
    store.put("private/other/one/file", b"x")
    store.put("private/other/two/file", b"y")
    page_other = store.list_prefix("private/other", limit=1)
    assert page_other.next_cursor is not None

    with pytest.raises(StorageOperationError, match="invalid or expired"):
        store.list_prefix("private/onboarding", limit=10, cursor=page_other.next_cursor)


def test_local_list_prefix_session_removed_when_complete(tmp_path: Path) -> None:
    store = LocalFilesystemStorage(root_directory=tmp_path, bucket="docs")
    store.put("private/onboarding/only/one", b"x")
    page = store.list_prefix("private/onboarding", limit=100)
    assert page.next_cursor is None
    assert store._listing_sessions == {}


def test_local_list_prefix_missing_prefix_directory(tmp_path: Path) -> None:
    store = LocalFilesystemStorage(root_directory=tmp_path, bucket="docs")
    page = store.list_prefix("private/does-not-exist", limit=50)
    assert page.keys == ()
    assert page.next_cursor is None
    assert store._listing_sessions == {}
