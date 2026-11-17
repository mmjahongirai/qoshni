"""Phase 18 Closure WP2 — database inventory, reservations, concurrency, idempotency."""

from __future__ import annotations

import threading
import uuid
from collections.abc import Generator
from contextlib import contextmanager
from datetime import UTC, datetime, timedelta
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient
from sqlalchemy import CheckConstraint, create_engine, func, inspect, select
from sqlalchemy.engine import Engine
from sqlalchemy.exc import IntegrityError, OperationalError
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.api.routes.orders import _replay_idempotent_order
from app.api.schemas.checkout_preparation import CheckoutCartLineRequest
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.consumer_catalog import ConsumerCatalogInventory
from app.db.models.consumer_orders import CheckoutQuote, ConsumerOrder, InventoryReservation
from app.db.models.identity import User
from app.domain.business_onboarding import BusinessServiceCategory, VerificationStatus
from app.domain.checkout_fulfillment import CheckoutFulfillmentType
from app.domain.consumer_catalog import ConsumerCatalogOfferingKind
from app.domain.identity import AccountStatus
from app.domain.inventory_reservation import InventoryReservationStatus
from app.main import create_app
from app.services.checkout.consumer_catalog_service import upsert_catalog_offering
from app.services.checkout.inventory_reservation_service import SkuKey
from app.services.checkout.order_placement_service import (
    OrderPlacementDependencies,
    OrderPlacementError,
    OrderPlacementErrorCode,
    PlaceOrderCommand,
    PlaceOrderSuccess,
    place_order,
)
from app.services.checkout.sql_catalog_authority import SqlConsumerCatalogAuthority
from app.services.checkout.sql_inventory import (
    SqlCatalogInventoryService,
    open_catalog_inventory,
)
from app.services.checkout.sql_order_repository import (
    SqlAlchemyOrderPlacementStore,
    SqlOrderLifecycleService,
    is_idempotency_unique_violation,
)
from app.services.search_discovery.stable_ids import stable_id_for_application
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "t" * 32
_BUYER_PHONE = "+998901240001"
BACKEND_ROOT = Path(__file__).resolve().parents[1]
INVENTORY_TABLE = "consumer_catalog_inventory"


def _phone() -> str:
    return f"+9989014{uuid.uuid4().int % 10000000:07d}"


def _seed(session: Session, *, on_hand: int | None) -> tuple[BusinessOnboardingApplication, str]:
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
        title="Fresh bread",
        unit_price_minor=8000,
    )
    assert not hasattr(item, "code")
    if on_hand is not None:
        open_catalog_inventory(session, catalog_item_id=item.id, quantity_on_hand=on_hand)
    session.commit()
    return application, stable_id_for_application(application.id)


def _command(
    buyer_id: uuid.UUID,
    business_stable_id: str,
    *,
    key: str,
    quantity: int = 1,
) -> PlaceOrderCommand:
    return PlaceOrderCommand(
        buyer_user_id=buyer_id,
        idempotency_key=key,
        fulfillment_type=CheckoutFulfillmentType.PICKUP,
        checkout_correlation_id="corr-wp2",
        server_quote_id=str(uuid.uuid4()),
        server_quote_revision=1,
        lines=[
            CheckoutCartLineRequest(
                business_stable_id=business_stable_id,
                catalog_item_stable_id="bread",
                quantity=quantity,
            )
        ],
        client_submitted_total_minor=1,
    )


def _deps(session: Session) -> OrderPlacementDependencies:
    return OrderPlacementDependencies(
        catalog=SqlConsumerCatalogAuthority(session),
        store=SqlAlchemyOrderPlacementStore(session),
        inventory=SqlCatalogInventoryService(session),
    )


