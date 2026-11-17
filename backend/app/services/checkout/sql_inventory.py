"""Database-backed stock holds for consumer catalog items (Phase 18 Closure WP2).

Balances live on ``consumer_catalog_inventory``, keyed by catalog item id. The
catalog item still points at a verified onboarding application, so a later
Business Profile migration can repoint items without moving these rows.

PostgreSQL locks the balance with ``SELECT … FOR UPDATE`` and then updates it.
Other dialects, including the SQLite test database, use a single conditional
``UPDATE`` (``available >= quantity``) so two writers cannot both succeed.
"""

from __future__ import annotations

import uuid
from datetime import UTC, datetime
from enum import StrEnum

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.db.models.consumer_catalog import ConsumerCatalogInventory, ConsumerCatalogItem
from app.domain.consumer_catalog import ConsumerCatalogItemStatus
from app.services.checkout.inventory_reservation_service import InventoryReservationRecord, SkuKey
from app.services.search_discovery.stable_ids import application_id_from_stable_id
from app.domain.inventory_reservation import InventoryReservationStatus


def open_catalog_inventory(
    session: Session,
    *,
    catalog_item_id: uuid.UUID,
    quantity_on_hand: int,
) -> ConsumerCatalogInventory:
    """Record a counted balance. ``quantity_on_hand`` must be passed explicitly.

    ``reserved_quantity`` is set to 0 because the balance has no holds yet —
    that is an explicit initial state, not a database default.
    """
    if isinstance(quantity_on_hand, bool) or not isinstance(quantity_on_hand, int):
        raise ValueError("quantity_on_hand must be an integer.")
    if quantity_on_hand < 0:
        raise ValueError("quantity_on_hand cannot be negative.")
    row = ConsumerCatalogInventory(
        catalog_item_id=catalog_item_id,
        quantity_on_hand=quantity_on_hand,
        reserved_quantity=0,
    )
    session.add(row)
    session.flush()
    return row


def _find_catalog_item(
    session: Session,
    sku: SkuKey,
    *,
    active_only: bool,
) -> ConsumerCatalogItem | None:
    application_id = application_id_from_stable_id(sku.business_stable_id)
    if application_id is None:
        return None
    filters = [
        ConsumerCatalogItem.business_application_id == application_id,
        ConsumerCatalogItem.catalog_item_stable_id == sku.catalog_item_stable_id,
    ]
    if active_only:
        filters.append(ConsumerCatalogItem.status == ConsumerCatalogItemStatus.ACTIVE.value)
    return session.scalar(select(ConsumerCatalogItem).where(*filters))


def _holds_row_lock(session: Session) -> bool:
    return session.get_bind().dialect.name == "postgresql"


def reserve_catalog_quantity(
    session: Session,
    *,
    catalog_item_id: uuid.UUID,
    quantity: int,
) -> bool:
    """Atomically move ``quantity`` from available to reserved. False if it cannot."""
    if quantity <= 0:
        return False
    now = datetime.now(UTC)
    if _holds_row_lock(session):
        balance = session.scalar(
            select(ConsumerCatalogInventory)
            .where(ConsumerCatalogInventory.catalog_item_id == catalog_item_id)
            .with_for_update()
        )
        if balance is None:
            return False
        if balance.quantity_on_hand - balance.reserved_quantity < quantity:
            return False
        balance.reserved_quantity += quantity
        balance.updated_at = now
        session.flush()
        return True

    available = (
        ConsumerCatalogInventory.quantity_on_hand - ConsumerCatalogInventory.reserved_quantity
    )
    result = session.execute(
        update(ConsumerCatalogInventory)
        .where(
            ConsumerCatalogInventory.catalog_item_id == catalog_item_id,
            available >= quantity,
        )
        .values(
            reserved_quantity=ConsumerCatalogInventory.reserved_quantity + quantity,
            updated_at=now,
        )
    )
    return result.rowcount == 1


