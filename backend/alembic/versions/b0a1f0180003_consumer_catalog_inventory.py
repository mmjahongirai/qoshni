"""Phase 18 Closure WP2 — database-backed catalog inventory balances.

Revision ID: b0a1f0180003
Revises: b0a1f0180002
Create Date: 2026-11-04 11:00:00.000000

One balance row per catalog item. Quantities have no server default: absence of a
row means stock is not authoritative. ``reserved_quantity <= quantity_on_hand``
keeps available units (on hand minus reserved) non-negative.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0180003"
down_revision: Union[str, Sequence[str], None] = "b0a1f0180002"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "consumer_catalog_inventory",
        sa.Column("catalog_item_id", sa.Uuid(), nullable=False),
        sa.Column("quantity_on_hand", sa.Integer(), nullable=False),
        sa.Column("reserved_quantity", sa.Integer(), nullable=False),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "quantity_on_hand >= 0",
            name="consumer_catalog_inventory_on_hand_non_negative",
        ),
        sa.CheckConstraint(
            "reserved_quantity >= 0",
            name="consumer_catalog_inventory_reserved_non_negative",
        ),
        sa.CheckConstraint(
            "reserved_quantity <= quantity_on_hand",
            name="consumer_catalog_inventory_reserved_within_on_hand",
        ),
        sa.ForeignKeyConstraint(
            ["catalog_item_id"],
            ["consumer_catalog_items.id"],
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("catalog_item_id"),
    )


def downgrade() -> None:
    op.drop_table("consumer_catalog_inventory")
