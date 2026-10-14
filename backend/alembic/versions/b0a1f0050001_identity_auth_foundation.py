"""Identity and authentication foundation.

Revision ID: b0a1f0050001
Revises: b0a1f0020001
Create Date: 2026-10-14 00:00:00.000000

Creates users, otp_challenges, auth_sessions, and auth_audit_events. Allowed
values are written literally so this revision does not change if application
enums evolve; later changes need their own revision.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "b0a1f0050001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0020001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _tz() -> sa.DateTime:
    return sa.DateTime(timezone=True)


def upgrade() -> None:
    """Upgrade schema."""

    op.create_table(
        "users",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("phone_e164", sa.String(length=16), nullable=False),
        sa.Column("phone_verified_at", _tz(), nullable=True),
        sa.Column("status", sa.String(length=16), server_default="pending", nullable=False),
        sa.Column("created_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.CheckConstraint(
            "status IN ('pending', 'active', 'suspended', 'disabled')",
            name=op.f("ck_users_status_valid"),
        ),
        sa.PrimaryKeyConstraint("id", name="pk_users"),
        sa.UniqueConstraint("phone_e164", name="uq_users_phone_e164"),
    )

    op.create_table(
        "otp_challenges",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("phone_e164", sa.String(length=16), nullable=False),
        sa.Column("purpose", sa.String(length=32), nullable=False),
        sa.Column("code_digest", sa.String(length=128), nullable=False),
        sa.Column("expires_at", _tz(), nullable=False),
        sa.Column("attempt_count", sa.Integer(), server_default="0", nullable=False),
        sa.Column("max_attempts", sa.Integer(), nullable=False),
        sa.Column("consumed_at", _tz(), nullable=True),
        sa.Column("created_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.CheckConstraint(
            "purpose IN ('sign_in', 'account_recovery')",
            name=op.f("ck_otp_challenges_purpose_valid"),
        ),
        sa.CheckConstraint(
            "attempt_count >= 0",
            name=op.f("ck_otp_challenges_attempt_count_non_negative"),
        ),
        sa.CheckConstraint(
            "max_attempts > 0",
            name=op.f("ck_otp_challenges_max_attempts_positive"),
        ),
        sa.CheckConstraint(
            "attempt_count <= max_attempts",
            name=op.f("ck_otp_challenges_attempts_within_limit"),
        ),
        sa.PrimaryKeyConstraint("id", name="pk_otp_challenges"),
    )
    op.create_index(
        "ix_otp_challenges_phone_e164_purpose_created_at",
        "otp_challenges",
        ["phone_e164", "purpose", "created_at"],
    )
    op.create_index("ix_otp_challenges_expires_at", "otp_challenges", ["expires_at"])

    op.create_table(
        "auth_sessions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("refresh_token_digest", sa.String(length=128), nullable=False),
        sa.Column("installation_id", sa.String(length=64), nullable=True),
        sa.Column("device_label", sa.String(length=64), nullable=True),
        sa.Column("device_platform", sa.String(length=16), nullable=True),
        sa.Column("created_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.Column("expires_at", _tz(), nullable=False),
        sa.Column("last_seen_at", _tz(), nullable=True),
        sa.Column("revoked_at", _tz(), nullable=True),
        sa.Column("revoked_reason", sa.String(length=32), nullable=True),
        sa.CheckConstraint(
            "device_platform IS NULL OR device_platform IN ('android', 'ios', 'web')",
            name=op.f("ck_auth_sessions_device_platform_valid"),
        ),
        sa.CheckConstraint(
            "revoked_reason IS NULL OR revoked_reason IN ('logout', 'revoked_by_user', "
            "'refresh_token_reuse', 'account_status_change', 'security_action')",
            name=op.f("ck_auth_sessions_revoked_reason_valid"),
        ),
        sa.CheckConstraint(
            "(revoked_at IS NULL) = (revoked_reason IS NULL)",
            name=op.f("ck_auth_sessions_revocation_consistent"),
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name="fk_auth_sessions_user_id_users",
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name="pk_auth_sessions"),
        sa.UniqueConstraint(
            "refresh_token_digest",
            name="uq_auth_sessions_refresh_token_digest",
        ),
    )
    op.create_index(
        "ix_auth_sessions_user_id_revoked_at",
        "auth_sessions",
        ["user_id", "revoked_at"],
    )
    op.create_index("ix_auth_sessions_expires_at", "auth_sessions", ["expires_at"])

    op.create_table(
        "auth_audit_events",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("event_type", sa.String(length=48), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=True),
        sa.Column("target_type", sa.String(length=32), nullable=True),
        sa.Column("target_id", sa.Uuid(), nullable=True),
        sa.Column("correlation_id", sa.String(length=64), nullable=True),
        sa.Column("details", sa.JSON(), nullable=True),
        sa.Column("occurred_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.CheckConstraint(
            "event_type IN ('otp_challenge_requested', 'otp_verification_failed', "
            "'otp_challenge_locked', 'otp_challenge_verified', 'identity_created', "
            "'session_created', 'session_refreshed', 'session_revoked', "
            "'refresh_token_reuse_detected')",
            name=op.f("ck_auth_audit_events_event_type_valid"),
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name="fk_auth_audit_events_user_id_users",
            ondelete="SET NULL",
        ),
        sa.PrimaryKeyConstraint("id", name="pk_auth_audit_events"),
    )
    op.create_index(
        "ix_auth_audit_events_user_id_occurred_at",
        "auth_audit_events",
        ["user_id", "occurred_at"],
    )
    op.create_index(
        "ix_auth_audit_events_event_type_occurred_at",
        "auth_audit_events",
        ["event_type", "occurred_at"],
    )


def downgrade() -> None:
    """Downgrade schema."""

    op.drop_index("ix_auth_audit_events_event_type_occurred_at", table_name="auth_audit_events")
    op.drop_index("ix_auth_audit_events_user_id_occurred_at", table_name="auth_audit_events")
    op.drop_table("auth_audit_events")

    op.drop_index("ix_auth_sessions_expires_at", table_name="auth_sessions")
    op.drop_index("ix_auth_sessions_user_id_revoked_at", table_name="auth_sessions")
    op.drop_table("auth_sessions")

    op.drop_index("ix_otp_challenges_expires_at", table_name="otp_challenges")
    op.drop_index("ix_otp_challenges_phone_e164_purpose_created_at", table_name="otp_challenges")
    op.drop_table("otp_challenges")

    op.drop_table("users")
