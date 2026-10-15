"""Static validation for Alembic revision scripts."""

import importlib.util
from pathlib import Path
from types import ModuleType

BACKEND_ROOT = Path(__file__).resolve().parents[1]
VERSIONS_DIR = BACKEND_ROOT / "alembic" / "versions"


def _load_revision_modules() -> list[ModuleType]:
    modules: list[ModuleType] = []
    for path in sorted(VERSIONS_DIR.glob("*.py")):
        spec = importlib.util.spec_from_file_location(path.stem, path)
        assert spec is not None and spec.loader is not None
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        modules.append(module)
    return modules


def _down_revision_targets(module: ModuleType) -> set[str]:
    down_revision = module.down_revision
    if down_revision is None:
        return set()
    if isinstance(down_revision, str):
        return {down_revision}
    return set(down_revision)


def test_revision_scripts_expose_required_metadata() -> None:
    modules = _load_revision_modules()

    assert modules, "Expected at least one Alembic revision file."

    for module in modules:
        assert isinstance(module.revision, str) and module.revision
        assert callable(module.upgrade)
        assert callable(module.downgrade)


def test_revision_history_has_single_linear_head() -> None:
    modules = _load_revision_modules()
    revisions = {module.revision for module in modules}
    referenced_down_revisions = set().union(
        *(_down_revision_targets(module) for module in modules)
    )

    assert referenced_down_revisions.issubset(revisions)

    heads = [module.revision for module in modules if module.revision not in referenced_down_revisions]

    assert heads == ["b0a1f0110001"]
    assert sum(module.down_revision is None for module in modules) == 1
