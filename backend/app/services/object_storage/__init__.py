"""Private object storage (Phase 07 Part 6B.1)."""

from app.services.object_storage.factory import create_object_storage
from app.services.object_storage.port import ObjectHead, StoragePort

__all__ = ["ObjectHead", "StoragePort", "create_object_storage"]
