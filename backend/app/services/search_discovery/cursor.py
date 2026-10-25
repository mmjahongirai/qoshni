"""HMAC-signed search cursors (server-side integrity)."""

from __future__ import annotations

import base64
import json
from dataclasses import dataclass
from typing import Any

from app.core.auth.secrets import compute_secret_digest, require_digest_key, verify_secret_digest
from app.core.config import Settings
from app.domain.search_discovery import SEARCH_CURSOR_HMAC_DOMAIN

CURSOR_VERSION = 1


@dataclass(frozen=True, slots=True)
class SearchCursorPayload:
    version: int
    query_fingerprint: str
    catalog_generation: int
    after_total_score: float
    after_relevance_score: float
    after_stable_id: str


def _canonical_payload(payload: SearchCursorPayload) -> str:
    body = {
        "v": payload.version,
        "q": payload.query_fingerprint,
        "g": payload.catalog_generation,
        "t": payload.after_total_score,
        "r": payload.after_relevance_score,
        "s": payload.after_stable_id,
    }
    return json.dumps(body, separators=(",", ":"), sort_keys=True)


def encode_signed_cursor(settings: Settings, payload: SearchCursorPayload) -> str:
    key = require_digest_key(settings)
    canonical = _canonical_payload(payload)
    digest = compute_secret_digest(key=key, secret=canonical, domain=SEARCH_CURSOR_HMAC_DOMAIN)
    envelope = {"p": canonical, "sig": digest}
    return base64.urlsafe_b64encode(json.dumps(envelope).encode("utf-8")).decode("ascii")


def decode_signed_cursor(settings: Settings, raw: str | None) -> SearchCursorPayload | None:
    if raw is None or not raw.strip():
        return None
    try:
        envelope_bytes = base64.urlsafe_b64decode(raw.encode("ascii"))
        envelope = json.loads(envelope_bytes.decode("utf-8"))
        canonical = envelope["p"]
        sig = envelope["sig"]
        if not isinstance(canonical, str) or not isinstance(sig, str):
            return None
        key = require_digest_key(settings)
        if not verify_secret_digest(
            key=key,
            secret=canonical,
            domain=SEARCH_CURSOR_HMAC_DOMAIN,
            expected_digest=sig,
        ):
            return None
        body: dict[str, Any] = json.loads(canonical)
        if body.get("v") != CURSOR_VERSION:
            return None
        return SearchCursorPayload(
            version=int(body["v"]),
            query_fingerprint=str(body["q"]),
            catalog_generation=int(body["g"]),
            after_total_score=float(body["t"]),
            after_relevance_score=float(body["r"]),
            after_stable_id=str(body["s"]),
        )
    except (KeyError, TypeError, ValueError, json.JSONDecodeError):
        return None


def cursor_is_after_row(cursor: SearchCursorPayload, row: "RankedRowLike") -> bool:
    if row.total_score < cursor.after_total_score:
        return True
    if row.total_score > cursor.after_total_score:
        return False
    if row.relevance_score < cursor.after_relevance_score:
        return True
    if row.relevance_score > cursor.after_relevance_score:
        return False
    return row.stable_id > cursor.after_stable_id


@dataclass(frozen=True, slots=True)
class RankedRowLike:
    stable_id: str
    total_score: float
    relevance_score: float
