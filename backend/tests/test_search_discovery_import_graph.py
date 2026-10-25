"""Regression: search_discovery modules must import without circular dependencies."""

from __future__ import annotations

import importlib
import uuid

import pytest


def test_stable_id_for_application_format() -> None:
    from app.services.search_discovery.stable_ids import stable_id_for_application

    app_id = uuid.UUID("11111111-1111-1111-1111-111111111111")
    assert stable_id_for_application(app_id) == f"business:onboarding:{app_id}"


@pytest.mark.parametrize(
    "module_name",
    [
        "app.services.search_discovery.stable_ids",
        "app.services.search_discovery.branch_coordinate_projection",
        "app.services.search_discovery.projector",
        "app.main",
    ],
)
def test_module_imports_cleanly(module_name: str) -> None:
    importlib.import_module(module_name)