def _ensure_buyer_and_quote(session: Session, command: PlaceOrderCommand) -> None:
    if session.get(User, command.buyer_user_id) is None:
        session.add(
            User(
                id=command.buyer_user_id,
                phone_e164=_phone(),
                status=AccountStatus.ACTIVE.value,
            )
        )
        session.flush()
    quote_id = uuid.UUID(command.server_quote_id)
    if session.get(CheckoutQuote, quote_id) is None:
        quantity = command.lines[0].quantity
        session.add(
            CheckoutQuote(
                id=quote_id,
                buyer_user_id=command.buyer_user_id,
                request_fingerprint="wp2-test",
                fulfillment_type=command.fulfillment_type.value,
                currency_code="UZS",
                subtotal_minor=8000 * quantity,
                total_minor=8000 * quantity,
                pricing_revision=command.server_quote_revision or 1,
                expires_at=datetime.now(UTC) + timedelta(minutes=15),
            )
        )
        session.flush()


def _commit_placement(
    session: Session,
    command: PlaceOrderCommand,
) -> PlaceOrderSuccess | OrderPlacementError:
    _ensure_buyer_and_quote(session, command)
    result = place_order(command, _deps(session))
    if isinstance(result, OrderPlacementError):
        session.rollback()
        return result
    if result.idempotent_replay:
        return result
    try:
        session.commit()
    except IntegrityError as exc:
        session.rollback()
        if not is_idempotency_unique_violation(exc):
            raise
        replayed = _replay_idempotent_order(session, command)
        if replayed is None:
            raise
        return replayed
    return result


@pytest.fixture
def engine(tmp_path: Path) -> Generator[Engine, None, None]:
    database = create_engine(
        f"sqlite:///{(tmp_path / 'inventory.db').as_posix()}",
        connect_args={"check_same_thread": False, "timeout": 30},
    )
    Base.metadata.create_all(database)
    yield database
    database.dispose()


def test_open_inventory_requires_an_explicit_non_negative_count(engine: Engine) -> None:
    with Session(engine) as session:
        _application, _stable = _seed(session, on_hand=None)
        item_id = session.scalar(select(ConsumerCatalogInventory.catalog_item_id))
        assert item_id is None
        from app.db.models.consumer_catalog import ConsumerCatalogItem

        catalog_item_id = session.scalar(select(ConsumerCatalogItem.id))
        with pytest.raises(ValueError):
            open_catalog_inventory(session, catalog_item_id=catalog_item_id, quantity_on_hand=-1)


def test_balance_read_and_reserve_keep_available_consistent(engine: Engine) -> None:
    with Session(engine) as session:
        _application, stable = _seed(session, on_hand=8)
        authority = SqlConsumerCatalogAuthority(session)
        before = authority.resolve_line(
            business_stable_id=stable,
            catalog_item_stable_id="bread",
            requested_quantity=1,
        )
        assert before is not None
        assert before.available_quantity == 8

        reserved = SqlCatalogInventoryService(session).reserve_for_order(
            sku=SkuKey(stable, "bread"),
            quantity=3,
            order_id=uuid.uuid4(),
        )
        assert reserved is not None
        session.commit()

    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.quantity_on_hand == 8
        assert balance.reserved_quantity == 3
        assert balance.quantity_on_hand - balance.reserved_quantity == 5
        after = SqlConsumerCatalogAuthority(session).resolve_line(
            business_stable_id=stable_id_for_application(
                session.scalar(
                    select(BusinessOnboardingApplication.id)
                )
            ),
            catalog_item_stable_id="bread",
            requested_quantity=1,
        )
        assert after is not None
        assert after.available_quantity == 5


def test_insufficient_stock_reserves_nothing(engine: Engine) -> None:
    with Session(engine) as session:
        _application, stable = _seed(session, on_hand=1)
        result = _commit_placement(session, _command(uuid.uuid4(), stable, key="short", quantity=2))
        assert isinstance(result, OrderPlacementError)
        assert result.code == OrderPlacementErrorCode.INSUFFICIENT_STOCK

    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 0
        assert session.scalar(select(func.count()).select_from(ConsumerOrder)) == 0
        assert session.scalar(select(func.count()).select_from(InventoryReservation)) == 0


