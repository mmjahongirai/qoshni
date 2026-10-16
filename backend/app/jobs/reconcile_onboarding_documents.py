"""Dry-run reconciliation for onboarding document DB/storage consistency."""

from __future__ import annotations

import argparse
import json
import sys

from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.database import get_engine
from app.services.business_onboarding.reconciliation_service import (
    reconcile_onboarding_documents_dry_run,
)
from app.services.object_storage.errors import StorageConfigurationError
from app.services.object_storage.factory import create_object_storage


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Compare onboarding document metadata with private object storage (read-only).",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Not implemented in Part 6B.4 (default is read-only dry-run).",
    )
    args = parser.parse_args(argv)

    if args.apply:
        print("Apply mode is not available in this release.", file=sys.stderr)
        return 2

    settings = get_settings()
    try:
        storage = create_object_storage(settings)
    except StorageConfigurationError:
        print("Object storage is not configured.", file=sys.stderr)
        return 1

    engine = get_engine()
    if engine is None:
        print("Database is not configured.", file=sys.stderr)
        return 1

    with Session(engine) as session:
        report = reconcile_onboarding_documents_dry_run(session, storage)

    print(json.dumps(report.to_public_dict(), indent=2, sort_keys=True))
    return 0 if report.complete else 1


if __name__ == "__main__":
    raise SystemExit(main())
