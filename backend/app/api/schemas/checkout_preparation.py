"""Typed checkout preparation contract (catalog authority not yet available)."""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.domain.checkout_fulfillment import CheckoutFulfillmentType
from app.domain.checkout_limits import (
    CHECKOUT_MAX_DISTINCT_LINES,
    CHECKOUT_MAX_LINE_QUANTITY,
    CHECKOUT_MIN_LINE_QUANTITY,
)


class CheckoutCartLineRequest(BaseModel):
    business_stable_id: str = Field(min_length=1, max_length=128)
    catalog_item_stable_id: str = Field(min_length=1, max_length=128)
    quantity: int = Field(
        ge=CHECKOUT_MIN_LINE_QUANTITY,
        le=CHECKOUT_MAX_LINE_QUANTITY,
    )


class CheckoutPrepareRequest(BaseModel):
    fulfillment_type: CheckoutFulfillmentType
    cart_revision: int | None = Field(default=None, ge=0)
    lines: list[CheckoutCartLineRequest] = Field(
        min_length=1,
        max_length=CHECKOUT_MAX_DISTINCT_LINES,
    )
    client_submitted_total_minor: int | None = Field(default=None, ge=0)


class CheckoutPrepareUnavailableResponse(BaseModel):
    code: str
    message: str


class CheckoutPrepareValidationErrorResponse(BaseModel):
    code: str
    message: str


class CheckoutPreparedLineView(BaseModel):
    business_stable_id: str
    catalog_item_stable_id: str
    quantity: int
    unit_price_minor: int
    line_subtotal_minor: int
    currency_code: str
    title_snapshot: str


class CheckoutPrepareSuccessResponse(BaseModel):
    session_correlation_id: str
    quoted_at: datetime
    currency_code: str
    subtotal_minor: int
    discount_minor: int
    delivery_fee_minor: int
    tax_minor: int
    total_minor: int
    lines: list[CheckoutPreparedLineView]
    cart_revision: int | None = None
    is_demo_pricing: bool = False


def new_checkout_correlation_id() -> str:
    return f"chk-{uuid.uuid4()}"
