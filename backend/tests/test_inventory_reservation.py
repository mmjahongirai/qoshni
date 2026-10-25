"""Inventory reservation ledger (test fixture)."""

import uuid

from app.services.checkout.inventory_reservation_service import (
    InMemoryInventoryLedger,
    InventoryReservationService,
    SkuKey,
)


def test_reserve_and_release_restore_stock() -> None:
    ledger = InMemoryInventoryLedger()
    sku = SkuKey("baraka-market", "baraka-fresh-bread")
    ledger.seed_stock(sku, 5)
    service = InventoryReservationService(ledger=ledger)
    order_id = uuid.uuid4()
    record = service.reserve_for_order(sku=sku, quantity=2, order_id=order_id)
    assert record is not None
    assert ledger.available(sku) == 3
    assert ledger.release(record.reservation_id)
    assert ledger.available(sku) == 5


def test_oversell_rejected() -> None:
    ledger = InMemoryInventoryLedger()
    sku = SkuKey("baraka-market", "baraka-fresh-bread")
    ledger.seed_stock(sku, 1)
    service = InventoryReservationService(ledger=ledger)
    order_id = uuid.uuid4()
    assert service.reserve_for_order(sku=sku, quantity=2, order_id=order_id) is None
