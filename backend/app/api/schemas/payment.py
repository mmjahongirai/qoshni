"""Payment read models. The client does not submit an amount."""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict

from app.domain.payment import PaymentMethod, PaymentStatus, WalletHoldStatus


class _Strict(BaseModel):
    model_config = ConfigDict(extra="forbid")


class CreatePaymentRequest(_Strict):
    order_id: uuid.UUID
    payment_method: PaymentMethod


class PaymentView(BaseModel):
    payment_id: uuid.UUID
    order_id: uuid.UUID
    amount_minor: int
    currency_code: str
    status: PaymentStatus
    hold_id: uuid.UUID
    created_at: datetime
    idempotent_replay: bool


class WalletHoldView(BaseModel):
    hold_id: uuid.UUID
    payment_id: uuid.UUID
    order_id: uuid.UUID
    wallet_id: uuid.UUID
    amount_minor: int
    currency_code: str
    status: WalletHoldStatus
    reason: str
    created_at: datetime


class WalletHoldListResponse(BaseModel):
    holds: list[WalletHoldView]


class PaymentErrorResponse(BaseModel):
    code: str
    message: str
