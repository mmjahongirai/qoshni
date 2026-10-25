"""In-process inventory holds for tests; production requires authoritative catalog + persistence."""

from __future__ import annotations

import threading
import uuid
from dataclasses import dataclass, field

from app.domain.inventory_reservation import InventoryReservationStatus


@dataclass(frozen=True, slots=True)
class SkuKey:
    business_stable_id: str
    catalog_item_stable_id: str


@dataclass
class InventoryReservationRecord:
    reservation_id: uuid.UUID
    sku: SkuKey
    quantity: int
    status: InventoryReservationStatus
    order_id: uuid.UUID | None = None


class InMemoryInventoryLedger:
    """Test-only authoritative stock ledger (not used in production API path)."""

    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._available: dict[SkuKey, int] = {}
        self._reservations: dict[uuid.UUID, InventoryReservationRecord] = {}

    def seed_stock(self, sku: SkuKey, quantity: int) -> None:
        with self._lock:
            self._available[sku] = quantity

    def available(self, sku: SkuKey) -> int:
        with self._lock:
            return self._available.get(sku, 0)

    def reserve(
        self,
        *,
        sku: SkuKey,
        quantity: int,
        order_id: uuid.UUID,
    ) -> InventoryReservationRecord | None:
        with self._lock:
            current = self._available.get(sku, 0)
            if quantity <= 0 or quantity > current:
                return None
            self._available[sku] = current - quantity
            record = InventoryReservationRecord(
                reservation_id=uuid.uuid4(),
                sku=sku,
                quantity=quantity,
                status=InventoryReservationStatus.HELD,
                order_id=order_id,
            )
            self._reservations[record.reservation_id] = record
            return record

    def consume(self, reservation_id: uuid.UUID) -> bool:
        with self._lock:
            record = self._reservations.get(reservation_id)
            if record is None or record.status != InventoryReservationStatus.HELD:
                return False
            record.status = InventoryReservationStatus.CONSUMED
            return True

    def release(self, reservation_id: uuid.UUID) -> bool:
        with self._lock:
            record = self._reservations.get(reservation_id)
            if record is None or record.status != InventoryReservationStatus.HELD:
                return False
            record.status = InventoryReservationStatus.RELEASED
            self._available[record.sku] = self._available.get(record.sku, 0) + record.quantity
            return True


@dataclass
class InventoryReservationService:
    ledger: InMemoryInventoryLedger = field(default_factory=InMemoryInventoryLedger)

    def reserve_for_order(
        self,
        *,
        sku: SkuKey,
        quantity: int,
        order_id: uuid.UUID,
    ) -> InventoryReservationRecord | None:
        return self.ledger.reserve(sku=sku, quantity=quantity, order_id=order_id)
