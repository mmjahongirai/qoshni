"""Owner catalog and inventory management contracts."""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.domain.consumer_catalog import (
    INVENTORY_EVENT_REASON_MAX_LENGTH,
    ConsumerCatalogInventoryEventKind,
    ConsumerCatalogItemStatus,
    ConsumerCatalogOfferingKind,
)


class _Strict(BaseModel):
    model_config = ConfigDict(extra="forbid")


class CatalogItemCreateRequest(_Strict):
    catalog_item_stable_id: str = Field(min_length=1, max_length=128)
    offering_kind: ConsumerCatalogOfferingKind
    title: str = Field(min_length=1, max_length=256)
    unit_price_minor: int = Field(ge=0, le=1_000_000_000)


class CatalogItemPriceRequest(_Strict):
    unit_price_minor: int = Field(ge=0, le=1_000_000_000)


class CatalogItemStatusRequest(_Strict):
    status: ConsumerCatalogItemStatus


class CatalogItemView(BaseModel):
    catalog_item_id: uuid.UUID
    business_application_id: uuid.UUID
    catalog_item_stable_id: str
    offering_kind: ConsumerCatalogOfferingKind
    title: str
    unit_price_minor: int
    currency_code: str
    pricing_revision: int
    status: ConsumerCatalogItemStatus
    created_at: datetime
    updated_at: datetime


class CatalogItemListResponse(BaseModel):
    items: list[CatalogItemView]


class InventoryOpenRequest(_Strict):
    quantity_on_hand: int = Field(ge=0)
    reason: str = Field(min_length=1, max_length=INVENTORY_EVENT_REASON_MAX_LENGTH)


class InventoryReplenishRequest(_Strict):
    quantity: int = Field(ge=1)
    reason: str = Field(min_length=1, max_length=INVENTORY_EVENT_REASON_MAX_LENGTH)


class InventoryCountRequest(_Strict):
    quantity_on_hand: int = Field(ge=0)
    reason: str = Field(min_length=1, max_length=INVENTORY_EVENT_REASON_MAX_LENGTH)


class InventoryBalanceView(BaseModel):
    catalog_item_id: uuid.UUID
    quantity_on_hand: int
    reserved_quantity: int
    available_quantity: int
    updated_at: datetime


class InventoryEventView(BaseModel):
    event_id: uuid.UUID
    catalog_item_id: uuid.UUID
    actor_user_id: uuid.UUID
    kind: ConsumerCatalogInventoryEventKind
    quantity_delta: int
    quantity_on_hand_after: int
    reserved_quantity_after: int
    reason: str
    created_at: datetime


class InventoryEventListResponse(BaseModel):
    events: list[InventoryEventView]


class CatalogInventoryErrorResponse(BaseModel):
    code: str
    message: str


class ReservationMaintenanceStatusView(BaseModel):
    overdue_held_count: int
    oldest_overdue_expires_at: datetime | None
    last_run_finished_at: datetime | None
    last_run_outcome: str | None
    last_expired_count: int | None
    last_error_message: str | None


class ReservationMaintenanceRunView(BaseModel):
    expired_count: int
    status: ReservationMaintenanceStatusView
