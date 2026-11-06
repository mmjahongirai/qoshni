"""Owner catalog and inventory management. Checkout stays on its own routes."""

from __future__ import annotations

import uuid

from typing import NoReturn

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps.access import get_current_principal
from app.core.database import get_db
from app.api.schemas.business_catalog import (
    CatalogInventoryErrorResponse,
    CatalogItemCreateRequest,
    CatalogItemListResponse,
    CatalogItemPriceRequest,
    CatalogItemStatusRequest,
    CatalogItemView,
    InventoryBalanceView,
    InventoryCountRequest,
    InventoryEventListResponse,
    InventoryEventView,
    InventoryOpenRequest,
    InventoryReplenishRequest,
)
from app.services.auth.principal import AuthenticatedPrincipal
from app.db.models.consumer_catalog import (
    ConsumerCatalogInventory,
    ConsumerCatalogInventoryEvent,
    ConsumerCatalogItem,
)
from app.domain.consumer_catalog import ConsumerCatalogInventoryEventKind, ConsumerCatalogItemStatus, ConsumerCatalogOfferingKind
from app.services.checkout.catalog_inventory_admin import (
    InventoryAdminError,
    InventoryAdminErrorCode,
    correct_owner_inventory_count,
    get_owner_inventory,
    list_owner_inventory_events,
    open_owner_inventory,
    replenish_owner_inventory,
)
from app.services.checkout.consumer_catalog_service import (
    ConsumerCatalogWriteError,
    ConsumerCatalogWriteErrorCode,
    create_catalog_offering,
    get_catalog_offering,
    list_catalog_offerings,
    set_catalog_offering_price,
    set_catalog_offering_status,
)
from app.services.checkout.reservation_maintenance import sweep_stale_reservations

router = APIRouter(
    prefix="/business/onboarding/applications/{application_id}/catalog",
    tags=["business-catalog"],
)

_STATUS = {
    ConsumerCatalogWriteErrorCode.VALIDATION_FAILED.value: 422,
    ConsumerCatalogWriteErrorCode.BUSINESS_NOT_FOUND.value: status.HTTP_404_NOT_FOUND,
    ConsumerCatalogWriteErrorCode.BUSINESS_NOT_VERIFIED.value: status.HTTP_403_FORBIDDEN,
    ConsumerCatalogWriteErrorCode.CATALOG_ITEM_EXISTS.value: status.HTTP_409_CONFLICT,
    ConsumerCatalogWriteErrorCode.CATALOG_ITEM_NOT_FOUND.value: status.HTTP_404_NOT_FOUND,
    InventoryAdminErrorCode.INVENTORY_ALREADY_OPEN.value: status.HTTP_409_CONFLICT,
    InventoryAdminErrorCode.INVENTORY_NOT_OPEN.value: status.HTTP_409_CONFLICT,
    InventoryAdminErrorCode.BELOW_RESERVED.value: status.HTTP_409_CONFLICT,
}


def _fail(error: ConsumerCatalogWriteError | InventoryAdminError) -> NoReturn:
    raise HTTPException(
        status_code=_STATUS.get(error.code.value, 422),
        detail=CatalogInventoryErrorResponse(code=error.code.value, message=error.message).model_dump(),
    )


def _item_view(item: ConsumerCatalogItem) -> CatalogItemView:
    return CatalogItemView(
        catalog_item_id=item.id,
        business_application_id=item.business_application_id,
        catalog_item_stable_id=item.catalog_item_stable_id,
        offering_kind=ConsumerCatalogOfferingKind(item.offering_kind),
        title=item.title,
        unit_price_minor=item.unit_price_minor,
        currency_code=item.currency_code,
        pricing_revision=item.pricing_revision,
        status=ConsumerCatalogItemStatus(item.status),
        created_at=item.created_at,
        updated_at=item.updated_at,
    )


def _balance_view(balance: ConsumerCatalogInventory) -> InventoryBalanceView:
    return InventoryBalanceView(
        catalog_item_id=balance.catalog_item_id,
        quantity_on_hand=balance.quantity_on_hand,
        reserved_quantity=balance.reserved_quantity,
        available_quantity=balance.quantity_on_hand - balance.reserved_quantity,
        updated_at=balance.updated_at,
    )


def _event_view(event: ConsumerCatalogInventoryEvent) -> InventoryEventView:
    return InventoryEventView(
        event_id=event.id,
        catalog_item_id=event.catalog_item_id,
        actor_user_id=event.actor_user_id,
        kind=ConsumerCatalogInventoryEventKind(event.kind),
        quantity_delta=event.quantity_delta,
        quantity_on_hand_after=event.quantity_on_hand_after,
        reserved_quantity_after=event.reserved_quantity_after,
        reason=event.reason,
        created_at=event.created_at,
    )


