"""Storage list_prefix tests."""

from __future__ import annotations

import os
import uuid
from pathlib import Path

import pytest

from app.services.object_storage.local import LocalFilesystemStorage
from tests.support.memory_object_storage import MemoryObjectStorage


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
