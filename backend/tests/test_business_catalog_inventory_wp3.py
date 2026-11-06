"""Phase 18 Closure WP3 — owner catalog, inventory audit, claim-safe expiry."""

from __future__ import annotations

import threading
import uuid
from collections.abc import Generator
from contextlib import contextmanager
from datetime import UTC, datetime, timedelta
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, func, select
from sqlalchemy.engine import Engine
from sqlalchemy.exc import OperationalError
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.consumer_catalog import (
    ConsumerCatalogInventory,
    ConsumerCatalogInventoryEvent,
    ConsumerCatalogItem,
)
from app.db.models.consumer_orders import ConsumerOrder, InventoryReservation
from app.db.models.identity import User
from app.db.models.platform_roles import UserPlatformRoleAssignment
from app.domain.business_onboarding import BusinessServiceCategory, VerificationStatus
from app.domain.consumer_catalog import ConsumerCatalogInventoryEventKind, ConsumerCatalogItemStatus, ConsumerCatalogOfferingKind
from app.domain.identity import AccountStatus
from app.domain.inventory_reservation import InventoryReservationStatus
from app.domain.order_lifecycle import ConsumerOrderStatus
from app.domain.platform_roles import PlatformRole
from app.domain.role_assignments import RoleAssignmentGrantSource
from app.main import create_app
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
    list_catalog_offerings,
    set_catalog_offering_price,
    set_catalog_offering_status,
)
from app.services.checkout.sql_catalog_authority import SqlConsumerCatalogAuthority
from app.services.checkout.sql_inventory import open_catalog_inventory
from app.services.checkout.sql_order_repository import (
    OrderRejectionOutcome,
    SqlOrderLifecycleService,
)
from app.services.search_discovery.stable_ids import stable_id_for_application
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "t" * 32
_OWNER_PHONE = "+998901250001"
_OTHER_PHONE = "+998901250002"


def _phone() -> str:
    return f"+9989015{uuid.uuid4().int % 10000000:07d}"


def _business(
    session: Session,
    *,
    owner: User | None = None,
    verified: bool = True,
) -> BusinessOnboardingApplication:
    if owner is None:
        owner = User(phone_e164=_phone(), status=AccountStatus.ACTIVE.value)
        session.add(owner)
        session.flush()
    application = BusinessOnboardingApplication(
        owner_user_id=owner.id,
        legal_business_name="Baraka LLC",
        trade_display_name="Baraka",
        service_category=BusinessServiceCategory.GROCERIES.value,
        registration_jurisdiction="UZ",
        registration_identifier=f"REG-{uuid.uuid4().hex[:10]}",
        verification_status=(
            VerificationStatus.VERIFIED.value if verified else VerificationStatus.SUBMITTED.value
        ),
        submitted_at=datetime.now(UTC),
    )
    session.add(application)
    session.flush()
    return application


@pytest.fixture
def engine(tmp_path: Path) -> Generator[Engine, None, None]:
    database = create_engine(
        f"sqlite:///{(tmp_path / 'wp3.db').as_posix()}",
        connect_args={"check_same_thread": False, "timeout": 30},
    )
    Base.metadata.create_all(database)
    yield database
    database.dispose()


def test_owner_creates_lists_prices_and_archives(engine: Engine) -> None:
    with Session(engine) as session:
        application = _business(session)
        created = create_catalog_offering(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_stable_id="bread",
            offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
            title="Fresh bread",
            unit_price_minor=8000,
        )
        assert isinstance(created, ConsumerCatalogItem)
        assert created.pricing_revision == 1
        duplicate = create_catalog_offering(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_stable_id="bread",
            offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
            title="Fresh bread",
            unit_price_minor=8000,
        )
        assert isinstance(duplicate, ConsumerCatalogWriteError)
        assert duplicate.code == ConsumerCatalogWriteErrorCode.CATALOG_ITEM_EXISTS

        same_price = set_catalog_offering_price(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_id=created.id,
            unit_price_minor=8000,
        )
        assert isinstance(same_price, ConsumerCatalogItem)
        assert same_price.pricing_revision == 1
        changed = set_catalog_offering_price(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_id=created.id,
            unit_price_minor=9000,
        )
        assert isinstance(changed, ConsumerCatalogItem)
        assert changed.pricing_revision == 2

        archived = set_catalog_offering_status(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_id=created.id,
            status=ConsumerCatalogItemStatus.ARCHIVED,
        )
        assert isinstance(archived, ConsumerCatalogItem)
        assert archived.status == ConsumerCatalogItemStatus.ARCHIVED.value
        assert archived.pricing_revision == 2
        visible = list_catalog_offerings(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
        )
        assert isinstance(visible, list)
        assert len(visible) == 1
        session.commit()
        stable = stable_id_for_application(application.id)
        item_id = created.id
        owner_id = application.owner_user_id
        application_id = application.id

    with Session(engine) as session:
        resolved = SqlConsumerCatalogAuthority(session).resolve_line(
            business_stable_id=stable,
            catalog_item_stable_id="bread",
            requested_quantity=1,
        )
        assert resolved is None
        reopened = set_catalog_offering_status(
            session,
            owner_user_id=owner_id,
            business_application_id=application_id,
            catalog_item_id=item_id,
            status=ConsumerCatalogItemStatus.INACTIVE,
        )
        assert isinstance(reopened, ConsumerCatalogItem)


