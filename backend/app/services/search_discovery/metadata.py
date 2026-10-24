"""Catalog generation metadata helpers."""

from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.search_discovery import SearchIndexMetadata


def get_catalog_generation(session: Session) -> int:
    row = session.scalar(select(SearchIndexMetadata).order_by(SearchIndexMetadata.id.asc()).limit(1))
    if row is None:
        row = SearchIndexMetadata(catalog_generation=1)
        session.add(row)
        session.flush()
    return int(row.catalog_generation)


def bump_catalog_generation(session: Session) -> int:
    row = session.scalar(select(SearchIndexMetadata).order_by(SearchIndexMetadata.id.asc()).limit(1))
    if row is None:
        row = SearchIndexMetadata(catalog_generation=1)
        session.add(row)
    row.catalog_generation = int(row.catalog_generation) + 1
    session.flush()
    return int(row.catalog_generation)
