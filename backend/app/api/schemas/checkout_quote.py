"""Server checkout quote responses."""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel

from app.api.schemas.checkout_preparation import CheckoutPrepareRequest


class CheckoutQuoteIssueRequest(CheckoutPrepareRequest):
    cart_revision: int | None = None


class CheckoutQuoteIssueResponse(BaseModel):
    quote_id: uuid.UUID
    pricing_revision: int
    expires_at: datetime
    currency_code: str
    total_minor: int