def test_other_owner_and_unverified_business_are_rejected(engine: Engine) -> None:
    with Session(engine) as session:
        application = _business(session)
        other = User(phone_e164=_phone(), status=AccountStatus.ACTIVE.value)
        session.add(other)
        session.flush()
        created = create_catalog_offering(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_stable_id="bread",
            offering_kind=ConsumerCatalogOfferingKind.SERVICE,
            title="Delivery",
            unit_price_minor=1000,
        )
        assert isinstance(created, ConsumerCatalogItem)
        hidden = list_catalog_offerings(
            session,
            owner_user_id=other.id,
            business_application_id=application.id,
        )
        assert isinstance(hidden, ConsumerCatalogWriteError)
        assert hidden.code == ConsumerCatalogWriteErrorCode.BUSINESS_NOT_FOUND
        missing = get_owner_inventory(
            session,
            owner_user_id=other.id,
            business_application_id=application.id,
            catalog_item_id=created.id,
        )
        assert isinstance(missing, InventoryAdminError)
        assert missing.code == InventoryAdminErrorCode.BUSINESS_NOT_FOUND

        unverified = _business(session, verified=False)
        denied = create_catalog_offering(
            session,
            owner_user_id=unverified.owner_user_id,
            business_application_id=unverified.id,
            catalog_item_stable_id="bread",
            offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
            title="Bread",
            unit_price_minor=1000,
        )
        assert isinstance(denied, ConsumerCatalogWriteError)
        assert denied.code == ConsumerCatalogWriteErrorCode.BUSINESS_NOT_VERIFIED


def test_inventory_open_replenish_count_and_audit(engine: Engine) -> None:
    with Session(engine) as session:
        application = _business(session)
        item = create_catalog_offering(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_stable_id="bread",
            offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
            title="Bread",
            unit_price_minor=8000,
        )
        assert isinstance(item, ConsumerCatalogItem)
        opened = open_owner_inventory(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_id=item.id,
            quantity_on_hand=4,
            reason="opening count",
        )
        assert isinstance(opened, ConsumerCatalogInventory)
        assert opened.reserved_quantity == 0
        again = open_owner_inventory(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_id=item.id,
            quantity_on_hand=9,
            reason="second open",
        )
        assert isinstance(again, InventoryAdminError)
        assert again.code == InventoryAdminErrorCode.INVENTORY_ALREADY_OPEN

        session.commit()
        from app.services.checkout.sql_inventory import reserve_catalog_quantity

        reserved = reserve_catalog_quantity(
            session,
            catalog_item_id=item.id,
            quantity=2,
        )
        assert reserved
        session.commit()

        replenished = replenish_owner_inventory(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_id=item.id,
            quantity=3,
            reason="morning delivery",
        )
        assert isinstance(replenished, ConsumerCatalogInventory)
        assert replenished.quantity_on_hand == 7
        assert replenished.reserved_quantity == 2

        too_low = correct_owner_inventory_count(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_id=item.id,
            quantity_on_hand=1,
            reason="bad count",
        )
        assert isinstance(too_low, InventoryAdminError)
        assert too_low.code == InventoryAdminErrorCode.BELOW_RESERVED

        corrected = correct_owner_inventory_count(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_id=item.id,
            quantity_on_hand=6,
            reason="shelf count",
        )
        assert isinstance(corrected, ConsumerCatalogInventory)
        assert corrected.quantity_on_hand == 6
        assert corrected.reserved_quantity == 2
        session.commit()

    with Session(engine) as session:
        events = list_owner_inventory_events(
            session,
            owner_user_id=session.scalar(select(BusinessOnboardingApplication.owner_user_id)),
            business_application_id=session.scalar(select(BusinessOnboardingApplication.id)),
            catalog_item_id=session.scalar(select(ConsumerCatalogItem.id)),
        )
        assert isinstance(events, list)
        by_reason = {event.reason: event for event in events}
        assert set(by_reason) == {"opening count", "morning delivery", "shelf count"}
        assert by_reason["opening count"].kind == ConsumerCatalogInventoryEventKind.OPENED.value
        assert by_reason["morning delivery"].kind == ConsumerCatalogInventoryEventKind.REPLENISHED.value
        assert by_reason["morning delivery"].quantity_delta == 3
        assert by_reason["shelf count"].kind == ConsumerCatalogInventoryEventKind.COUNT_CORRECTED.value
        assert by_reason["shelf count"].quantity_delta == -1
        owner_id = session.scalar(select(BusinessOnboardingApplication.owner_user_id))
        assert by_reason["morning delivery"].actor_user_id == owner_id
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.quantity_on_hand - balance.reserved_quantity == 4
        assert session.scalar(select(func.count()).select_from(ConsumerCatalogInventoryEvent)) == 3


