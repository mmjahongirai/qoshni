"""Post a balanced ledger movement and refresh materialized wallet balances.

PostgreSQL locks each touched wallet with ``SELECT … FOR UPDATE`` before the
balance is changed. Other dialects, including the SQLite test database, apply
one conditional ``UPDATE`` per wallet (``balance + delta >= 0``). A failed
posting rolls back its savepoint, so neither balances nor ledger rows remain.
SQLite coverage does not verify PostgreSQL row-lock concurrency.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from enum import StrEnum

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.db.models.wallet import LedgerEntry, LedgerTransaction, Wallet
from app.domain.wallet import (
    AUTHORITATIVE_CURRENCY,
    LedgerAccountType,
    LedgerDirection,
    LedgerTransactionStatus,
)


class WalletPostingErrorCode(StrEnum):
    VALIDATION_FAILED = "validation_failed"
    UNBALANCED_LEDGER = "unbalanced_ledger"
    WALLET_NOT_FOUND = "wallet_not_found"
    CURRENCY_MISMATCH = "currency_mismatch"
    INSUFFICIENT_BALANCE = "insufficient_balance"


@dataclass(frozen=True, slots=True)
class WalletPostingError:
    code: WalletPostingErrorCode
    message: str


@dataclass(frozen=True, slots=True)
class LedgerLeg:
    wallet_id: uuid.UUID
    account_type: LedgerAccountType
    direction: LedgerDirection
    amount_minor: int


@dataclass(frozen=True, slots=True)
class ReconciledBalance:
    available_minor: int
    hold_minor: int
    pending_minor: int


def _positive_amount(amount: object) -> bool:
    return isinstance(amount, int) and not isinstance(amount, bool) and amount > 0


def _validate(currency_code: str, legs: list[LedgerLeg]) -> WalletPostingError | None:
    if currency_code != AUTHORITATIVE_CURRENCY:
        return WalletPostingError(
            code=WalletPostingErrorCode.CURRENCY_MISMATCH,
            message="This posting currency is not authoritative.",
        )
    if len(legs) < 2:
        return WalletPostingError(
            code=WalletPostingErrorCode.UNBALANCED_LEDGER,
            message="A ledger posting needs both a debit and a credit.",
        )
    debit = 0
    credit = 0
    for leg in legs:
        if not _positive_amount(leg.amount_minor):
            return WalletPostingError(
                code=WalletPostingErrorCode.VALIDATION_FAILED,
                message="Ledger amounts must be positive integers.",
            )
        if leg.direction is LedgerDirection.DEBIT:
            debit += leg.amount_minor
        elif leg.direction is LedgerDirection.CREDIT:
            credit += leg.amount_minor
        else:
            return WalletPostingError(
                code=WalletPostingErrorCode.VALIDATION_FAILED,
                message="Ledger direction is invalid.",
            )
    if debit != credit or debit == 0:
        return WalletPostingError(
            code=WalletPostingErrorCode.UNBALANCED_LEDGER,
            message="Ledger debits and credits must be equal and non-zero.",
        )
    return None


def _effects(legs: list[LedgerLeg]) -> dict[uuid.UUID, tuple[int, int, int]]:
    """Net change to available, hold, and pending. Debit reduces those accounts."""

    totals: dict[uuid.UUID, list[int]] = {}
    for leg in legs:
        bucket = totals.setdefault(leg.wallet_id, [0, 0, 0])
        if leg.account_type is LedgerAccountType.CLEARING:
            continue
        sign = -1 if leg.direction is LedgerDirection.DEBIT else 1
        index = {
            LedgerAccountType.AVAILABLE: 0,
            LedgerAccountType.HOLD: 1,
            LedgerAccountType.PENDING: 2,
        }[leg.account_type]
        bucket[index] += sign * leg.amount_minor
    return {wallet_id: (values[0], values[1], values[2]) for wallet_id, values in totals.items()}


def _locks_rows(session: Session) -> bool:
    return session.get_bind().dialect.name == "postgresql"


def _load_wallets(session: Session, wallet_ids: list[uuid.UUID]) -> list[Wallet]:
    statement = select(Wallet).where(Wallet.id.in_(wallet_ids)).order_by(Wallet.id)
    if _locks_rows(session):
        statement = statement.with_for_update()
    return list(session.scalars(statement))


def post_balanced_movement(
    session: Session,
    *,
    currency_code: str,
    legs: list[LedgerLeg],
    reference: str | None = None,
) -> LedgerTransaction | WalletPostingError:
    """Apply one balanced posting. Failure leaves balances and the ledger unchanged."""

    invalid = _validate(currency_code, legs)
    if invalid is not None:
        return invalid

    effects = _effects(legs)
    savepoint = session.begin_nested()
    try:
        wallets = _load_wallets(session, sorted(effects))
        by_id = {wallet.id: wallet for wallet in wallets}
        if set(by_id) != set(effects):
            savepoint.rollback()
            return WalletPostingError(
                code=WalletPostingErrorCode.WALLET_NOT_FOUND,
                message="Wallet not found.",
            )
        for wallet in wallets:
            if wallet.currency_code != currency_code:
                savepoint.rollback()
                return WalletPostingError(
                    code=WalletPostingErrorCode.CURRENCY_MISMATCH,
                    message="Wallet currency does not match the posting.",
                )

        now = datetime.now(UTC)
        if _locks_rows(session):
            for wallet in wallets:
                available_delta, hold_delta, pending_delta = effects[wallet.id]
                if (
                    wallet.available_minor + available_delta < 0
                    or wallet.hold_minor + hold_delta < 0
                    or wallet.pending_minor + pending_delta < 0
                ):
                    savepoint.rollback()
                    return WalletPostingError(
                        code=WalletPostingErrorCode.INSUFFICIENT_BALANCE,
                        message="The wallet balance cannot cover this posting.",
                    )
                wallet.available_minor += available_delta
                wallet.hold_minor += hold_delta
                wallet.pending_minor += pending_delta
                wallet.updated_at = now
        else:
            for wallet_id, (available_delta, hold_delta, pending_delta) in effects.items():
                result = session.execute(
                    update(Wallet)
                    .where(
                        Wallet.id == wallet_id,
                        Wallet.currency_code == currency_code,
                        Wallet.available_minor + available_delta >= 0,
                        Wallet.hold_minor + hold_delta >= 0,
                        Wallet.pending_minor + pending_delta >= 0,
                    )
                    .values(
                        available_minor=Wallet.available_minor + available_delta,
                        hold_minor=Wallet.hold_minor + hold_delta,
                        pending_minor=Wallet.pending_minor + pending_delta,
                        updated_at=now,
                    )
                )
                if result.rowcount != 1:
                    savepoint.rollback()
                    return WalletPostingError(
                        code=WalletPostingErrorCode.INSUFFICIENT_BALANCE,
                        message="The wallet balance cannot cover this posting.",
                    )
            for wallet in wallets:
                session.expire(wallet)

        header = LedgerTransaction(
            currency_code=currency_code,
            status=LedgerTransactionStatus.COMPLETED.value,
            reference=reference,
        )
        session.add(header)
        session.flush()
        for leg in legs:
            session.add(
                LedgerEntry(
                    ledger_transaction_id=header.id,
                    wallet_id=leg.wallet_id,
                    account_type=leg.account_type.value,
                    direction=leg.direction.value,
                    amount_minor=leg.amount_minor,
                    currency_code=currency_code,
                )
            )
        session.flush()
        savepoint.commit()
        return header
    except Exception:
        if savepoint.is_active:
            savepoint.rollback()
        raise


def balances_from_ledger(session: Session, wallet_id: uuid.UUID) -> ReconciledBalance:
    """Rebuild the three balances from immutable entries. Clearing is excluded."""

    available = 0
    hold = 0
    pending = 0
    entries = session.scalars(select(LedgerEntry).where(LedgerEntry.wallet_id == wallet_id)).all()
    for entry in entries:
        account = LedgerAccountType(entry.account_type)
        if account is LedgerAccountType.CLEARING:
            continue
        sign = -1 if entry.direction == LedgerDirection.DEBIT.value else 1
        amount = sign * entry.amount_minor
        if account is LedgerAccountType.AVAILABLE:
            available += amount
        elif account is LedgerAccountType.HOLD:
            hold += amount
        else:
            pending += amount
    return ReconciledBalance(
        available_minor=available,
        hold_minor=hold,
        pending_minor=pending,
    )