def release_catalog_quantity(
    session: Session,
    *,
    catalog_item_id: uuid.UUID,
    quantity: int,
) -> bool:
    """Return held units to available. False when the balance cannot absorb them."""
    if quantity <= 0:
        return False
    now = datetime.now(UTC)
    if _holds_row_lock(session):
        balance = session.scalar(
            select(ConsumerCatalogInventory)
            .where(ConsumerCatalogInventory.catalog_item_id == catalog_item_id)
            .with_for_update()
        )
        if balance is None or balance.reserved_quantity < quantity:
            return False
        balance.reserved_quantity -= quantity
        balance.updated_at = now
        session.flush()
        return True

    result = session.execute(
        update(ConsumerCatalogInventory)
        .where(
            ConsumerCatalogInventory.catalog_item_id == catalog_item_id,
            ConsumerCatalogInventory.reserved_quantity >= quantity,
        )
        .values(
            reserved_quantity=ConsumerCatalogInventory.reserved_quantity - quantity,
            updated_at=now,
        )
    )
    return result.rowcount == 1


def release_reservation_stock(
    session: Session,
    *,
    business_stable_id: str,
    catalog_item_stable_id: str,
    quantity: int,
) -> bool:
    item = _find_catalog_item(
        session,
        SkuKey(
            business_stable_id=business_stable_id,
            catalog_item_stable_id=catalog_item_stable_id,
        ),
        active_only=False,
    )
    if item is None:
        return True
    balance = session.get(ConsumerCatalogInventory, item.id)
    if balance is None:
        return True
    return release_catalog_quantity(session, catalog_item_id=item.id, quantity=quantity)


class OnHandChange(StrEnum):
    APPLIED = "applied"
    NOT_OPEN = "not_open"
    BELOW_RESERVED = "below_reserved"


def apply_on_hand_delta(
    session: Session,
    *,
    catalog_item_id: uuid.UUID,
    delta: int,
) -> tuple[OnHandChange, ConsumerCatalogInventory | None]:
    """Change on-hand stock without touching ``reserved_quantity``.

    The resulting on-hand value must stay at least the reserved quantity.
    """
    if isinstance(delta, bool) or not isinstance(delta, int) or delta == 0:
        balance = session.get(ConsumerCatalogInventory, catalog_item_id)
        if balance is None:
            return OnHandChange.NOT_OPEN, None
        return OnHandChange.APPLIED, balance
    now = datetime.now(UTC)
    if _holds_row_lock(session):
        balance = session.scalar(
            select(ConsumerCatalogInventory)
            .where(ConsumerCatalogInventory.catalog_item_id == catalog_item_id)
            .with_for_update()
        )
        if balance is None:
            return OnHandChange.NOT_OPEN, None
        updated = balance.quantity_on_hand + delta
        if updated < balance.reserved_quantity or updated < 0:
            return OnHandChange.BELOW_RESERVED, balance
        balance.quantity_on_hand = updated
        balance.updated_at = now
        session.flush()
        return OnHandChange.APPLIED, balance

    result = session.execute(
        update(ConsumerCatalogInventory)
        .where(
            ConsumerCatalogInventory.catalog_item_id == catalog_item_id,
            ConsumerCatalogInventory.quantity_on_hand + delta
            >= ConsumerCatalogInventory.reserved_quantity,
            ConsumerCatalogInventory.quantity_on_hand + delta >= 0,
        )
        .values(
            quantity_on_hand=ConsumerCatalogInventory.quantity_on_hand + delta,
            updated_at=now,
        )
    )
    if result.rowcount == 1:
        session.expire_all()
        balance = session.get(ConsumerCatalogInventory, catalog_item_id)
        return OnHandChange.APPLIED, balance
    balance = session.get(ConsumerCatalogInventory, catalog_item_id)
    if balance is None:
        return OnHandChange.NOT_OPEN, None
    return OnHandChange.BELOW_RESERVED, balance


class SqlCatalogInventoryService:
    """Placement port backed by ``consumer_catalog_inventory`` (same DB session)."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def reserve_for_order(
        self,
        *,
        sku: SkuKey,
        quantity: int,
        order_id: uuid.UUID,
    ) -> InventoryReservationRecord | None:
        item = _find_catalog_item(self._session, sku, active_only=True)
        if item is None:
            return None
        if not reserve_catalog_quantity(
            self._session,
            catalog_item_id=item.id,
            quantity=quantity,
        ):
            return None
        return InventoryReservationRecord(
            reservation_id=uuid.uuid4(),
            sku=sku,
            quantity=quantity,
            status=InventoryReservationStatus.HELD,
            order_id=order_id,
        )
