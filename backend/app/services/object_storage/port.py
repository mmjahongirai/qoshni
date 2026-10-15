"""Private object storage port (bytes in/out only — no ORM coupling)."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True, slots=True)
class ObjectHead:
    """Metadata returned by ``head`` without reading object bytes."""

    byte_size: int
    content_type: str | None = None


@dataclass(frozen=True, slots=True)
class ListPrefixPage:
    """One page of opaque object keys under a prefix (server-side listing only)."""

    keys: tuple[str, ...]
    next_cursor: str | None = None


class StoragePort(Protocol):
    """Provider-neutral private object storage."""

    def put(
        self,
        key: str,
        data: bytes,
        *,
        content_type: str | None = None,
        overwrite: bool = False,
    ) -> None:
        """Store ``data`` at ``key``. Uses atomic replace when overwriting."""

    def head(self, key: str) -> ObjectHead:
        """Return object metadata; raise ``StorageObjectNotFoundError`` if missing."""

    def read(self, key: str) -> bytes:
        """Read full object bytes (server-side only)."""

    def delete(self, key: str) -> None:
        """Delete object if present; idempotent when already absent."""

    def list_prefix(
        self,
        prefix: str,
        *,
        limit: int = 500,
        cursor: str | None = None,
    ) -> ListPrefixPage:
        """List regular object keys under ``prefix`` (excludes scratch/meta sidecars)."""
