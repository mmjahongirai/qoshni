"""In-memory S3 API double for adapter tests."""

from __future__ import annotations

from typing import Any


class FakeS3Client:
    def __init__(self) -> None:
        self.objects: dict[str, dict[str, Any]] = {}
        self.last_error: Exception | None = None

    def put_object(self, **kwargs: Any) -> dict[str, Any]:
        key = kwargs["Key"]
        body = kwargs["Body"]
        if isinstance(body, bytes):
            data = body
        else:
            data = body.read()
        self.objects[key] = {
            "Body": data,
            "ContentType": kwargs.get("ContentType"),
            "ContentLength": len(data),
        }
        return {}

    def head_object(self, **kwargs: Any) -> dict[str, Any]:
        key = kwargs["Key"]
        if key not in self.objects:
            raise self._not_found()
        item = self.objects[key]
        return {
            "ContentLength": item["ContentLength"],
            "ContentType": item.get("ContentType"),
        }

    def get_object(self, **kwargs: Any) -> dict[str, Any]:
        key = kwargs["Key"]
        if key not in self.objects:
            raise self._not_found()
        item = self.objects[key]

        class _Body:
            def __init__(self, payload: bytes) -> None:
                self._payload = payload

            def read(self) -> bytes:
                return self._payload

        return {"Body": _Body(item["Body"])}

    def delete_object(self, **kwargs: Any) -> dict[str, Any]:
        self.objects.pop(kwargs["Key"], None)
        return {}

    def list_objects_v2(self, **kwargs: Any) -> dict[str, Any]:
        prefix = kwargs.get("Prefix", "")
        max_keys = int(kwargs.get("MaxKeys", 1000))
        token = kwargs.get("ContinuationToken")
        keys = sorted(key for key in self.objects if key.startswith(prefix))
        start = 0
        if token is not None:
            start = int(token)
        page = keys[start : start + max_keys]
        next_start = start + max_keys
        truncated = next_start < len(keys)
        response: dict[str, Any] = {
            "Contents": [{"Key": key} for key in page],
            "IsTruncated": truncated,
        }
        if truncated:
            response["NextContinuationToken"] = str(next_start)
        return response

    @staticmethod
    def _not_found() -> Exception:
        class ClientError(Exception):
            response = {"Error": {"Code": "NoSuchKey"}}

        return ClientError()