def test_successful_order_holds_stock_and_ignores_client_total(engine: Engine) -> None:
    buyer = uuid.uuid4()
    with Session(engine) as session:
        _application, stable = _seed(session, on_hand=10)
        command = _command(buyer, stable, key="ok-1", quantity=2)
        result = _commit_placement(session, command)
        assert isinstance(result, PlaceOrderSuccess)
        assert result.order.total_minor == 16000
        order_id = result.order.order_id

    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 2
        reservation = session.scalars(select(InventoryReservation)).one()
        assert reservation.order_id == order_id
        assert reservation.expires_at is not None
        assert reservation.status == InventoryReservationStatus.HELD.value
        replay = _commit_placement(session, command)
        assert isinstance(replay, PlaceOrderSuccess)
        assert replay.idempotent_replay is True
        assert replay.order.order_id == order_id

    with Session(engine) as session:
        assert session.scalars(select(ConsumerCatalogInventory)).one().reserved_quantity == 2
        assert session.scalar(select(func.count()).select_from(ConsumerOrder)) == 1


def test_cancel_releases_the_hold(engine: Engine) -> None:
    buyer = uuid.uuid4()
    with Session(engine) as session:
        _application, stable = _seed(session, on_hand=4)
        placed = _commit_placement(session, _command(buyer, stable, key="cancel-1"))
        assert isinstance(placed, PlaceOrderSuccess)
        order_id = placed.order.order_id

    with Session(engine) as session:
        cancelled = SqlOrderLifecycleService(session).cancel_order(
            buyer_user_id=buyer,
            order_id=order_id,
        )
        assert cancelled is not None
        session.commit()

    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 0
        assert balance.quantity_on_hand == 4
        reservation = session.scalars(select(InventoryReservation)).one()
        assert reservation.status == InventoryReservationStatus.RELEASED.value
        again = SqlOrderLifecycleService(session).cancel_order(
            buyer_user_id=buyer,
            order_id=order_id,
        )
        session.commit()
        assert again is not None
        assert session.scalars(select(ConsumerCatalogInventory)).one().reserved_quantity == 0


def test_expired_hold_is_released_once(engine: Engine) -> None:
    buyer = uuid.uuid4()
    with Session(engine) as session:
        _application, stable = _seed(session, on_hand=3)
        placed = _commit_placement(session, _command(buyer, stable, key="expire-1"))
        assert isinstance(placed, PlaceOrderSuccess)
        reservation = session.scalars(select(InventoryReservation)).one()
        reservation.expires_at = datetime.now(UTC) - timedelta(minutes=1)
        session.commit()

    with Session(engine) as session:
        expired = SqlOrderLifecycleService(session).expire_stale_reservations()
        session.commit()
        assert expired == 1

    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 0
        reservation = session.scalars(select(InventoryReservation)).one()
        assert reservation.status == InventoryReservationStatus.EXPIRED.value
        order = session.get(ConsumerOrder, reservation.order_id)
        assert order is not None
        assert order.status == "expired"
        assert SqlOrderLifecycleService(session).expire_stale_reservations() == 0


def test_rollback_undoes_a_hold(engine: Engine) -> None:
    with Session(engine) as session:
        _application, stable = _seed(session, on_hand=6)
        reserved = SqlCatalogInventoryService(session).reserve_for_order(
            sku=SkuKey(stable, "bread"),
            quantity=2,
            order_id=uuid.uuid4(),
        )
        assert reserved is not None
        session.rollback()

    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 0
        assert balance.quantity_on_hand == 6


def test_balance_cannot_go_negative(engine: Engine) -> None:
    with Session(engine) as session:
        _application, _stable = _seed(session, on_hand=2)
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        balance.reserved_quantity = 3
        with pytest.raises(IntegrityError):
            session.commit()


