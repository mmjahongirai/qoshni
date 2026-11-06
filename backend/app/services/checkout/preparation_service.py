"""Checkout preparation validation and authoritative catalog pricing preview."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime
from enum import StrEnum

from app.api.schemas.checkout_preparation import (
    CheckoutPreparedLineView,
    CheckoutPrepareRequest,
    CheckoutPrepareSuccessResponse,
    new_checkout_correlation_id,
)
from app.domain.checkout_limits import CHECKOUT_CURRENCY_UZS
from app.services.checkout.catalog_authority import ConsumerCatalogAuthority


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
    """Response when no authoritative catalog is wired (production default)."""
    validation = validate_prepare_request(payload)
    if validation is not None:
        return validation

    return CheckoutPreparationError(
        code=CheckoutPreparationErrorCode.AUTHORITATIVE_CATALOG_UNAVAILABLE,
        message=(
            "Authoritative consumer catalog pricing is not available on the backend. "
            "Use the Flutter demo pricing adapter until catalog APIs are delivered."
        ),
    )


def prepare_checkout_with_catalog(
    payload: CheckoutPrepareRequest,
    catalog: ConsumerCatalogAuthority,
) -> CheckoutPrepareSuccessResponse | CheckoutPreparationError:
    """Price every line from the catalog; ``client_submitted_total_minor`` is never used."""
    if not catalog.is_operational():
        return prepare_checkout_pricing(payload)
    validation = validate_prepare_request(payload)
    if validation is not None:
        return validation

    priced: list[CheckoutPreparedLineView] = []
    for line in payload.lines:
        authority = catalog.resolve_line(
            business_stable_id=line.business_stable_id,
            catalog_item_stable_id=line.catalog_item_stable_id,
            requested_quantity=line.quantity,
        )
        if (
            authority is None
            or authority.unit_price_minor < 0
            or authority.currency_code != CHECKOUT_CURRENCY_UZS
        ):
            return CheckoutPreparationError(
                code=CheckoutPreparationErrorCode.VALIDATION_FAILED,
                message="Line is not priceable from authoritative catalog.",
            )
        priced.append(
            CheckoutPreparedLineView(
                business_stable_id=line.business_stable_id,
                catalog_item_stable_id=line.catalog_item_stable_id,
                quantity=line.quantity,
                unit_price_minor=authority.unit_price_minor,
                line_subtotal_minor=authority.unit_price_minor * line.quantity,
                currency_code=authority.currency_code,
                title_snapshot=authority.title_snapshot,
            )
        )

    subtotal = sum(line.line_subtotal_minor for line in priced)
    return CheckoutPrepareSuccessResponse(
        session_correlation_id=new_checkout_correlation_id(),
        quoted_at=datetime.now(UTC),
        currency_code=CHECKOUT_CURRENCY_UZS,
        subtotal_minor=subtotal,
        discount_minor=0,
        delivery_fee_minor=0,
        tax_minor=0,
        total_minor=subtotal,
        lines=priced,
        cart_revision=payload.cart_revision,
        is_demo_pricing=False,
    )
