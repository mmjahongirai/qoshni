"""Store opaque access-token digests on auth sessions.

Revision ID: b0a1f0060001
Revises: b0a1f0050001
Create Date: 2026-10-14 12:00:00.000000
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0060001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0050001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _tz() -> sa.DateTime:
    return sa.DateTime(timezone=True)


def upgrade() -> None:
    with op.batch_alter_table("auth_sessions", schema=None) as batch_op:
        batch_op.add_column(
            sa.Column("access_token_digest", sa.String(length=128), nullable=True),
        )
        batch_op.add_column(
            sa.Column("access_token_expires_at", _tz(), nullable=True),
        )

    op.execute(
        sa.text(
            "UPDATE auth_sessions SET access_token_digest = refresh_token_digest, "
            "access_token_expires_at = expires_at WHERE access_token_digest IS NULL",
        ),
    )

    with op.batch_alter_table("auth_sessions", schema=None) as batch_op:
        batch_op.alter_column("access_token_digest", nullable=False)
        batch_op.alter_column("access_token_expires_at", nullable=False)
        batch_op.create_unique_constraint(
            "uq_auth_sessions_access_token_digest",
            ["access_token_digest"],
        )


def downgrade() -> None:
    with op.batch_alter_table("auth_sessions", schema=None) as batch_op:
        batch_op.drop_constraint("uq_auth_sessions_access_token_digest", type_="unique")
        batch_op.drop_column("access_token_expires_at")
        batch_op.drop_column("access_token_digest")
