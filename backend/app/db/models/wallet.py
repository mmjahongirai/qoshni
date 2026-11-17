"""Wallets and an append-only double-entry ledger (Phase 19 WP1).

Balances are a materialized cache of ledger entries. Ledger rows have no
update timestamp and application listeners reject UPDATE and DELETE.
"""

from __future__ import annotations

import uuid
from datetime import datetime
from enum import StrEnum
from typing import Any

from sqlalchemy import (
    JSON,
    BigInteger,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    String,
    UniqueConstraint,
    Uuid,
    event,
    func,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.domain.wallet import (
    LedgerAccountType,
    LedgerDirection,
    LedgerImmutableError,
    LedgerTransactionStatus,
    WalletOwnerType,
    WalletStatus,
)


def _in_values(column: str, enum_type: type[StrEnum]) -> str:
    values = ", ".join(f"'{member.value}'" for member in enum_type)
    return f"{column} IN ({values})"


class Wallet(Base):
    """One currency bucket for a user, a verified onboarding application, or the platform."""

    __tablename__ = "wallets"
    __table_args__ = (
        UniqueConstraint(
            "owner_type",
            "owner_id",
            "currency_code",
            name="uq_wallets_owner_currency",
        ),
        CheckConstraint(_in_values("owner_type", WalletOwnerType), name="wallet_owner_type_valid"),
        CheckConstraint(_in_values("status", WalletStatus), name="wallet_status_valid"),
        CheckConstraint(
            "length(currency_code) = 3 AND currency_code = upper(currency_code)",
            name="wallet_currency_code_iso",
        ),
        CheckConstraint("available_minor >= 0", name="wallet_available_non_negative"),
        CheckConstraint("hold_minor >= 0", name="wallet_hold_non_negative"),
        CheckConstraint("pending_minor >= 0", name="wallet_pending_non_negative"),
        Index(
            "uq_wallets_platform_currency",
            "currency_code",
            unique=True,
            sqlite_where=text("owner_type = 'platform'"),
            postgresql_where=text("owner_type = 'platform'"),
        ),
        Index("ix_wallets_owner", "owner_type", "owner_id"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    owner_type: Mapped[str] = mapped_column(String(32), nullable=False)
    owner_id: Mapped[uuid.UUID] = mapped_column(Uuid, nullable=False)
    currency_code: Mapped[str] = mapped_column(String(3), nullable=False)
    available_minor: Mapped[int] = mapped_column(BigInteger, nullable=False)
    hold_minor: Mapped[int] = mapped_column(BigInteger, nullable=False)
    pending_minor: Mapped[int] = mapped_column(BigInteger, nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    ledger_entries: Mapped[list[LedgerEntry]] = relationship(back_populates="wallet")


class LedgerTransaction(Base):
    """Header for one completed, balanced set of ledger entries."""

    __tablename__ = "ledger_transactions"
    __table_args__ = (
        CheckConstraint(
            _in_values("status", LedgerTransactionStatus),
            name="ledger_transaction_status_valid",
        ),
        CheckConstraint(
            "length(currency_code) = 3 AND currency_code = upper(currency_code)",
            name="ledger_transaction_currency_code_iso",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    currency_code: Mapped[str] = mapped_column(String(3), nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False)
    reference: Mapped[str | None] = mapped_column(String(128), nullable=True)
    details: Mapped[dict[str, Any] | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    entries: Mapped[list[LedgerEntry]] = relationship(back_populates="transaction")


class LedgerEntry(Base):
    """Immutable debit or credit. Amount is always a positive integer."""

    __tablename__ = "ledger_entries"
    __table_args__ = (
        CheckConstraint(_in_values("account_type", LedgerAccountType), name="ledger_entry_account_valid"),
        CheckConstraint(_in_values("direction", LedgerDirection), name="ledger_entry_direction_valid"),
        CheckConstraint("amount_minor > 0", name="ledger_entry_amount_positive"),
        CheckConstraint(
            "length(currency_code) = 3 AND currency_code = upper(currency_code)",
            name="ledger_entry_currency_code_iso",
        ),
        Index("ix_ledger_entries_wallet_id", "wallet_id"),
        Index("ix_ledger_entries_ledger_transaction_id", "ledger_transaction_id"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    ledger_transaction_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("ledger_transactions.id", ondelete="RESTRICT"),
        nullable=False,
    )
    wallet_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("wallets.id", ondelete="RESTRICT"),
        nullable=False,
    )
    account_type: Mapped[str] = mapped_column(String(16), nullable=False)
    direction: Mapped[str] = mapped_column(String(8), nullable=False)
    amount_minor: Mapped[int] = mapped_column(BigInteger, nullable=False)
    currency_code: Mapped[str] = mapped_column(String(3), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    transaction: Mapped[LedgerTransaction] = relationship(back_populates="entries")
    wallet: Mapped[Wallet] = relationship(back_populates="ledger_entries")


def _reject_ledger_mutation(_mapper: object, _connection: object, _target: object) -> None:
    raise LedgerImmutableError("Ledger rows cannot be updated or deleted.")


event.listen(LedgerTransaction, "before_update", _reject_ledger_mutation)
event.listen(LedgerTransaction, "before_delete", _reject_ledger_mutation)
event.listen(LedgerEntry, "before_update", _reject_ledger_mutation)
event.listen(LedgerEntry, "before_delete", _reject_ledger_mutation)
