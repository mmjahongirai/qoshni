"""Order placement + idempotency (service layer with fake catalog)."""

from __future__ import annotations

import uuid

from app.api.schemas.checkout_preparation import CheckoutCartLineRequest
from app.domain.checkout_fulfillment import CheckoutFulfillmentType
from app.services.checkout.catalog_authority import UnavailableConsumerCatalogAuthority
from app.services.checkout.inventory_reservation_service import (
    InventoryReservationService,
    SkuKey,
)
from app.services.checkout.order_placement_service import (
    OrderPlacementErrorCode,
    OrderPlacementDependencies,
    PlaceOrderCommand,
    place_order,
)
from app.services.checkout.order_placement_store import InMemoryOrderPlacementStore
from tests.support.fake_consumer_catalog import FakeConsumerCatalogAuthority


def _line() -> CheckoutCartLineRequest:
    return CheckoutCartLineRequest(
        business_stable_id="baraka-market",
        catalog_item_stable_id="baraka-fresh-bread",
        quantity=2,
    )


def test_production_catalog_unavailable_fails_closed() -> None:
    command = PlaceOrderCommand(
        buyer_user_id=uuid.uuid4(),
        idempotency_key="key-1",
        fulfillment_type=CheckoutFulfillmentType.PICKUP,
        checkout_correlation_id="corr-1",
        server_quote_id="quote-1",
        server_quote_revision=1,
        lines=[_line()],
        client_submitted_total_minor=1,
    )
    result = place_order(
        command,
        OrderPlacementDependencies(
            catalog=UnavailableConsumerCatalogAuthority(),
            store=InMemoryOrderPlacementStore(),
            inventory=InventoryReservationService(),
        ),
    )
    from app.services.checkout.order_placement_service import OrderPlacementError

    assert isinstance(result, OrderPlacementError)
    assert result.code == OrderPlacementErrorCode.AUTHORITATIVE_CATALOG_UNAVAILABLE


def test_success_with_fake_catalog_and_idempotent_replay() -> None:
    store = InMemoryOrderPlacementStore()
    inventory = InventoryReservationService()
    catalog = FakeConsumerCatalogAuthority(inventory.ledger)
    catalog.seed(
        business_stable_id="baraka-market",
        catalog_item_stable_id="baraka-fresh-bread",
        title="Bread",
        unit_price_minor=8000,
        stock=10,
    )
    deps = OrderPlacementDependencies(catalog=catalog, store=store, inventory=inventory)
    buyer = uuid.uuid4()
    command = PlaceOrderCommand(
        buyer_user_id=buyer,
        idempotency_key="idem-abc",
        fulfillment_type=CheckoutFulfillmentType.PICKUP,
        checkout_correlation_id="corr-1",
        server_quote_id="quote-1",
        server_quote_revision=3,
        lines=[_line()],
        client_submitted_total_minor=999_999,
    )
    first = place_order(command, deps)
    from app.services.checkout.order_placement_service import PlaceOrderSuccess

    assert isinstance(first, PlaceOrderSuccess)
    assert first.idempotent_replay is False
    assert first.order.total_minor == 16000
    assert first.order.payment_status.value == "unpaid"

    second = place_order(command, deps)
    assert isinstance(second, PlaceOrderSuccess)
    assert second.idempotent_replay is True
    assert second.order.order_id == first.order.order_id


def test_idempotency_conflict_on_different_body() -> None:
    store = InMemoryOrderPlacementStore()
    inventory = InventoryReservationService()
    catalog = FakeConsumerCatalogAuthority(inventory.ledger)
    catalog.seed(
        business_stable_id="baraka-market",
        catalog_item_stable_id="baraka-fresh-bread",
        title="Bread",
        unit_price_minor=8000,
        stock=10,
    )
    deps = OrderPlacementDependencies(catalog=catalog, store=store, inventory=inventory)
    buyer = uuid.uuid4()
    base = PlaceOrderCommand(
        buyer_user_id=buyer,
        idempotency_key="idem-x",
        fulfillment_type=CheckoutFulfillmentType.PICKUP,
        checkout_correlation_id="corr-1",
        server_quote_id="quote-1",
        server_quote_revision=1,
        lines=[_line()],
        client_submitted_total_minor=None,
    )
    place_order(base, deps)
    changed = PlaceOrderCommand(
        buyer_user_id=buyer,
        idempotency_key="idem-x",
        fulfillment_type=CheckoutFulfillmentType.PICKUP,
        checkout_correlation_id="corr-1",
        server_quote_id="quote-1",
        server_quote_revision=1,
        lines=[
            CheckoutCartLineRequest(
                business_stable_id="baraka-market",
                catalog_item_stable_id="baraka-fresh-bread",
                quantity=3,
            )
        ],
        client_submitted_total_minor=None,
    )
    result = place_order(changed, deps)
    from app.services.checkout.order_placement_service import OrderPlacementError

    assert isinstance(result, OrderPlacementError)
    assert result.code == OrderPlacementErrorCode.IDEMPOTENCY_CONFLICT


def test_insufficient_stock_does_not_create_order() -> None:
    store = InMemoryOrderPlacementStore()
    inventory = InventoryReservationService()
    catalog = FakeConsumerCatalogAuthority(inventory.ledger)
    catalog.seed(
        business_stable_id="baraka-market",
        catalog_item_stable_id="baraka-fresh-bread",
        title="Bread",
        unit_price_minor=8000,
        stock=1,
    )
    deps = OrderPlacementDependencies(catalog=catalog, store=store, inventory=inventory)
    command = PlaceOrderCommand(
        buyer_user_id=uuid.uuid4(),
        idempotency_key="idem-stock",
        fulfillment_type=CheckoutFulfillmentType.PICKUP,
        checkout_correlation_id="corr",
        server_quote_id="q",
        server_quote_revision=1,
        lines=[_line()],
        client_submitted_total_minor=None,
    )
    result = place_order(command, deps)
    from app.services.checkout.order_placement_service import OrderPlacementError

    assert isinstance(result, OrderPlacementError)
    assert result.code == OrderPlacementErrorCode.INSUFFICIENT_STOCK
    from app.services.checkout.order_placement_store import IdempotencyScope

    assert (
        store.get_idempotency(
            IdempotencyScope(
                buyer_user_id=command.buyer_user_id,
                operation="place_order",
                idempotency_key="idem-stock",
            )
        )
        is None
    )
