"""Read models for wallet balances. Clients do not submit amounts."""

from __future__ import annotations

import uuid

from pydantic import BaseModel

from app.domain.wallet import WalletOwnerType, WalletStatus


class WalletView(BaseModel):
    wallet_id: uuid.UUID
    owner_type: WalletOwnerType
    owner_id: uuid.UUID
    currency_code: str
    available_minor: int
    hold_minor: int
    pending_minor: int
    status: WalletStatus


class WalletErrorResponse(BaseModel):
    code: str
    message: str
