"""Private business onboarding document metadata foundation.

Revision ID: b0a1f0100001
Revises: b0a1f0090001
Create Date: 2026-10-15 14:40:00.000000

Creates business_onboarding_documents for opaque storage keys and lifecycle
metadata. No blob columns or public URLs.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "b0a1f0100001"
down_revision: Union[str, Sequence[str], None] = "b0a1f0090001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_DOCUMENT_TYPES = (
    "registration_certificate",
    "tax_registration",
    "authorized_representative_id",
    "other_supporting",
)
_LIFECYCLE_STATES = (
    "awaiting_upload",
    "uploaded_pending_validation",
    "quarantined",
    "rejected",
    "accepted_for_review",
    "deleted",
)


def _tz() -> sa.DateTime:
    return sa.DateTime(timezone=True)


def _in_list(column: str, values: tuple[str, ...]) -> str:
    joined = ", ".join(f"'{value}'" for value in values)
    return f"{column} IN ({joined})"


def upgrade() -> None:
    op.create_table(
        "business_onboarding_documents",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("application_id", sa.Uuid(), nullable=False),
        sa.Column("uploaded_by_user_id", sa.Uuid(), nullable=False),
        sa.Column("document_type", sa.String(length=48), nullable=False),
        sa.Column("storage_object_key", sa.String(length=512), nullable=False),
        sa.Column(
            "lifecycle_state",
            sa.String(length=48),
            server_default="awaiting_upload",
            nullable=False,
        ),
        sa.Column("declared_content_type", sa.String(length=128), nullable=True),
        sa.Column("byte_size", sa.Integer(), nullable=True),
        sa.Column("checksum_sha256", sa.String(length=64), nullable=True),
        sa.Column("created_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", _tz(), server_default=sa.func.now(), nullable=False),
        sa.CheckConstraint(
            _in_list("document_type", _DOCUMENT_TYPES),
            name=op.f("ck_business_onboarding_documents_document_type_valid"),
        ),
        sa.CheckConstraint(
            _in_list("lifecycle_state", _LIFECYCLE_STATES),
            name=op.f("ck_business_onboarding_documents_lifecycle_state_valid"),
        ),
        sa.CheckConstraint(
            "length(trim(storage_object_key)) > 0",
            name=op.f("ck_business_onboarding_documents_storage_object_key_not_blank"),
        ),
        sa.CheckConstraint(
            "storage_object_key = trim(storage_object_key)",
            name=op.f("ck_business_onboarding_documents_storage_object_key_trimmed"),
        ),
        sa.CheckConstraint(
            "byte_size IS NULL OR byte_size >= 0",
            name=op.f("ck_business_onboarding_documents_byte_size_non_negative"),
        ),
        sa.CheckConstraint(
            "checksum_sha256 IS NULL OR length(checksum_sha256) = 64",
            name=op.f("ck_business_onboarding_documents_checksum_sha256_length"),
        ),
        sa.ForeignKeyConstraint(
            ["application_id"],
            ["business_onboarding_applications.id"],
            name=op.f("fk_business_onboarding_documents_application_id_business_onboarding_applications"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["uploaded_by_user_id"],
            ["users.id"],
            name=op.f("fk_business_onboarding_documents_uploaded_by_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_business_onboarding_documents")),
        sa.UniqueConstraint(
            "storage_object_key",
            name=op.f("uq_business_onboarding_documents_storage_object_key"),
        ),
    )
    op.create_index(
        op.f("ix_business_onboarding_documents_application_id_created_at"),
        "business_onboarding_documents",
        ["application_id", "created_at"],
    )
    op.create_index(
        op.f("ix_business_onboarding_documents_uploaded_by_user_id"),
        "business_onboarding_documents",
        ["uploaded_by_user_id"],
    )


def downgrade() -> None:
    op.drop_index(
        op.f("ix_business_onboarding_documents_uploaded_by_user_id"),
        table_name="business_onboarding_documents",
    )
    op.drop_index(
        op.f("ix_business_onboarding_documents_application_id_created_at"),
        table_name="business_onboarding_documents",
    )
    op.drop_table("business_onboarding_documents")
