"""Checkout preparation API (contract only until catalog authority exists)."""

from __future__ import annotations

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.api.deps.checkout import get_consumer_catalog_authority
from app.api.schemas.checkout_quote import (
    CheckoutQuoteIssueRequest,
    CheckoutQuoteIssueResponse,
)
from app.core.database import get_db
from app.services.checkout.catalog_authority import ConsumerCatalogAuthority
from app.services.auth.principal import AuthenticatedPrincipal
from app.services.checkout.checkout_quote_service import (
    CheckoutQuoteErrorCode,
    issue_checkout_quote,
)
from app.api.schemas.checkout_preparation import (
    CheckoutPrepareRequest,
    CheckoutPrepareUnavailableResponse,
    CheckoutPrepareValidationErrorResponse,
)
from app.services.checkout.preparation_service import (
    CheckoutPreparationErrorCode,
    prepare_checkout_pricing,
)

router = APIRouter(prefix="/checkout", tags=["checkout"])


@router.post(
    "/prepare",
    responses={
        400: {"model": CheckoutPrepareValidationErrorResponse},
        503: {"model": CheckoutPrepareUnavailableResponse},
    },
)
def post_checkout_prepare(
    payload: CheckoutPrepareRequest,
    _principal: AuthenticatedPrincipal = Depends(get_current_principal),
) -> JSONResponse:
    result = prepare_checkout_pricing(payload)
    if result.code == CheckoutPreparationErrorCode.EMPTY_CART:
        return JSONResponse(
            status_code=400,
            content=CheckoutPrepareValidationErrorResponse(
                code=result.code.value,
                message=result.message,
            ).model_dump(),
        )
    if result.code == CheckoutPreparationErrorCode.VALIDATION_FAILED:
        return JSONResponse(
            status_code=400,
            content=CheckoutPrepareValidationErrorResponse(
                code=result.code.value,
                message=result.message,
            ).model_dump(),
        )
    return JSONResponse(
        status_code=503,
        content=CheckoutPrepareUnavailableResponse(
            code=result.code.value,
            message=result.message,
        ).model_dump(),
    )


@router.post(
    "/quotes",
    response_model=CheckoutQuoteIssueResponse,
    responses={
        400: {"model": CheckoutPrepareValidationErrorResponse},
        503: {"model": CheckoutPrepareUnavailableResponse},
    },
)
def post_checkout_quote(
    payload: CheckoutQuoteIssueRequest,
    session: Session = Depends(get_db),
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    catalog: ConsumerCatalogAuthority = Depends(get_consumer_catalog_authority),
) -> CheckoutQuoteIssueResponse | JSONResponse:
    result = issue_checkout_quote(
        session,
        buyer_user_id=principal.user_id,
        catalog=catalog,
        fulfillment_type=payload.fulfillment_type,
        lines=payload.lines,
        cart_revision=payload.cart_revision,
    )
    from app.services.checkout.checkout_quote_service import CheckoutQuoteError

    if isinstance(result, CheckoutQuoteError):
        status = 503 if result.code == CheckoutQuoteErrorCode.AUTHORITATIVE_CATALOG_UNAVAILABLE else 400
        body = (
            CheckoutPrepareUnavailableResponse(code=result.code.value, message=result.message)
            if status == 503
            else CheckoutPrepareValidationErrorResponse(code=result.code.value, message=result.message)
        )
        return JSONResponse(status_code=status, content=body.model_dump())
    session.commit()
    return CheckoutQuoteIssueResponse(
        quote_id=result.quote_id,
        pricing_revision=result.pricing_revision,
        expires_at=result.expires_at,
        currency_code=result.currency_code,
        total_minor=result.total_minor,
    )
