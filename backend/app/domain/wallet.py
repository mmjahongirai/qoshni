"""Wallet and ledger vocabulary (Phase 19 WP1).

Money amounts are integer minor units. Debit decreases a balance account
(available, hold, pending). Credit increases it. Clearing legs do not change
those three balances; they exist so every posting can balance.

Renaming a persisted member requires a migration.
"""

from __future__ import annotations

import uuid
from enum import StrEnum


AUTHORITATIVE_CURRENCY = "UZS"
PLATFORM_WALLET_OWNER_ID = uuid.UUID("00000000-0000-4000-8000-000000000019")
PLATFORM_WALLET_ID = uuid.UUID("00000000-0000-4000-8000-00000000001a")


class WalletOwnerType(StrEnum):
    USER = "user"
    BUSINESS_APPLICATION = "business_application"
    PLATFORM = "platform"


class WalletStatus(StrEnum):
    ACTIVE = "active"
    FROZEN = "frozen"


class LedgerAccountType(StrEnum):
    AVAILABLE = "available"
    HOLD = "hold"
    PENDING = "pending"
    CLEARING = "clearing"


class LedgerDirection(StrEnum):
    DEBIT = "debit"
    CREDIT = "credit"


class LedgerTransactionStatus(StrEnum):
    COMPLETED = "completed"


class LedgerImmutableError(RuntimeError):
    """Raised when application code tries to change a ledger row."""
