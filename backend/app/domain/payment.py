"""Payment and wallet-hold vocabulary (Phase 19 WP2).

A payment hold is not an order status and not an inventory reservation.
Settlement and refund are later work.
"""

from __future__ import annotations

from enum import StrEnum


class PaymentStatus(StrEnum):
    PENDING = "pending"
    HELD = "held"
    FAILED = "failed"
    RELEASED = "released"


class PaymentMethod(StrEnum):
    WALLET = "wallet"


class WalletHoldStatus(StrEnum):
    ACTIVE = "active"
    RELEASED = "released"
    CONSUMED = "consumed"


class PaymentErrorCode(StrEnum):
    VALIDATION_FAILED = "validation_failed"
    ORDER_NOT_FOUND = "order_not_found"
    ORDER_NOT_PAYABLE = "order_not_payable"
    PAYMENT_ALREADY_EXISTS = "payment_already_exists"
    INSUFFICIENT_BALANCE = "insufficient_balance"
    IDEMPOTENCY_CONFLICT = "idempotency_conflict"
    CURRENCY_MISMATCH = "currency_mismatch"
    WALLET_NOT_FOUND = "wallet_not_found"
    BUSINESS_WALLET_UNAVAILABLE = "business_wallet_unavailable"
    PAYMENT_NOT_FOUND = "payment_not_found"


PAYMENT_OPERATION = "create_payment"
PAYMENT_HOLD_REASON = "payment_hold"
