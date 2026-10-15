"""In-memory ``StoragePort`` for API tests."""

from __future__ import annotations

from app.services.object_storage.errors import (
    StorageObjectAlreadyExistsError,
    StorageObjectNotFoundError,
    StorageOperationError,
)
from app.services.object_storage.port import ObjectHead


class MemoryObjectStorage:
    def __init__(self, *, fail_puts: bool = False) -> None:
        self._objects: dict[str, bytes] = {}
        self._content_types: dict[str, str | None] = {}
        self.fail_puts = fail_puts
        self.put_calls = 0

    def put(
        self,
        key: str,
        data: bytes,
        *,
        content_type: str | None = None,
        overwrite: bool = False,
    ) -> None:
        self.put_calls += 1
        if self.fail_puts:
            raise StorageOperationError("Injected storage failure.")
        if key in self._objects and not overwrite:
            raise StorageObjectAlreadyExistsError("Storage object already exists.")
        self._objects[key] = data
        self._content_types[key] = content_type

    def head(self, key: str) -> ObjectHead:
        if key not in self._objects:
            raise StorageObjectNotFoundError("Storage object not found.")
        return ObjectHead(
            byte_size=len(self._objects[key]),
            content_type=self._content_types.get(key),
        )

    def read(self, key: str) -> bytes:
        if key not in self._objects:
            raise StorageObjectNotFoundError("Storage object not found.")
        return self._objects[key]

    def delete(self, key: str) -> None:
        self._objects.pop(key, None)
        self._content_types.pop(key, None)
