"""Owner inventory commands. Reservations stay under the order engine."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from enum import StrEnum

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db.models.consumer_catalog import (
    ConsumerCatalogInventory,
    ConsumerCatalogInventoryEvent,
    ConsumerCatalogItem,
)
from app.domain.consumer_catalog import (
    INVENTORY_EVENT_REASON_MAX_LENGTH,
    ConsumerCatalogInventoryEventKind,
)
from app.services.checkout.consumer_catalog_service import (
    ConsumerCatalogWriteError,
    ConsumerCatalogWriteErrorCode,
    get_catalog_offering,
)
from app.services.checkout.sql_inventory import (
    OnHandChange,
    apply_on_hand_delta,
    open_catalog_inventory,
)


class InventoryAdminErrorCode(StrEnum):
    VALIDATION_FAILED = "validation_failed"
    BUSINESS_NOT_FOUND = "business_not_found"
    BUSINESS_NOT_VERIFIED = "business_not_verified"
    CATALOG_ITEM_NOT_FOUND = "catalog_item_not_found"
    INVENTORY_ALREADY_OPEN = "inventory_already_open"
    INVENTORY_NOT_OPEN = "inventory_not_open"
    BELOW_RESERVED = "below_reserved"


@dataclass(frozen=True, slots=True)
class InventoryAdminError:
    code: InventoryAdminErrorCode
    message: str


def _clean_reason(reason: str) -> str | InventoryAdminError:
    cleaned = reason.strip()
    if not cleaned or len(cleaned) > INVENTORY_EVENT_REASON_MAX_LENGTH:
        return InventoryAdminError(
            code=InventoryAdminErrorCode.VALIDATION_FAILED,
            message="A non-empty reason is required.",
        )
    return cleaned


def _from_catalog_error(error: ConsumerCatalogWriteError) -> InventoryAdminError:
    return InventoryAdminError(
        code=InventoryAdminErrorCode(error.code.value),
        message=error.message,
    )


def _require_item(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
) -> ConsumerCatalogItem | InventoryAdminError:
    item = get_catalog_offering(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(item, ConsumerCatalogWriteError):
        return _from_catalog_error(item)
    return item


def _record_event(
    session: Session,
    *,
    item_id: uuid.UUID,
    actor_user_id: uuid.UUID,
    kind: ConsumerCatalogInventoryEventKind,
    delta: int,
    balance: ConsumerCatalogInventory,
    reason: str,
) -> ConsumerCatalogInventoryEvent:
    event = ConsumerCatalogInventoryEvent(
        catalog_item_id=item_id,
        actor_user_id=actor_user_id,
        kind=kind.value,
        quantity_delta=delta,
        quantity_on_hand_after=balance.quantity_on_hand,
        reserved_quantity_after=balance.reserved_quantity,
        reason=reason,
    )
    session.add(event)
    session.flush()
    return event


def open_owner_inventory(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    quantity_on_hand: int,
    reason: str,
) -> ConsumerCatalogInventory | InventoryAdminError:
    item = _require_item(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(item, InventoryAdminError):
        return item
    cleaned = _clean_reason(reason)
    if isinstance(cleaned, InventoryAdminError):
        return cleaned
    if session.get(ConsumerCatalogInventory, item.id) is not None:
        return InventoryAdminError(
            code=InventoryAdminErrorCode.INVENTORY_ALREADY_OPEN,
            message="Inventory is already open. Replenish or correct the count instead of replacing it.",
        )
    try:
        balance = open_catalog_inventory(
            session,
            catalog_item_id=item.id,
            quantity_on_hand=quantity_on_hand,
        )
    except ValueError as exc:
        return InventoryAdminError(
            code=InventoryAdminErrorCode.VALIDATION_FAILED,
            message=str(exc),
        )
    except IntegrityError:
        session.rollback()
        return InventoryAdminError(
            code=InventoryAdminErrorCode.INVENTORY_ALREADY_OPEN,
            message="Inventory is already open.",
        )
    _record_event(
        session,
        item_id=item.id,
        actor_user_id=owner_user_id,
        kind=ConsumerCatalogInventoryEventKind.OPENED,
        delta=quantity_on_hand,
        balance=balance,
        reason=cleaned,
    )
    return balance


def replenish_owner_inventory(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    quantity: int,
    reason: str,
) -> ConsumerCatalogInventory | InventoryAdminError:
    item = _require_item(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(item, InventoryAdminError):
        return item
    cleaned = _clean_reason(reason)
    if isinstance(cleaned, InventoryAdminError):
        return cleaned
    if isinstance(quantity, bool) or not isinstance(quantity, int) or quantity <= 0:
        return InventoryAdminError(
            code=InventoryAdminErrorCode.VALIDATION_FAILED,
            message="Replenishment quantity must be a positive integer.",
        )
    outcome, balance = apply_on_hand_delta(session, catalog_item_id=item.id, delta=quantity)
    if outcome == OnHandChange.NOT_OPEN or balance is None:
        return InventoryAdminError(
            code=InventoryAdminErrorCode.INVENTORY_NOT_OPEN,
            message="Open inventory before replenishing it.",
        )
    _record_event(
        session,
        item_id=item.id,
        actor_user_id=owner_user_id,
        kind=ConsumerCatalogInventoryEventKind.REPLENISHED,
        delta=quantity,
        balance=balance,
        reason=cleaned,
    )
    return balance


def correct_owner_inventory_count(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    quantity_on_hand: int,
    reason: str,
) -> ConsumerCatalogInventory | InventoryAdminError:
    """Set on-hand to a counted value. Reserved units are left in place."""
    item = _require_item(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(item, InventoryAdminError):
        return item
    cleaned = _clean_reason(reason)
    if isinstance(cleaned, InventoryAdminError):
        return cleaned
    if isinstance(quantity_on_hand, bool) or not isinstance(quantity_on_hand, int) or quantity_on_hand < 0:
        return InventoryAdminError(
            code=InventoryAdminErrorCode.VALIDATION_FAILED,
            message="Counted on-hand quantity must be a non-negative integer.",
        )
    current = session.get(ConsumerCatalogInventory, item.id)
    if current is None:
        return InventoryAdminError(
            code=InventoryAdminErrorCode.INVENTORY_NOT_OPEN,
            message="Open inventory before correcting the count.",
        )
    delta = quantity_on_hand - current.quantity_on_hand
    if delta == 0:
        _record_event(
            session,
            item_id=item.id,
            actor_user_id=owner_user_id,
            kind=ConsumerCatalogInventoryEventKind.COUNT_CORRECTED,
            delta=0,
            balance=current,
            reason=cleaned,
        )
        return current
    outcome, balance = apply_on_hand_delta(session, catalog_item_id=item.id, delta=delta)
    if outcome == OnHandChange.BELOW_RESERVED:
        return InventoryAdminError(
            code=InventoryAdminErrorCode.BELOW_RESERVED,
            message="On-hand quantity cannot be set below the reserved quantity.",
        )
    if outcome != OnHandChange.APPLIED or balance is None:
        return InventoryAdminError(
            code=InventoryAdminErrorCode.INVENTORY_NOT_OPEN,
            message="Open inventory before correcting the count.",
        )
    _record_event(
        session,
        item_id=item.id,
        actor_user_id=owner_user_id,
        kind=ConsumerCatalogInventoryEventKind.COUNT_CORRECTED,
        delta=delta,
        balance=balance,
        reason=cleaned,
    )
    return balance


def get_owner_inventory(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
) -> ConsumerCatalogInventory | InventoryAdminError:
    item = _require_item(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(item, InventoryAdminError):
        return item
    balance = session.get(ConsumerCatalogInventory, item.id)
    if balance is None:
        return InventoryAdminError(
            code=InventoryAdminErrorCode.INVENTORY_NOT_OPEN,
            message="Inventory has not been opened for this item.",
        )
    return balance


def list_owner_inventory_events(
    session: Session,
    *,
    owner_user_id: uuid.UUID,
    business_application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
) -> list[ConsumerCatalogInventoryEvent] | InventoryAdminError:
    item = _require_item(
        session,
        owner_user_id=owner_user_id,
        business_application_id=business_application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(item, InventoryAdminError):
        return item
    return list(
        session.scalars(
            select(ConsumerCatalogInventoryEvent)
            .where(ConsumerCatalogInventoryEvent.catalog_item_id == item.id)
            .order_by(ConsumerCatalogInventoryEvent.created_at, ConsumerCatalogInventoryEvent.id)
        )
    )