def test_two_workers_release_one_expired_hold_once(engine: Engine) -> None:
    with Session(engine) as session:
        application = _business(session)
        item = create_catalog_offering(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_stable_id="bread",
            offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
            title="Bread",
            unit_price_minor=8000,
        )
        assert isinstance(item, ConsumerCatalogItem)
        open_catalog_inventory(session, catalog_item_id=item.id, quantity_on_hand=5)
        from app.db.models.consumer_orders import ConsumerOrderItem
        from app.domain.order_lifecycle import (
            ConsumerOrderFulfillmentStatus,
            ConsumerOrderPaymentStatus,
        )

        buyer = User(phone_e164=_phone(), status=AccountStatus.ACTIVE.value)
        session.add(buyer)
        session.flush()
        order = ConsumerOrder(
            buyer_user_id=buyer.id,
            status=ConsumerOrderStatus.PENDING_ACCEPTANCE.value,
            payment_status=ConsumerOrderPaymentStatus.UNPAID.value,
            fulfillment_status=ConsumerOrderFulfillmentStatus.NOT_STARTED.value,
            currency_code="UZS",
            subtotal_minor=8000,
            total_minor=8000,
            checkout_correlation_id="wp3",
            idempotency_key="wp3-expire",
        )
        session.add(order)
        session.flush()
        session.add(
            ConsumerOrderItem(
                order_id=order.id,
                business_stable_id=stable_id_for_application(application.id),
                catalog_item_stable_id="bread",
                title_snapshot="Bread",
                quantity=2,
                unit_price_minor=8000,
                line_subtotal_minor=16000,
                currency_code="UZS",
            )
        )
        from app.services.checkout.sql_inventory import reserve_catalog_quantity

        assert reserve_catalog_quantity(
            session,
            catalog_item_id=item.id,
            quantity=2,
        )
        session.add(
            InventoryReservation(
                order_id=order.id,
                business_stable_id=stable_id_for_application(application.id),
                catalog_item_stable_id="bread",
                quantity=2,
                status=InventoryReservationStatus.HELD.value,
                expires_at=datetime.now(UTC) - timedelta(minutes=1),
            )
        )
        session.commit()
        order_id = order.id

    results: list[int] = []

    def _expire() -> None:
        for _attempt in range(3):
            try:
                with Session(engine) as session:
                    expired = SqlOrderLifecycleService(session).expire_stale_reservations()
                    session.commit()
                    results.append(expired)
                    return
            except OperationalError:
                continue
        raise AssertionError("reservation expiry stayed locked")

    threads = [threading.Thread(target=_expire) for _ in range(2)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()

    assert sorted(results) == [0, 1]
    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.quantity_on_hand == 5
        assert balance.reserved_quantity == 0
        reservation = session.scalars(select(InventoryReservation)).one()
        assert reservation.status == InventoryReservationStatus.EXPIRED.value
        order = session.get(ConsumerOrder, order_id)
        assert order is not None
        assert order.status == ConsumerOrderStatus.EXPIRED.value


def test_accepted_hold_is_not_released_by_expiry(engine: Engine) -> None:
    with Session(engine) as session:
        application = _business(session)
        item = create_catalog_offering(
            session,
            owner_user_id=application.owner_user_id,
            business_application_id=application.id,
            catalog_item_stable_id="bread",
            offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
            title="Bread",
            unit_price_minor=8000,
        )
        assert isinstance(item, ConsumerCatalogItem)
        open_catalog_inventory(session, catalog_item_id=item.id, quantity_on_hand=5)
        from app.domain.order_lifecycle import (
            ConsumerOrderFulfillmentStatus,
            ConsumerOrderPaymentStatus,
        )

        buyer = User(phone_e164=_phone(), status=AccountStatus.ACTIVE.value)
        session.add(buyer)
        session.flush()
        order = ConsumerOrder(
            buyer_user_id=buyer.id,
            status=ConsumerOrderStatus.ACCEPTED.value,
            payment_status=ConsumerOrderPaymentStatus.UNPAID.value,
            fulfillment_status=ConsumerOrderFulfillmentStatus.NOT_STARTED.value,
            currency_code="UZS",
            subtotal_minor=8000,
            total_minor=8000,
            checkout_correlation_id="wp3-accepted",
            idempotency_key="wp3-accepted",
        )
        session.add(order)
        session.flush()
        from app.services.checkout.sql_inventory import reserve_catalog_quantity

        assert reserve_catalog_quantity(
            session,
            catalog_item_id=item.id,
            quantity=2,
        )
        session.add(
            InventoryReservation(
                order_id=order.id,
                business_stable_id=stable_id_for_application(application.id),
                catalog_item_stable_id="bread",
                quantity=2,
                status=InventoryReservationStatus.HELD.value,
                expires_at=datetime.now(UTC) - timedelta(minutes=1),
            )
        )
        session.commit()

    with Session(engine) as session:
        assert SqlOrderLifecycleService(session).expire_stale_reservations() == 0
        session.commit()
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 2
        reservation = session.scalars(select(InventoryReservation)).one()
        assert reservation.status == InventoryReservationStatus.HELD.value


@pytest.fixture
def api_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'wp3_api.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", _DIGEST_KEY)
    monkeypatch.delenv("QOSHNI_CONSUMER_CATALOG_ENABLED", raising=False)
    get_settings.cache_clear()
    database = create_engine(url, connect_args={"check_same_thread": False})
    Base.metadata.create_all(database)
    yield database
    database.dispose()
    get_settings.cache_clear()


@contextmanager
def _client(engine: Engine, provider: FakeOtpProvider) -> Generator[TestClient, None, None]:
    factory = sessionmaker(bind=engine, autoflush=False, autocommit=False, expire_on_commit=False)

    def override_db() -> Generator[Session, None, None]:
        db = factory()
        try:
            yield db
        finally:
            db.close()

    app = create_app()
    app.dependency_overrides[get_db] = override_db
    app.dependency_overrides[get_otp_delivery_provider] = lambda: provider
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()


def _sign_in(client: TestClient, provider: FakeOtpProvider, phone: str) -> str:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": phone})
    assert challenge.status_code == 202, challenge.text
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": challenge.json()["challenge_id"], "code": provider.last_code},
    )
    assert verify.status_code == 200, verify.text
    return verify.json()["access_token"]


