"""PostgreSQL-only inventory checks. Skipped unless a disposable test URL is set.

Set ``QOSHNI_TEST_POSTGRES_URL`` to a database whose URL contains ``test``.
Do not point this at production. This file does not apply Alembic to a shared
database; it builds the metadata on that disposable database and drops its tables.
"""

from __future__ import annotations

import os
import threading
import uuid
from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy import create_engine, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.consumer_catalog import ConsumerCatalogInventory
from app.db.models.consumer_orders import CheckoutQuote
from app.db.models.identity import User
from app.domain.business_onboarding import BusinessServiceCategory, VerificationStatus
from app.domain.checkout_fulfillment import CheckoutFulfillmentType
from app.domain.consumer_catalog import ConsumerCatalogOfferingKind
from app.domain.identity import AccountStatus
from app.services.checkout.consumer_catalog_service import upsert_catalog_offering
from app.services.checkout.order_placement_service import (
    OrderPlacementDependencies,
    PlaceOrderCommand,
    PlaceOrderSuccess,
    place_order,
)
from app.services.checkout.sql_catalog_authority import SqlConsumerCatalogAuthority
from app.services.checkout.sql_inventory import SqlCatalogInventoryService, open_catalog_inventory
from app.services.checkout.sql_order_repository import (
    SqlAlchemyOrderPlacementStore,
    is_idempotency_unique_violation,
)
from app.services.search_discovery.stable_ids import stable_id_for_application
from app.api.schemas.checkout_preparation import CheckoutCartLineRequest

_URL = os.environ.get("QOSHNI_TEST_POSTGRES_URL")

pytestmark = pytest.mark.skipif(
    not _URL or "test" not in _URL.lower(),
    reason=(
        "QOSHNI_TEST_POSTGRES_URL is unset or is not a disposable test database. "
        "PostgreSQL integration was not executed."
    ),
)


@pytest.fixture
def engine():
    assert _URL is not None
    database = create_engine(_URL)
    Base.metadata.drop_all(database)
    Base.metadata.create_all(database)
    yield database
    Base.metadata.drop_all(database)
    database.dispose()


def _seed(session: Session) -> str:
    owner = User(phone_e164=f"+9989016{uuid.uuid4().int % 10000000:07d}", status=AccountStatus.ACTIVE.value)
    session.add(owner)
    session.flush()
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name="PG Test",
        trade_display_name="PG",
        service_category=BusinessServiceCategory.GROCERIES.value,
        registration_jurisdiction="UZ",
        registration_identifier=f"REG-{uuid.uuid4().hex[:10]}",
        verification_status=VerificationStatus.VERIFIED.value,
        submitted_at=datetime.now(UTC),
    )
    session.add(application)
    session.flush()
    item = upsert_catalog_offering(
        session,
        owner_user_id=owner.id,
        business_application_id=application.id,
        catalog_item_stable_id="bread",
        offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
        title="Bread",
        unit_price_minor=8000,
    )
    assert not hasattr(item, "code")
    open_catalog_inventory(session, catalog_item_id=item.id, quantity_on_hand=1)
    session.commit()
    return stable_id_for_application(application.id)


def test_parallel_reserve_of_the_last_unit_uses_row_locks(engine) -> None:
    with Session(engine) as session:
        stable = _seed(session)

    winners: list[bool] = []
    barrier = threading.Barrier(2)

    def _reserve() -> None:
        with Session(engine) as session:
            barrier.wait(timeout=10)
            service = SqlCatalogInventoryService(session)
            from app.services.checkout.inventory_reservation_service import SkuKey

            reserved = service.reserve_for_order(
                sku=SkuKey(stable, "bread"),
                quantity=1,
                order_id=uuid.uuid4(),
            )
            session.commit()
            winners.append(reserved is not None)

    threads = [threading.Thread(target=_reserve) for _ in range(2)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    assert sorted(winners) == [False, True]
    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 1
        assert balance.quantity_on_hand == 1


def test_parallel_same_idempotency_key_replays_one_order(engine) -> None:
    with Session(engine) as session:
        stable = _seed(session)
        buyer = User(
            phone_e164=f"+9989017{uuid.uuid4().int % 10000000:07d}",
            status=AccountStatus.ACTIVE.value,
        )
        session.add(buyer)
        session.flush()
        quote = CheckoutQuote(
            buyer_user_id=buyer.id,
            request_fingerprint="pg",
            fulfillment_type=CheckoutFulfillmentType.PICKUP.value,
            currency_code="UZS",
            subtotal_minor=8000,
            total_minor=8000,
            pricing_revision=1,
            expires_at=datetime.now(UTC) + timedelta(minutes=15),
        )
        session.add(quote)
        session.commit()
        buyer_id = buyer.id
        quote_id = quote.id

    command = PlaceOrderCommand(
        buyer_user_id=buyer_id,
        idempotency_key="pg-same",
        fulfillment_type=CheckoutFulfillmentType.PICKUP,
        checkout_correlation_id="pg",
        server_quote_id=str(quote_id),
        server_quote_revision=1,
        lines=[
            CheckoutCartLineRequest(
                business_stable_id=stable,
                catalog_item_stable_id="bread",
                quantity=1,
            )
        ],
        client_submitted_total_minor=1,
    )
    outcomes: list[str] = []
    barrier = threading.Barrier(2)

    def _place() -> None:
        with Session(engine) as session:
            barrier.wait(timeout=10)
            deps = OrderPlacementDependencies(
                catalog=SqlConsumerCatalogAuthority(session),
                store=SqlAlchemyOrderPlacementStore(session),
                inventory=SqlCatalogInventoryService(session),
            )
            try:
                result = place_order(command, deps)
                session.commit()
            except IntegrityError as exc:
                session.rollback()
                assert is_idempotency_unique_violation(exc)
                outcomes.append("replay-conflict")
                return
            assert isinstance(result, PlaceOrderSuccess)
            outcomes.append("committed" if not result.idempotent_replay else "replay")

    threads = [threading.Thread(target=_place) for _ in range(2)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    assert "committed" in outcomes
    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 1
