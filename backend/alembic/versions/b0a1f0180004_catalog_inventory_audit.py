"""Phase 18 Closure WP3 — catalog inventory audit and maintenance runs.

Revision ID: b0a1f0180004
Revises: b0a1f0180003
Create Date: 2026-11-04 16:00:00.000000
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0180004"
down_revision: Union[str, Sequence[str], None] = "b0a1f0180003"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "consumer_catalog_inventory_events",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("catalog_item_id", sa.Uuid(), nullable=False),
        sa.Column("actor_user_id", sa.Uuid(), nullable=False),
        sa.Column("kind", sa.String(length=32), nullable=False),
        sa.Column("quantity_delta", sa.Integer(), nullable=False),
        sa.Column("quantity_on_hand_after", sa.Integer(), nullable=False),
        sa.Column("reserved_quantity_after", sa.Integer(), nullable=False),
        sa.Column("reason", sa.String(length=256), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "kind IN ('opened', 'replenished', 'count_corrected')",
            name="consumer_catalog_inventory_event_kind_valid",
        ),
        sa.CheckConstraint(
            "length(trim(reason)) > 0",
            name="consumer_catalog_inventory_event_reason_not_blank",
        ),
        sa.ForeignKeyConstraint(
            ["catalog_item_id"],
            ["consumer_catalog_items.id"],
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(["actor_user_id"], ["users.id"], ondelete="RESTRICT"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_consumer_catalog_inventory_events_catalog_item_id",
        "consumer_catalog_inventory_events",
        ["catalog_item_id"],
    )
    op.create_table(
        "inventory_maintenance_runs",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("worker_id", sa.String(length=64), nullable=False),
        sa.Column("outcome", sa.String(length=16), nullable=False),
        sa.Column("expired_count", sa.Integer(), nullable=False),
        sa.Column("error_message", sa.String(length=500), nullable=True),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("finished_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint(
            "outcome IN ('succeeded', 'failed')",
            name="inventory_maintenance_run_outcome_valid",
        ),
        sa.CheckConstraint(
            "expired_count >= 0",
            name="inventory_maintenance_run_expired_count_non_negative",
        ),
        sa.PrimaryKeyConstraint("id"),
    )


def downgrade() -> None:
    op.drop_table("inventory_maintenance_runs")
    op.drop_index(
        "ix_consumer_catalog_inventory_events_catalog_item_id",
        table_name="consumer_catalog_inventory_events",
    )
    op.drop_table("consumer_catalog_inventory_events")