def _run_together(workers: list) -> list:
    barrier = threading.Barrier(len(workers))
    results: list = [None] * len(workers)

    def run(index: int, worker) -> None:
        barrier.wait()
        for _ in range(3):
            try:
                results[index] = worker()
                return
            except OperationalError:
                continue
        results[index] = "busy"

    threads = [threading.Thread(target=run, args=(index, worker)) for index, worker in enumerate(workers)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    return results


def test_parallel_orders_do_not_oversell(engine: Engine) -> None:
    with Session(engine) as session:
        _application, stable = _seed(session, on_hand=1)

    def worker(key: str):
        def attempt():
            with Session(engine) as session:
                return _commit_placement(session, _command(uuid.uuid4(), stable, key=key))

        return attempt

    results = _run_together([worker("parallel-a"), worker("parallel-b")])
    assert "busy" not in results
    successes = [result for result in results if isinstance(result, PlaceOrderSuccess)]
    failures = [result for result in results if isinstance(result, OrderPlacementError)]
    assert len(successes) == 1
    assert len(failures) == 1
    assert failures[0].code == OrderPlacementErrorCode.INSUFFICIENT_STOCK

    with Session(engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.quantity_on_hand == 1
        assert balance.reserved_quantity == 1
        assert balance.quantity_on_hand - balance.reserved_quantity >= 0
        assert session.scalar(select(func.count()).select_from(ConsumerOrder)) == 1


def test_parallel_same_key_keeps_a_single_order(engine: Engine) -> None:
    buyer = uuid.uuid4()
    with Session(engine) as session:
        _application, stable = _seed(session, on_hand=5)
        command = _command(buyer, stable, key="same-key", quantity=1)
        _ensure_buyer_and_quote(session, command)
        session.commit()

    def attempt():
        with Session(engine) as session:
            return _commit_placement(session, command)

    results = _run_together([attempt, attempt])
    assert "busy" not in results

    with Session(engine) as session:
        assert session.scalar(select(func.count()).select_from(ConsumerOrder)) == 1
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 1
        follow_up = _commit_placement(session, command)
        assert isinstance(follow_up, PlaceOrderSuccess)
        assert follow_up.idempotent_replay is True


def test_missing_balance_does_not_place_an_order(engine: Engine) -> None:
    with Session(engine) as session:
        _application, stable = _seed(session, on_hand=None)
        resolved = SqlConsumerCatalogAuthority(session).resolve_line(
            business_stable_id=stable,
            catalog_item_stable_id="bread",
            requested_quantity=1,
        )
        assert resolved is not None
        assert resolved.available_quantity is None
        result = _commit_placement(session, _command(uuid.uuid4(), stable, key="no-balance"))
        assert isinstance(result, OrderPlacementError)
        assert result.code == OrderPlacementErrorCode.AUTHORITATIVE_INVENTORY_UNAVAILABLE
        assert session.scalar(select(func.count()).select_from(ConsumerOrder)) == 0


# --- HTTP ----------------------------------------------------------------------


@contextmanager
def _http_client(
    database: Engine,
    fake_provider: FakeOtpProvider,
) -> Generator[TestClient, None, None]:
    factory = sessionmaker(bind=database, autoflush=False, autocommit=False)

    def override_db() -> Generator[Session, None, None]:
        db = factory()
        try:
            yield db
        finally:
            db.close()

    app = create_app()
    app.dependency_overrides[get_db] = override_db
    app.dependency_overrides[get_otp_delivery_provider] = lambda: fake_provider
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()


@pytest.fixture
def api_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'inventory_api.db').as_posix()}"
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", _DIGEST_KEY)
    get_settings.cache_clear()
    database = create_engine(url, connect_args={"check_same_thread": False})
    Base.metadata.create_all(database)
    yield database
    database.dispose()
    get_settings.cache_clear()


@pytest.fixture
def fake_provider() -> FakeOtpProvider:
    return FakeOtpProvider()


def _auth(client: TestClient, fake_provider: FakeOtpProvider) -> dict[str, str]:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": _BUYER_PHONE})
    assert challenge.status_code == 202, challenge.text
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": challenge.json()["challenge_id"], "code": fake_provider.last_code},
    )
    assert verify.status_code == 200, verify.text
    return {"Authorization": f"Bearer {verify.json()['access_token']}"}


