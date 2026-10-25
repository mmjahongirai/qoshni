"""Location WP3 — authoritative onboarding branch coordinates.

Revision ID: b0a1f0170001
Revises: b0a1f0160001
Create Date: 2026-10-24 23:30:00.000000
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0170001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0160001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "business_onboarding_branch_coordinates",
        sa.Column("application_id", sa.Uuid(), nullable=False),
        sa.Column("latitude", sa.Float(), nullable=False),
        sa.Column("longitude", sa.Float(), nullable=False),
        sa.Column("coordinate_source", sa.String(length=32), nullable=False),
        sa.Column("verification_status", sa.String(length=16), nullable=False),
        sa.Column("revision", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("verified_revision", sa.Integer(), nullable=True),
        sa.Column("verified_by_user_id", sa.Uuid(), nullable=True),
        sa.Column("verified_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("proposed_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint("latitude >= -90.0 AND latitude <= 90.0", name="branch_coordinate_latitude_valid"),
        sa.CheckConstraint("longitude >= -180.0 AND longitude <= 180.0", name="branch_coordinate_longitude_valid"),
        sa.ForeignKeyConstraint(["application_id"], ["business_onboarding_applications.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("application_id"),
    )
    op.add_column(
        "search_index_records",
        sa.Column("branch_coordinate_revision", sa.Integer(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("search_index_records", "branch_coordinate_revision")
    op.drop_table("business_onboarding_branch_coordinates")
