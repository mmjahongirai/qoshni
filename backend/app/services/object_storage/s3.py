"""S3-compatible private object storage (production adapter)."""

from __future__ import annotations

import base64
import json
from typing import Any, Protocol

from app.services.object_storage.errors import (
    StorageKeyInvalidError,
    StorageObjectAlreadyExistsError,
    StorageObjectNotFoundError,
    StorageOperationError,
)
from app.services.object_storage.keys import validate_storage_object_key
from app.services.object_storage.port import ListPrefixPage, ObjectHead


class S3ClientProtocol(Protocol):
    def put_object(self, **kwargs: Any) -> Any: ...

    def head_object(self, **kwargs: Any) -> Any: ...

    def get_object(self, **kwargs: Any) -> Any: ...

    def delete_object(self, **kwargs: Any) -> Any: ...

    def list_objects_v2(self, **kwargs: Any) -> Any: ...


class S3ObjectStorage:
    """Private object operations against one bucket (no public ACLs or URLs)."""

    _CURSOR_VERSION = 1

    def __init__(self, *, client: S3ClientProtocol, bucket: str) -> None:
        bucket_name = bucket.strip()
        if not bucket_name:
            raise StorageKeyInvalidError("Object storage bucket name is invalid.")
        self._client = client
        self._bucket = bucket_name

    def put(
        self,
        key: str,
        data: bytes,
        *,
        content_type: str | None = None,
        overwrite: bool = False,
    ) -> None:
        safe_key = validate_storage_object_key(key)
        if not overwrite:
            try:
                self.head(safe_key)
            except StorageObjectNotFoundError:
                pass
            else:
                raise StorageObjectAlreadyExistsError("Storage object already exists.")

        params: dict[str, Any] = {
            "Bucket": self._bucket,
            "Key": safe_key,
            "Body": data,
        }
        if content_type:
            params["ContentType"] = content_type.strip()
        try:
            self._client.put_object(**params)
        except Exception as error:
            raise self._map_error(error, operation="put") from error

    def head(self, key: str) -> ObjectHead:
        safe_key = validate_storage_object_key(key)
        try:
            response = self._client.head_object(Bucket=self._bucket, Key=safe_key)
        except Exception as error:
            raise self._map_error(error, operation="head") from error
        size = int(response.get("ContentLength", 0))
        content_type = response.get("ContentType")
        return ObjectHead(byte_size=size, content_type=content_type)

    def read(self, key: str) -> bytes:
        safe_key = validate_storage_object_key(key)
        try:
            response = self._client.get_object(Bucket=self._bucket, Key=safe_key)
            body = response["Body"]
            return body.read()
        except Exception as error:
            raise self._map_error(error, operation="read") from error

    def delete(self, key: str) -> None:
        try:
            safe_key = validate_storage_object_key(key)
        except StorageKeyInvalidError:
            return
        try:
            self._client.delete_object(Bucket=self._bucket, Key=safe_key)
        except Exception as error:
            raise self._map_error(error, operation="delete") from error

    def _encode_cursor(self, *, prefix: str, continuation_token: str) -> str:
        payload = {
            "v": self._CURSOR_VERSION,
            "prefix": prefix.rstrip("/"),
            "token": continuation_token,
        }
        raw = json.dumps(payload, separators=(",", ":"), sort_keys=True).encode("utf-8")
        return base64.urlsafe_b64encode(raw).decode("ascii")

    def _decode_cursor(self, *, prefix: str, cursor: str) -> str:
        try:
            raw = base64.urlsafe_b64decode(cursor.encode("ascii"))
            payload = json.loads(raw.decode("utf-8"))
        except (ValueError, json.JSONDecodeError):
            raise StorageOperationError("Listing cursor is invalid or expired.") from None
        if payload.get("v") != self._CURSOR_VERSION:
            raise StorageOperationError("Listing cursor is invalid or expired.")
        if payload.get("prefix") != prefix.rstrip("/"):
            raise StorageOperationError("Listing cursor is invalid or expired.")
        token = payload.get("token")
        if not isinstance(token, str) or not token:
            raise StorageOperationError("Listing cursor is invalid or expired.")
        return token

    def list_prefix(
        self,
        prefix: str,
        *,
        limit: int = 500,
        cursor: str | None = None,
    ) -> ListPrefixPage:
        if limit < 1:
            raise StorageKeyInvalidError("Listing limit must be positive.")

        safe_prefix = validate_storage_object_key(prefix.rstrip("/"))
        list_prefix = f"{safe_prefix}/" if safe_prefix else ""
        params: dict[str, Any] = {
            "Bucket": self._bucket,
            "Prefix": list_prefix,
            "MaxKeys": limit,
        }
        if cursor is not None:
            params["ContinuationToken"] = self._decode_cursor(prefix=safe_prefix, cursor=cursor)

        try:
            response = self._client.list_objects_v2(**params)
        except Exception as error:
            raise self._map_error(error, operation="list") from error

        keys: list[str] = []
        for item in response.get("Contents") or ():
            object_key = item.get("Key")
            if not isinstance(object_key, str):
                continue
            if object_key.endswith("/"):
                continue
            try:
                keys.append(validate_storage_object_key(object_key))
            except StorageKeyInvalidError:
                continue

        next_cursor = None
        if response.get("IsTruncated"):
            token = response.get("NextContinuationToken")
            if isinstance(token, str) and token:
                next_cursor = self._encode_cursor(prefix=safe_prefix, continuation_token=token)

        return ListPrefixPage(keys=tuple(keys), next_cursor=next_cursor)

    @staticmethod
    def _map_error(error: Exception, *, operation: str) -> Exception:
        code = None
        response = getattr(error, "response", None)
        if isinstance(response, dict):
            error_block = response.get("Error")
            if isinstance(error_block, dict):
                code = error_block.get("Code")
        if code in {"NoSuchKey", "404", "NotFound"}:
            return StorageObjectNotFoundError("Storage object not found.")
        if code in {"PreconditionFailed", "412"} and operation == "put":
            return StorageObjectAlreadyExistsError("Storage object already exists.")
        return StorageOperationError("Storage operation failed.")