@router.post("/items", response_model=CatalogItemView, status_code=status.HTTP_201_CREATED)
def post_catalog_item(
    application_id: uuid.UUID,
    body: CatalogItemCreateRequest,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> CatalogItemView:
    result = create_catalog_offering(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
        catalog_item_stable_id=body.catalog_item_stable_id,
        offering_kind=body.offering_kind,
        title=body.title,
        unit_price_minor=body.unit_price_minor,
    )
    if isinstance(result, ConsumerCatalogWriteError):
        _fail(result)
    session.commit()
    return _item_view(result)


@router.get("/items", response_model=CatalogItemListResponse)
def get_catalog_items(
    application_id: uuid.UUID,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> CatalogItemListResponse:
    result = list_catalog_offerings(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
    )
    if isinstance(result, ConsumerCatalogWriteError):
        _fail(result)
    return CatalogItemListResponse(items=[_item_view(item) for item in result])


@router.get("/items/{catalog_item_id}", response_model=CatalogItemView)
def get_catalog_item(
    application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> CatalogItemView:
    result = get_catalog_offering(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(result, ConsumerCatalogWriteError):
        _fail(result)
    return _item_view(result)


@router.patch("/items/{catalog_item_id}/price", response_model=CatalogItemView)
def patch_catalog_item_price(
    application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    body: CatalogItemPriceRequest,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> CatalogItemView:
    result = set_catalog_offering_price(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
        catalog_item_id=catalog_item_id,
        unit_price_minor=body.unit_price_minor,
    )
    if isinstance(result, ConsumerCatalogWriteError):
        _fail(result)
    session.commit()
    return _item_view(result)


@router.patch("/items/{catalog_item_id}/status", response_model=CatalogItemView)
def patch_catalog_item_status(
    application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    body: CatalogItemStatusRequest,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> CatalogItemView:
    result = set_catalog_offering_status(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
        catalog_item_id=catalog_item_id,
        status=body.status,
    )
    if isinstance(result, ConsumerCatalogWriteError):
        _fail(result)
    session.commit()
    return _item_view(result)


@router.post("/items/{catalog_item_id}/inventory", response_model=InventoryBalanceView, status_code=status.HTTP_201_CREATED)
def post_open_inventory(
    application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    body: InventoryOpenRequest,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> InventoryBalanceView:
    result = open_owner_inventory(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
        catalog_item_id=catalog_item_id,
        quantity_on_hand=body.quantity_on_hand,
        reason=body.reason,
    )
    if isinstance(result, InventoryAdminError):
        _fail(result)
    session.commit()
    return _balance_view(result)


@router.post("/items/{catalog_item_id}/inventory/replenishments", response_model=InventoryBalanceView)
def post_replenish_inventory(
    application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    body: InventoryReplenishRequest,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> InventoryBalanceView:
    result = replenish_owner_inventory(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
        catalog_item_id=catalog_item_id,
        quantity=body.quantity,
        reason=body.reason,
    )
    if isinstance(result, InventoryAdminError):
        _fail(result)
    session.commit()
    return _balance_view(result)


@router.post("/items/{catalog_item_id}/inventory/counts", response_model=InventoryBalanceView)
def post_correct_inventory_count(
    application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    body: InventoryCountRequest,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> InventoryBalanceView:
    result = correct_owner_inventory_count(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
        catalog_item_id=catalog_item_id,
        quantity_on_hand=body.quantity_on_hand,
        reason=body.reason,
    )
    if isinstance(result, InventoryAdminError):
        _fail(result)
    session.commit()
    return _balance_view(result)


@router.get("/items/{catalog_item_id}/inventory", response_model=InventoryBalanceView)
def get_inventory(
    application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> InventoryBalanceView:
    result = get_owner_inventory(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(result, InventoryAdminError):
        _fail(result)
    sweep_stale_reservations(session, worker_id="owner-inventory-read", record=False)
    session.commit()
    session.refresh(result)
    return _balance_view(result)


@router.get("/items/{catalog_item_id}/inventory/events", response_model=InventoryEventListResponse)
def get_inventory_events(
    application_id: uuid.UUID,
    catalog_item_id: uuid.UUID,
    principal: AuthenticatedPrincipal = Depends(get_current_principal),
    session: Session = Depends(get_db),
) -> InventoryEventListResponse:
    result = list_owner_inventory_events(
        session,
        owner_user_id=principal.user_id,
        business_application_id=application_id,
        catalog_item_id=catalog_item_id,
    )
    if isinstance(result, InventoryAdminError):
        _fail(result)
    return InventoryEventListResponse(events=[_event_view(event) for event in result])
