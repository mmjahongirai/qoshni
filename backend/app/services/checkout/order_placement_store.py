"""Ephemeral order/idempotency storage for service-layer tests (no production DB schema yet)."""

from __future__ import annotations

import hashlib
import json
import threading
import uuid
from dataclasses import dataclass, field
from datetime import UTC, datetime

from app.domain.order_lifecycle import (
    ConsumerOrderFulfillmentStatus,
    ConsumerOrderPaymentStatus,
    ConsumerOrderStatus,
)


@dataclass(frozen=True, slots=True)
class OrderLineSnapshot:
    business_stable_id: str
    catalog_item_stable_id: str
    title_snapshot: str
    quantity: int
    unit_price_minor: int
    line_subtotal_minor: int
    currency_code: str


@dataclass
class ConsumerOrderRecord:
    order_id: uuid.UUID
    buyer_user_id: uuid.UUID
    status: ConsumerOrderStatus
    payment_status: ConsumerOrderPaymentStatus
    fulfillment_status: ConsumerOrderFulfillmentStatus
    currency_code: str
    subtotal_minor: int
    total_minor: int
    checkout_correlation_id: str
    idempotency_key: str
    lines: list[OrderLineSnapshot]
    reservation_ids: list[uuid.UUID]
    checkout_quote_id: uuid.UUID | None = None
    created_at: datetime = field(default_factory=lambda: datetime.now(UTC))
    updated_at: datetime = field(default_factory=lambda: datetime.now(UTC))


@dataclass(frozen=True, slots=True)
class IdempotencyScope:
    buyer_user_id: uuid.UUID
    operation: str
    idempotency_key: str


@dataclass
class IdempotencyRecord:
    scope: IdempotencyScope
    request_fingerprint: str
    order_id: uuid.UUID
    created_at: datetime = field(default_factory=lambda: datetime.now(UTC))


def fingerprint_place_order_request(payload: dict) -> str:
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


class InMemoryOrderPlacementStore:
    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._orders: dict[uuid.UUID, ConsumerOrderRecord] = {}
        self._idempotency: dict[tuple[uuid.UUID, str, str], IdempotencyRecord] = {}

    def get_idempotency(self, scope: IdempotencyScope) -> IdempotencyRecord | None:
        with self._lock:
            key = (scope.buyer_user_id, scope.operation, scope.idempotency_key)
            return self._idempotency.get(key)

    def save_idempotency(self, record: IdempotencyRecord) -> None:
        with self._lock:
            key = (
                record.scope.buyer_user_id,
                record.scope.operation,
                record.scope.idempotency_key,
            )
            self._idempotency[key] = record

    def get_order(self, order_id: uuid.UUID) -> ConsumerOrderRecord | None:
        with self._lock:
            return self._orders.get(order_id)

    def save_order(self, order: ConsumerOrderRecord) -> None:
        with self._lock:
            self._orders[order.order_id] = order
