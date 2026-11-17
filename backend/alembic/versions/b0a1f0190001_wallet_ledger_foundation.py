"""Phase 19 WP1 — wallets and an immutable double-entry ledger.

Revision ID: b0a1f0190001
Revises: b0a1f0180004
Create Date: 2026-11-06 11:10:00.000000

Creates ``wallets``, ``ledger_transactions``, and ``ledger_entries``.
Inserts the single platform UZS wallet. Ledger rows are append-only at the
application boundary; this migration does not grant an update path.
"""

from typing import Sequence, Union
import uuid

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0190001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0180004"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_PLATFORM_WALLET_ID = uuid.UUID("00000000-0000-4000-8000-00000000001a")
_PLATFORM_OWNER_ID = uuid.UUID("00000000-0000-4000-8000-000000000019")
_PLATFORM_WHERE = "owner_type = 'platform'"


def upgrade() -> None:
    op.create_table(
        "wallets",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("owner_type", sa.String(length=32), nullable=False),
        sa.Column("owner_id", sa.Uuid(), nullable=False),
        sa.Column("currency_code", sa.String(length=3), nullable=False),
        sa.Column("available_minor", sa.BigInteger(), nullable=False),
        sa.Column("hold_minor", sa.BigInteger(), nullable=False),
        sa.Column("pending_minor", sa.BigInteger(), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "owner_type IN ('user', 'business_application', 'platform')",
            name="wallet_owner_type_valid",
        ),
        sa.CheckConstraint("status IN ('active', 'frozen')", name="wallet_status_valid"),
        sa.CheckConstraint(
            "length(currency_code) = 3 AND currency_code = upper(currency_code)",
            name="wallet_currency_code_iso",
        ),
        sa.CheckConstraint("available_minor >= 0", name="wallet_available_non_negative"),
        sa.CheckConstraint("hold_minor >= 0", name="wallet_hold_non_negative"),
        sa.CheckConstraint("pending_minor >= 0", name="wallet_pending_non_negative"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "owner_type",
            "owner_id",
            "currency_code",
            name="uq_wallets_owner_currency",
        ),
    )
    op.create_index("ix_wallets_owner", "wallets", ["owner_type", "owner_id"])
    op.create_index(
        "uq_wallets_platform_currency",
        "wallets",
        ["currency_code"],
        unique=True,
        postgresql_where=sa.text(_PLATFORM_WHERE),
        sqlite_where=sa.text(_PLATFORM_WHERE),
    )
    op.create_table(
        "ledger_transactions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("currency_code", sa.String(length=3), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("reference", sa.String(length=128), nullable=True),
        sa.Column("details", sa.JSON(), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.CheckConstraint("status IN ('completed')", name="ledger_transaction_status_valid"),
        sa.CheckConstraint(
            "length(currency_code) = 3 AND currency_code = upper(currency_code)",
            name="ledger_transaction_currency_code_iso",
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_table(
        "ledger_entries",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("ledger_transaction_id", sa.Uuid(), nullable=False),
        sa.Column("wallet_id", sa.Uuid(), nullable=False),
        sa.Column("account_type", sa.String(length=16), nullable=False),
        sa.Column("direction", sa.String(length=8), nullable=False),
        sa.Column("amount_minor", sa.BigInteger(), nullable=False),
        sa.Column("currency_code", sa.String(length=3), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "account_type IN ('available', 'hold', 'pending', 'clearing')",
            name="ledger_entry_account_valid",
        ),
        sa.CheckConstraint("direction IN ('debit', 'credit')", name="ledger_entry_direction_valid"),
        sa.CheckConstraint("amount_minor > 0", name="ledger_entry_amount_positive"),
        sa.CheckConstraint(
            "length(currency_code) = 3 AND currency_code = upper(currency_code)",
            name="ledger_entry_currency_code_iso",
        ),
        sa.ForeignKeyConstraint(
            ["ledger_transaction_id"],
            ["ledger_transactions.id"],
            ondelete="RESTRICT",
        ),
        sa.ForeignKeyConstraint(["wallet_id"], ["wallets.id"], ondelete="RESTRICT"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_ledger_entries_wallet_id", "ledger_entries", ["wallet_id"])
    op.create_index(
        "ix_ledger_entries_ledger_transaction_id",
        "ledger_entries",
        ["ledger_transaction_id"],
    )
    wallets = sa.table(
        "wallets",
        sa.column("id", sa.Uuid()),
        sa.column("owner_type", sa.String()),
        sa.column("owner_id", sa.Uuid()),
        sa.column("currency_code", sa.String()),
        sa.column("available_minor", sa.BigInteger()),
        sa.column("hold_minor", sa.BigInteger()),
        sa.column("pending_minor", sa.BigInteger()),
        sa.column("status", sa.String()),
    )
    op.bulk_insert(
        wallets,
        [
            {
                "id": _PLATFORM_WALLET_ID,
                "owner_type": "platform",
                "owner_id": _PLATFORM_OWNER_ID,
                "currency_code": "UZS",
                "available_minor": 0,
                "hold_minor": 0,
                "pending_minor": 0,
                "status": "active",
            }
        ],
    )


def downgrade() -> None:
    op.drop_index("ix_ledger_entries_ledger_transaction_id", table_name="ledger_entries")
    op.drop_index("ix_ledger_entries_wallet_id", table_name="ledger_entries")
    op.drop_table("ledger_entries")
    op.drop_table("ledger_transactions")
    op.drop_index("uq_wallets_platform_currency", table_name="wallets")
    op.drop_index("ix_wallets_owner", table_name="wallets")
    op.drop_table("wallets")