def test_catalog_http_requires_auth_and_ignores_checkout_flag(api_engine: Engine) -> None:
    provider = FakeOtpProvider()
    with _client(api_engine, provider) as client:
        denied = client.post(
            f"/api/v1/business/onboarding/applications/{uuid.uuid4()}/catalog/items",
            json={
                "catalog_item_stable_id": "bread",
                "offering_kind": "product",
                "title": "Bread",
                "unit_price_minor": 8000,
            },
        )
        assert denied.status_code == 401
        token = _sign_in(client, provider, _OWNER_PHONE)
        with Session(api_engine) as session:
            owner = session.scalar(select(User).where(User.phone_e164 == _OWNER_PHONE))
            assert owner is not None
            application = _business(session, owner=owner)
            session.commit()
            application_id = application.id
        created = client.post(
            f"/api/v1/business/onboarding/applications/{application_id}/catalog/items",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "catalog_item_stable_id": "bread",
                "offering_kind": "product",
                "title": "Bread",
                "unit_price_minor": 8000,
            },
        )
        assert created.status_code == 201, created.text
        item_id = created.json()["catalog_item_id"]
        opened = client.post(
            f"/api/v1/business/onboarding/applications/{application_id}/catalog/items/{item_id}/inventory",
            headers={"Authorization": f"Bearer {token}"},
            json={"quantity_on_hand": 3, "reason": "first count"},
        )
        assert opened.status_code == 201, opened.text
        assert opened.json()["available_quantity"] == 3
        quote = client.post(
            "/api/v1/checkout/quotes",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "fulfillment_type": "pickup",
                "lines": [
                    {
                        "business_stable_id": stable_id_for_application(application_id),
                        "catalog_item_stable_id": "bread",
                        "quantity": 1,
                    }
                ],
            },
        )
        assert quote.status_code == 503


