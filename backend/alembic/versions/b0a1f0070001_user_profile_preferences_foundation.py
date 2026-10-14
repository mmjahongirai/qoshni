"""User profile and explicit preferences foundation.

Revision ID: b0a1f0070001
Revises: b0a1f0060001
Create Date: 2026-10-14 14:00:00.000000

Creates user_profiles and user_preferences with one row per user enforced by
unique user_id constraints. Locale codes are written literally so this revision
does not change if application enums evolve.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0070001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0060001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _tz() -> sa.DateTime:
    return sa.DateTime(timezone=True)


def upgrade() -> None:
    op.create_table(
        "user_profiles",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("display_name", sa.String(length=64), nullable=True),
        sa.Column("avatar_storage_ref", sa.String(length=512), nullable=True),
        sa.Column("created_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.CheckConstraint(
            "display_name IS NULL OR length(trim(display_name)) > 0",
            name=op.f("ck_user_profiles_display_name_not_blank"),
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_user_profiles_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_user_profiles")),
        sa.UniqueConstraint("user_id", name=op.f("uq_user_profiles_user_id")),
    )

    op.create_table(
        "user_preferences",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column(
            "preferred_language",
            sa.String(length=8),
            server_default="en",
            nullable=False,
        ),
        sa.Column(
            "personalization_enabled",
            sa.Boolean(),
            server_default="0",
            nullable=False,
        ),
        sa.Column("created_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.CheckConstraint(
            "preferred_language IN ('en', 'ru', 'uz')",
            name=op.f("ck_user_preferences_preferred_language_valid"),
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_user_preferences_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_user_preferences")),
        sa.UniqueConstraint("user_id", name=op.f("uq_user_preferences_user_id")),
    )


def downgrade() -> None:
    op.drop_table("user_preferences")
    op.drop_table("user_profiles")