def _quote_and_place(
    client: TestClient,
    headers: dict[str, str],
    stable: str,
    *,
    key: str,
) -> tuple[object, object]:
    lines = [{"business_stable_id": stable, "catalog_item_stable_id": "bread", "quantity": 2}]
    quote = client.post(
        "/api/v1/checkout/quotes",
        json={"fulfillment_type": "pickup", "lines": lines},
        headers=headers,
    )
    assert quote.status_code == 200, quote.text
    body = quote.json()
    placed = client.post(
        "/api/v1/orders",
        json={
            "fulfillment_type": "pickup",
            "checkout_correlation_id": "corr-http",
            "server_quote_id": body["quote_id"],
            "server_quote_revision": body["pricing_revision"],
            "client_submitted_total_minor": 1,
            "lines": lines,
        },
        headers={**headers, "Idempotency-Key": key},
    )
    return quote, placed


def test_http_place_and_cancel_round_trip(
    api_engine: Engine,
    fake_provider: FakeOtpProvider,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("QOSHNI_CONSUMER_CATALOG_ENABLED", "true")
    get_settings.cache_clear()
    with Session(api_engine) as session:
        _application, stable = _seed(session, on_hand=9)
    with _http_client(api_engine, fake_provider) as client:
        headers = _auth(client, fake_provider)
        _quote, placed = _quote_and_place(client, headers, stable, key="http-1")
        assert placed.status_code == 200, placed.text
        assert placed.json()["total_minor"] == 16000
        order_id = placed.json()["order_id"]
        cancelled = client.post(f"/api/v1/orders/{order_id}/cancel", headers=headers)
        assert cancelled.status_code == 200, cancelled.text
        assert cancelled.json()["status"] == "cancelled"

    with Session(api_engine) as session:
        balance = session.scalars(select(ConsumerCatalogInventory)).one()
        assert balance.reserved_quantity == 0
        reservation = session.scalars(select(InventoryReservation)).one()
        assert reservation.status == InventoryReservationStatus.RELEASED.value


def test_http_catalog_disabled_stays_fail_closed(
    api_engine: Engine,
    fake_provider: FakeOtpProvider,
) -> None:
    with Session(api_engine) as session:
        _application, stable = _seed(session, on_hand=9)
    get_settings.cache_clear()
    with _http_client(api_engine, fake_provider) as client:
        headers = _auth(client, fake_provider)
        response = client.post(
            "/api/v1/orders",
            json={
                "fulfillment_type": "pickup",
                "checkout_correlation_id": "corr-off",
                "server_quote_id": str(uuid.uuid4()),
                "server_quote_revision": 1,
                "lines": [
                    {
                        "business_stable_id": stable,
                        "catalog_item_stable_id": "bread",
                        "quantity": 1,
                    }
                ],
            },
            headers={**headers, "Idempotency-Key": "off-1"},
        )
        assert response.status_code == 503
        assert response.json()["code"] == "authoritative_catalog_unavailable"
    with Session(api_engine) as session:
        assert session.scalars(select(ConsumerCatalogInventory)).one().reserved_quantity == 0
        assert session.scalar(select(func.count()).select_from(ConsumerOrder)) == 0


# --- Migration ------------------------------------------------------------------


def test_inventory_migration_upgrade_and_downgrade(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    url = f"sqlite:///{(tmp_path / 'inventory_migration.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    get_settings.cache_clear()
    config = Config()
    config.set_main_option("script_location", str(BACKEND_ROOT / "alembic"))
    database = create_engine(url)
    command.upgrade(config, "head")
    inspector = inspect(database)
    assert INVENTORY_TABLE in inspector.get_table_names()
    migrated = {check["name"] for check in inspector.get_check_constraints(INVENTORY_TABLE)}
    declared = {
        constraint.name
        for constraint in Base.metadata.tables[INVENTORY_TABLE].constraints
        if isinstance(constraint, CheckConstraint)
    }
    assert migrated == declared
    command.downgrade(config, "b0a1f0180002")
    assert INVENTORY_TABLE not in inspect(database).get_table_names()
    command.upgrade(config, "head")
    assert INVENTORY_TABLE in inspect(database).get_table_names()
    database.dispose()
    get_settings.cache_clear()