def test_maintenance_endpoint_records_a_run(api_engine: Engine) -> None:
    provider = FakeOtpProvider()
    with _client(api_engine, provider) as client:
        token = _sign_in(client, provider, _OTHER_PHONE)
        with Session(api_engine) as session:
            reviewer = session.scalar(select(User).where(User.phone_e164 == _OTHER_PHONE))
            assert reviewer is not None
            session.add(
                UserPlatformRoleAssignment(
                    user_id=reviewer.id,
                    role=PlatformRole.BUSINESS_ONBOARDING_REVIEWER.value,
                    grant_source=RoleAssignmentGrantSource.OPERATOR_CONTROL_PLANE.value,
                )
            )
            session.commit()
        headers = {"Authorization": f"Bearer {token}"}
        health = client.get("/api/v1/internal/inventory/reservation-maintenance", headers=headers)
        assert health.status_code == 200, health.text
        assert health.json()["overdue_held_count"] == 0
        run = client.post("/api/v1/internal/inventory/reservation-maintenance", headers=headers)
        assert run.status_code == 200, run.text
        assert run.json()["expired_count"] == 0
        assert run.json()["status"]["last_run_outcome"] == "succeeded"


def _pending_hold(session: Session, *, status: ConsumerOrderStatus) -> tuple[uuid.UUID, uuid.UUID, uuid.UUID]:
    from app.db.models.consumer_orders import ConsumerOrderItem
    from app.domain.order_lifecycle import ConsumerOrderFulfillmentStatus, ConsumerOrderPaymentStatus
    from app.services.checkout.sql_inventory import reserve_catalog_quantity

    application = _business(session)
    item = create_catalog_offering(
        session,
        owner_user_id=application.owner_user_id,
        business_application_id=application.id,
        catalog_item_stable_id="bread",
        offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
        title="Bread",
        unit_price_minor=8000,
    )
    assert isinstance(item, ConsumerCatalogItem)
    open_catalog_inventory(session, catalog_item_id=item.id, quantity_on_hand=5)
    buyer = User(phone_e164=_phone(), status=AccountStatus.ACTIVE.value)
    session.add(buyer)
    session.flush()
    order = ConsumerOrder(
        buyer_user_id=buyer.id,
        status=status.value,
        payment_status=ConsumerOrderPaymentStatus.UNPAID.value,
        fulfillment_status=ConsumerOrderFulfillmentStatus.NOT_STARTED.value,
        currency_code="UZS",
        subtotal_minor=8000,
        total_minor=8000,
        checkout_correlation_id="wp3-reject",
        idempotency_key=f"wp3-reject-{uuid.uuid4().hex}",
    )
    session.add(order)
    session.flush()
    session.add(
        ConsumerOrderItem(
            order_id=order.id,
            business_stable_id=stable_id_for_application(application.id),
            catalog_item_stable_id="bread",
            title_snapshot="Bread",
            quantity=2,
            unit_price_minor=8000,
            line_subtotal_minor=16000,
            currency_code="UZS",
        )
    )
    assert reserve_catalog_quantity(session, catalog_item_id=item.id, quantity=2)
    session.add(
        InventoryReservation(
            order_id=order.id,
            business_stable_id=stable_id_for_application(application.id),
            catalog_item_stable_id="bread",
            quantity=2,
            status=InventoryReservationStatus.HELD.value,
            expires_at=datetime.now(UTC) + timedelta(minutes=15),
        )
    )
    session.commit()
    return application.id, application.owner_user_id, order.id


