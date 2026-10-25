"""Place-order request/response contracts."""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.api.schemas.checkout_preparation import CheckoutCartLineRequest
from app.domain.checkout_fulfillment import CheckoutFulfillmentType
from app.domain.order_lifecycle import (
    ConsumerOrderFulfillmentStatus,
    ConsumerOrderPaymentStatus,
    ConsumerOrderStatus,
)


class PlaceOrderRequest(BaseModel):
    fulfillment_type: CheckoutFulfillmentType
    checkout_correlation_id: str = Field(min_length=1, max_length=128)
    server_quote_id: str | None = Field(default=None, max_length=128)
    server_quote_revision: int | None = Field(default=None, ge=0)
    lines: list[CheckoutCartLineRequest] = Field(min_length=1)
    client_submitted_total_minor: int | None = Field(default=None, ge=0)


class OrderLineSnapshotView(BaseModel):
    business_stable_id: str
    catalog_item_stable_id: str
    title_snapshot: str
    quantity: int
    unit_price_minor: int
    line_subtotal_minor: int
    currency_code: str


class PlaceOrderResponse(BaseModel):
    order_id: uuid.UUID
    status: ConsumerOrderStatus
    payment_status: ConsumerOrderPaymentStatus
    fulfillment_status: ConsumerOrderFulfillmentStatus
    currency_code: str
    subtotal_minor: int
    total_minor: int
    checkout_correlation_id: str
    lines: list[OrderLineSnapshotView]
    idempotent_replay: bool
    created_at: datetime


class OrderPlacementErrorResponse(BaseModel):
    code: str
    message: str
