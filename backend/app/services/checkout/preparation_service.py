"""Checkout preparation validation — authoritative catalog not available in WP1."""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum

from app.api.schemas.checkout_preparation import CheckoutPrepareRequest
from app.domain.checkout_limits import CHECKOUT_CURRENCY_UZS


class CheckoutPreparationErrorCode(StrEnum):
    EMPTY_CART = "empty_cart"
    VALIDATION_FAILED = "validation_failed"
    AUTHORITATIVE_CATALOG_UNAVAILABLE = "authoritative_catalog_unavailable"


@dataclass(frozen=True, slots=True)
class CheckoutPreparationError:
    code: CheckoutPreparationErrorCode
    message: str


def validate_prepare_request(
    payload: CheckoutPrepareRequest,
) -> CheckoutPreparationError | None:
    if not payload.lines:
        return CheckoutPreparationError(
            code=CheckoutPreparationErrorCode.EMPTY_CART,
            message="Cart must contain at least one line.",
        )

    seen: set[tuple[str, str]] = set()
    for line in payload.lines:
        key = (line.business_stable_id.strip(), line.catalog_item_stable_id.strip())
        if not key[0] or not key[1]:
            return CheckoutPreparationError(
                code=CheckoutPreparationErrorCode.VALIDATION_FAILED,
                message="Line references must be non-empty.",
            )
        if key in seen:
            return CheckoutPreparationError(
                code=CheckoutPreparationErrorCode.VALIDATION_FAILED,
                message="Duplicate cart lines must be merged client-side.",
            )
        seen.add(key)

    if payload.client_submitted_total_minor is not None and payload.client_submitted_total_minor < 0:
        return CheckoutPreparationError(
            code=CheckoutPreparationErrorCode.VALIDATION_FAILED,
            message="Client total cannot be negative.",
        )

    return None


def prepare_checkout_pricing(
    payload: CheckoutPrepareRequest,
) -> CheckoutPreparationError:
    """No server-side consumer catalog exists yet — pricing remains client demo-only."""
    validation = validate_prepare_request(payload)
    if validation is not None:
        return validation

    _ = CHECKOUT_CURRENCY_UZS  # contract placeholder for future pricing currency
    return CheckoutPreparationError(
        code=CheckoutPreparationErrorCode.AUTHORITATIVE_CATALOG_UNAVAILABLE,
        message=(
            "Authoritative consumer catalog pricing is not available on the backend. "
            "Use the Flutter demo pricing adapter until catalog APIs are delivered."
        ),
    )
