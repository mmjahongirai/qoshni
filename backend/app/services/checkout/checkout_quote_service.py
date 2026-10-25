"""Server-issued checkout quotes (only when catalog authority is operational)."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from enum import StrEnum

from sqlalchemy.orm import Session

from app.api.schemas.checkout_preparation import CheckoutCartLineRequest, CheckoutPrepareRequest
from app.db.models.consumer_orders import CheckoutQuote, CheckoutQuoteLine
from app.domain.checkout_fulfillment import CheckoutFulfillmentType
from app.domain.checkout_limits import CHECKOUT_CURRENCY_UZS
from app.services.checkout.catalog_authority import ConsumerCatalogAuthority
from app.services.checkout.order_placement_store import fingerprint_place_order_request
from app.services.checkout.preparation_service import validate_prepare_request

CHECKOUT_QUOTE_TTL = timedelta(minutes=15)


class CheckoutQuoteErrorCode(StrEnum):
    VALIDATION_FAILED = "validation_failed"
    AUTHORITATIVE_CATALOG_UNAVAILABLE = "authoritative_catalog_unavailable"


@dataclass(frozen=True, slots=True)
class CheckoutQuoteError:
    code: CheckoutQuoteErrorCode
    message: str


@dataclass(frozen=True, slots=True)
class IssuedCheckoutQuote:
    quote_id: uuid.UUID
    pricing_revision: int
    expires_at: datetime
    total_minor: int
    currency_code: str


def _fingerprint(
    *,
    fulfillment_type: CheckoutFulfillmentType,
    lines: list[CheckoutCartLineRequest],
) -> str:
    payload = {
        "fulfillment_type": fulfillment_type.value,
        "lines": [
            {
                "business_stable_id": line.business_stable_id,
                "catalog_item_stable_id": line.catalog_item_stable_id,
                "quantity": line.quantity,
            }
            for line in lines
        ],
    }
    return fingerprint_place_order_request(payload)


def issue_checkout_quote(
    session: Session,
    *,
    buyer_user_id: uuid.UUID,
    catalog: ConsumerCatalogAuthority,
    fulfillment_type: CheckoutFulfillmentType,
    lines: list[CheckoutCartLineRequest],
    cart_revision: int | None = None,
) -> IssuedCheckoutQuote | CheckoutQuoteError:
    validation = validate_prepare_request(
        CheckoutPrepareRequest(fulfillment_type=fulfillment_type, lines=lines)
    )
    if validation is not None:
        return CheckoutQuoteError(
            code=CheckoutQuoteErrorCode.VALIDATION_FAILED,
            message=validation.message,
        )

    if not catalog.is_operational():
        return CheckoutQuoteError(
            code=CheckoutQuoteErrorCode.AUTHORITATIVE_CATALOG_UNAVAILABLE,
            message="Cannot issue server quotes without authoritative catalog pricing.",
        )

    fingerprint = _fingerprint(fulfillment_type=fulfillment_type, lines=lines)
    snapshots: list[CheckoutQuoteLine] = []
    subtotal = 0
    pricing_revision = 1

    for line in lines:
        authority = catalog.resolve_line(
            business_stable_id=line.business_stable_id,
            catalog_item_stable_id=line.catalog_item_stable_id,
            requested_quantity=line.quantity,
        )
        if authority is None or authority.unit_price_minor < 0:
            return CheckoutQuoteError(
                code=CheckoutQuoteErrorCode.VALIDATION_FAILED,
                message="Line is not quotable from authoritative catalog.",
            )
        line_subtotal = authority.unit_price_minor * line.quantity
        subtotal += line_subtotal
        snapshots.append(
            CheckoutQuoteLine(
                business_stable_id=line.business_stable_id,
                catalog_item_stable_id=line.catalog_item_stable_id,
                title_snapshot=authority.title_snapshot,
                quantity=line.quantity,
                unit_price_minor=authority.unit_price_minor,
                line_subtotal_minor=line_subtotal,
                currency_code=authority.currency_code,
            )
        )

    quote_id = uuid.uuid4()
    expires_at = datetime.now(UTC) + CHECKOUT_QUOTE_TTL
    quote = CheckoutQuote(
        id=quote_id,
        buyer_user_id=buyer_user_id,
        request_fingerprint=fingerprint,
        fulfillment_type=fulfillment_type.value,
        currency_code=CHECKOUT_CURRENCY_UZS,
        subtotal_minor=subtotal,
        total_minor=subtotal,
        pricing_revision=pricing_revision,
        cart_revision=cart_revision,
        expires_at=expires_at,
    )
    for row in snapshots:
        row.quote_id = quote_id
    quote.lines = snapshots
    session.add(quote)
    session.flush()

    return IssuedCheckoutQuote(
        quote_id=quote_id,
        pricing_revision=pricing_revision,
        expires_at=expires_at,
        total_minor=subtotal,
        currency_code=CHECKOUT_CURRENCY_UZS,
    )


def validate_quote_for_placement(
    session: Session,
    *,
    buyer_user_id: uuid.UUID,
    server_quote_id: uuid.UUID,
    server_quote_revision: int,
    request_fingerprint: str,
    fulfillment_type: CheckoutFulfillmentType,
    lines: list[CheckoutCartLineRequest],
) -> CheckoutQuoteError | None:
    quote = session.get(CheckoutQuote, server_quote_id)
    if quote is None or quote.buyer_user_id != buyer_user_id:
        return CheckoutQuoteError(
            code=CheckoutQuoteErrorCode.VALIDATION_FAILED,
            message="Checkout quote not found for buyer.",
        )
    if quote.expires_at <= datetime.now(UTC):
        return CheckoutQuoteError(
            code=CheckoutQuoteErrorCode.VALIDATION_FAILED,
            message="Checkout quote has expired.",
        )
    if quote.pricing_revision != server_quote_revision:
        return CheckoutQuoteError(
            code=CheckoutQuoteErrorCode.VALIDATION_FAILED,
            message="Checkout quote revision is stale.",
        )
    if quote.fulfillment_type != fulfillment_type.value:
        return CheckoutQuoteError(
            code=CheckoutQuoteErrorCode.VALIDATION_FAILED,
            message="Fulfillment does not match quoted request.",
        )
    expected_fp = _fingerprint(fulfillment_type=fulfillment_type, lines=lines)
    if quote.request_fingerprint != expected_fp or quote.request_fingerprint != request_fingerprint:
        return CheckoutQuoteError(
            code=CheckoutQuoteErrorCode.VALIDATION_FAILED,
            message="Checkout quote does not match placement fingerprint.",
        )
    return None
