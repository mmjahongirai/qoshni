"""Separate process that expires stale reservation holds.

The API process does not start this loop. A deployment must run this module
and set ``QOSHNI_RESERVATION_MAINTENANCE_ENABLED=true``. With the flag false
the process exits without sweeping.
"""

from __future__ import annotations

import logging
import time

from app.core.config import get_settings
from app.core.database import get_session_factory
from app.services.checkout.reservation_maintenance import run_recorded_sweep

logger = logging.getLogger(__name__)


def run_worker(*, max_iterations: int | None = None) -> int:
    """Sweep until stopped. Returns the number of iterations actually run."""
    settings = get_settings()
    if not settings.reservation_maintenance_enabled:
        logger.info(
            "Reservation maintenance stayed off. "
            "Set QOSHNI_RESERVATION_MAINTENANCE_ENABLED=true to run the worker."
        )
        return 0
    factory = get_session_factory(settings=settings)
    if factory is None:
        logger.error("Reservation maintenance worker has no database URL.")
        return 0
    completed = 0
    while max_iterations is None or completed < max_iterations:
        session = factory()
        try:
            run_recorded_sweep(
                session,
                worker_id=settings.reservation_maintenance_worker_id,
            )
        except Exception:
            logger.exception("Reservation maintenance iteration failed")
        finally:
            session.close()
        completed += 1
        if max_iterations is not None and completed >= max_iterations:
            break
        time.sleep(settings.reservation_maintenance_interval_seconds)
    return completed


if __name__ == "__main__":
    raise SystemExit(run_worker())