def test_rejection_releases_stock_once(engine: Engine) -> None:
    with Session(engine) as session:
        application_id, owner_id, order_id = _pending_hold(
            session,
            status=ConsumerOrderStatus.PENDING_ACCEPTANCE,
        )
        first = SqlOrderLifecycleService(session).reject_order(
            owner_user_id=owner_id,
            business_application_id=application_id,
            order_id=order_id,
            reason="out of stock",
        )
        assert first.outcome == OrderRejectionOutcome.REJECTED
        assert first.record is not None
        assert first.record.status == ConsumerOrderStatus.REJECTED
        session.commit()

    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.quantity_on_hand == 5
        assert balance.reserved_quantity == 0
        assert balance.quantity_on_hand - balance.reserved_quantity == 5
        reservation = session.scalars(select(InventoryReservation)).one()
        assert reservation.status == InventoryReservationStatus.RELEASED.value
        second = SqlOrderLifecycleService(session).reject_order(
            owner_user_id=owner_id,
            business_application_id=application_id,
            order_id=order_id,
        )
        assert second.outcome == OrderRejectionOutcome.REPLAY
        session.commit()
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 0


def test_other_owner_and_accepted_order_are_not_rejected(engine: Engine) -> None:
    with Session(engine) as session:
        application_id, _owner_id, order_id = _pending_hold(
            session,
            status=ConsumerOrderStatus.ACCEPTED,
        )
        stranger = User(phone_e164=_phone(), status=AccountStatus.ACTIVE.value)
        session.add(stranger)
        session.commit()
        stranger_id = stranger.id
        denied = SqlOrderLifecycleService(session).reject_order(
            owner_user_id=stranger_id,
            business_application_id=application_id,
            order_id=order_id,
        )
        assert denied.outcome == OrderRejectionOutcome.NOT_FOUND
        blocked = SqlOrderLifecycleService(session).reject_order(
            owner_user_id=_owner_id,
            business_application_id=application_id,
            order_id=order_id,
        )
        assert blocked.outcome == OrderRejectionOutcome.INVALID_TRANSITION
        session.rollback()
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 2


def test_two_workers_reject_one_hold_once(engine: Engine) -> None:
    with Session(engine) as session:
        application_id, owner_id, order_id = _pending_hold(
            session,
            status=ConsumerOrderStatus.PENDING_ACCEPTANCE,
        )
    outcomes: list[str] = []

    def _reject() -> None:
        for _attempt in range(3):
            try:
                with Session(engine) as session:
                    result = SqlOrderLifecycleService(session).reject_order(
                        owner_user_id=owner_id,
                        business_application_id=application_id,
                        order_id=order_id,
                    )
                    if result.outcome in {
                        OrderRejectionOutcome.REJECTED,
                        OrderRejectionOutcome.REPLAY,
                    }:
                        session.commit()
                    else:
                        session.rollback()
                    outcomes.append(result.outcome.value)
                    return
            except OperationalError:
                continue
        raise AssertionError("rejection stayed locked")

    threads = [threading.Thread(target=_reject) for _ in range(2)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    assert outcomes.count(OrderRejectionOutcome.REJECTED.value) == 1
    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.quantity_on_hand == 5
        assert balance.reserved_quantity == 0
        order = session.get(ConsumerOrder, order_id)
        assert order is not None
        assert order.status == ConsumerOrderStatus.REJECTED.value


def test_worker_stays_idle_unless_explicitly_enabled(monkeypatch: pytest.MonkeyPatch) -> None:
    import inspect

    from app.main import create_app as build_app
    from app.main import lifespan
    from app.services.checkout.reservation_maintenance_worker import run_worker

    monkeypatch.setenv("QOSHNI_RESERVATION_MAINTENANCE_ENABLED", "false")
    get_settings.cache_clear()
    assert run_worker(max_iterations=5) == 0
    assert "run_worker" not in inspect.getsource(lifespan)
    assert "reservation_maintenance_worker" not in inspect.getsource(build_app)
    get_settings.cache_clear()


def test_recorded_sweep_survives_a_restart(engine: Engine) -> None:
    from app.db.models.consumer_catalog import InventoryMaintenanceRun
    from app.services.checkout.reservation_maintenance import run_recorded_sweep

    with Session(engine) as session:
        _application_id, _owner_id, order_id = _pending_hold(
            session,
            status=ConsumerOrderStatus.PENDING_ACCEPTANCE,
        )
        reservation = session.scalars(select(InventoryReservation)).one()
        reservation.expires_at = datetime.now(UTC) - timedelta(minutes=1)
        session.commit()
        assert run_recorded_sweep(session, worker_id="worker-a") == 1

    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 0
        order = session.get(ConsumerOrder, order_id)
        assert order is not None
        assert order.status == ConsumerOrderStatus.EXPIRED.value
        run = session.scalars(select(InventoryMaintenanceRun)).one()
        assert run.outcome == "succeeded"
        assert run.expired_count == 1
        assert run_recorded_sweep(session, worker_id="worker-a") == 0
