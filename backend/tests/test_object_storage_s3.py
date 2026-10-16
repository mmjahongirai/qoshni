"""S3-compatible storage adapter tests (no real network)."""

from __future__ import annotations

import pytest

from app.services.object_storage.errors import (
    StorageObjectAlreadyExistsError,
    StorageObjectNotFoundError,
    StorageOperationError,
)
from app.services.object_storage.s3 import S3ObjectStorage
from tests.support.fake_s3_client import FakeS3Client


@pytest.fixture
def s3_storage() -> S3ObjectStorage:
    return S3ObjectStorage(client=FakeS3Client(), bucket="private-docs")


def test_put_head_read_delete_round_trip(s3_storage: S3ObjectStorage) -> None:
    key = "private/onboarding/app/doc"
    payload = b"%PDF-1.4\n"
    s3_storage.put(key, payload, content_type="application/pdf")
    assert s3_storage.head(key).byte_size == len(payload)
    assert s3_storage.read(key) == payload
    s3_storage.delete(key)
    with pytest.raises(StorageObjectNotFoundError):
        s3_storage.head(key)


def test_put_without_overwrite_rejects_existing_key(s3_storage: S3ObjectStorage) -> None:
    key = "private/onboarding/app/doc"
    s3_storage.put(key, b"a")
    with pytest.raises(StorageObjectAlreadyExistsError):
        s3_storage.put(key, b"b", overwrite=False)


def test_list_prefix_paginates_without_loading_entire_bucket(s3_storage: S3ObjectStorage) -> None:
    for index in range(5):
        s3_storage.put(f"private/onboarding/{index}/object", b"x")
    first = s3_storage.list_prefix("private/onboarding", limit=2)
    assert len(first.keys) == 2
    assert first.next_cursor is not None
    second = s3_storage.list_prefix("private/onboarding", limit=2, cursor=first.next_cursor)
    assert len(second.keys) == 2
    collected = set(first.keys) | set(second.keys)
    assert len(collected) == 4


def test_list_prefix_rejects_wrong_prefix_cursor(s3_storage: S3ObjectStorage) -> None:
    s3_storage.put("private/onboarding/a/file", b"x")
    s3_storage.put("private/onboarding/b/file", b"y")
    page = s3_storage.list_prefix("private/onboarding", limit=1)
    assert page.next_cursor is not None
    with pytest.raises(StorageOperationError, match="invalid or expired"):
        s3_storage.list_prefix("private/other", limit=10, cursor=page.next_cursor)


def test_provider_errors_do_not_leak_internals(s3_storage: S3ObjectStorage) -> None:
    class BrokenClient(FakeS3Client):
        def head_object(self, **kwargs):  # type: ignore[no-untyped-def]
            raise RuntimeError("secret-endpoint-token leak")

    broken = S3ObjectStorage(client=BrokenClient(), bucket="b")
    with pytest.raises(StorageOperationError, match="Storage operation failed"):
        broken.head("private/onboarding/missing")
    with pytest.raises(StorageOperationError) as error:
        broken.head("private/onboarding/missing")
    assert "secret-endpoint-token" not in str(error.value)
