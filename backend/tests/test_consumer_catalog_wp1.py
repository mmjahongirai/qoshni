"""Phase 18 Closure WP1 — SQL consumer catalog authority, pricing integrity, fail-closed default."""

from __future__ import annotations

import uuid
from collections.abc import Generator
from datetime import UTC, datetime
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient
from sqlalchemy import CheckConstraint, create_engine, func, inspect, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps.auth import get_otp_delivery_provider
from app.api.deps.checkout import get_consumer_catalog_authority
from app.core.config import get_settings
from app.core.database import get_db
from app.db.base import Base
from app.db.models.business_onboarding import BusinessOnboardingApplication
from app.db.models.consumer_catalog import ConsumerCatalogItem
from app.db.models.consumer_orders import CheckoutQuoteLine, ConsumerOrder, OrderIdempotencyRecord
from app.db.models.identity import User
from app.domain.business_onboarding import BusinessServiceCategory, VerificationStatus
from app.domain.consumer_catalog import ConsumerCatalogItemStatus, ConsumerCatalogOfferingKind
from app.domain.identity import AccountStatus
from app.main import create_app
from app.services.checkout.catalog_authority import UnavailableConsumerCatalogAuthority
from app.services.checkout.consumer_catalog_service import (
    ConsumerCatalogWriteError,
    ConsumerCatalogWriteErrorCode,
    upsert_catalog_offering,
)
from app.services.checkout.sql_catalog_authority import SqlConsumerCatalogAuthority
from app.services.search_discovery.stable_ids import (
    application_id_from_stable_id,
    stable_id_for_application,
)
from tests.support.fake_otp_provider import FakeOtpProvider

_DIGEST_KEY = "t" * 32
_BUYER_PHONE = "+998901230001"
BACKEND_ROOT = Path(__file__).resolve().parents[1]
CATALOG_TABLE = "consumer_catalog_items"


def _phone() -> str:
    return f"+9989013{uuid.uuid4().int % 10000000:07d}"


def _seed_business(
    session: Session,
    *,
    status: VerificationStatus = VerificationStatus.VERIFIED,
) -> BusinessOnboardingApplication:
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
        verification_status=status.value,
        rejection_reason_code="other" if status == VerificationStatus.REJECTED else None,
        submitted_at=None if status == VerificationStatus.DRAFT else datetime.now(UTC),
    )
    session.add(application)
    session.flush()
    return application


def _publish(
    session: Session,
    application: BusinessOnboardingApplication,
    *,
    item_id: str = "bread",
    price: int = 8000,
    status: ConsumerCatalogItemStatus = ConsumerCatalogItemStatus.ACTIVE,
) -> ConsumerCatalogItem:
    result = upsert_catalog_offering(
        session,
        owner_user_id=application.owner_user_id,
        business_application_id=application.id,
        catalog_item_stable_id=item_id,
        offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
        title="Fresh bread",
        unit_price_minor=price,
        status=status,
    )
    assert isinstance(result, ConsumerCatalogItem), result
    return result


# --- Stable identifiers ---------------------------------------------------


def test_application_stable_id_round_trip() -> None:
    app_id = uuid.uuid4()
    assert application_id_from_stable_id(stable_id_for_application(app_id)) == app_id


@pytest.mark.parametrize(
    "value",
    [
        "baraka-market",
        "business:onboarding:not-a-uuid",
        "business:onboarding:",
        "business:onboarding:ABCDEF00-0000-0000-0000-000000000001",
        f"business:onboarding:{uuid.UUID(int=1)} ",
        f"other:onboarding:{uuid.UUID(int=1)}",
    ],
)
def test_application_stable_id_rejects_other_shapes(value: str) -> None:
    assert application_id_from_stable_id(value) is None


# --- Session-level authority & writes ---------------------------------------


@pytest.fixture
def session(tmp_path: Path) -> Generator[Session, None, None]:
    engine = create_engine(f"sqlite:///{(tmp_path / 'catalog.db').as_posix()}")
    Base.metadata.create_all(engine)
    factory = sessionmaker(bind=engine, autoflush=False, autocommit=False)
    db = factory()
    try:
        yield db
    finally:
        db.close()
        engine.dispose()


def _resolve(session: Session, business_stable_id: str, item_id: str = "bread"):
    return SqlConsumerCatalogAuthority(session).resolve_line(
        business_stable_id=business_stable_id,
        catalog_item_stable_id=item_id,
        requested_quantity=1,
    )


def test_sql_catalog_resolves_active_item_of_verified_business(session: Session) -> None:
    application = _seed_business(session)
    _publish(session, application, price=8000)

    line = _resolve(session, stable_id_for_application(application.id))

    assert line is not None
    assert line.unit_price_minor == 8000
    assert line.currency_code == "UZS"
    assert line.pricing_revision == 1
    assert line.title_snapshot == "Fresh bread"
    assert line.available_quantity is None
    assert SqlConsumerCatalogAuthority(session).is_operational() is True


@pytest.mark.parametrize(
    "status",
    [
        VerificationStatus.DRAFT,
        VerificationStatus.SUBMITTED,
        VerificationStatus.UNDER_REVIEW,
        VerificationStatus.REJECTED,
        VerificationStatus.SUSPENDED,
    ],
)
def test_sql_catalog_rejects_business_that_is_not_verified(
    session: Session,
    status: VerificationStatus,
) -> None:
    application = _seed_business(session)
    _publish(session, application)
    application.verification_status = status.value
    application.rejection_reason_code = "other" if status == VerificationStatus.REJECTED else None
    session.flush()

    assert _resolve(session, stable_id_for_application(application.id)) is None


@pytest.mark.parametrize(
    "status",
    [ConsumerCatalogItemStatus.INACTIVE, ConsumerCatalogItemStatus.ARCHIVED],
)
def test_sql_catalog_rejects_non_active_item(
    session: Session,
    status: ConsumerCatalogItemStatus,
) -> None:
    application = _seed_business(session)
    _publish(session, application, status=status)

    assert _resolve(session, stable_id_for_application(application.id)) is None


def test_sql_catalog_rejects_unknown_item_and_malformed_business(session: Session) -> None:
    application = _seed_business(session)
    _publish(session, application)

    assert _resolve(session, stable_id_for_application(application.id), "missing") is None
    assert _resolve(session, stable_id_for_application(uuid.uuid4())) is None
    assert _resolve(session, "baraka-market") is None


def test_sql_catalog_does_not_resolve_item_under_another_business(session: Session) -> None:
    owner_business = _seed_business(session)
    other_business = _seed_business(session)
    _publish(session, owner_business, item_id="bread")

    assert _resolve(session, stable_id_for_application(other_business.id), "bread") is None


def test_upsert_bumps_pricing_revision_only_on_price_change(session: Session) -> None:
    application = _seed_business(session)
    item = _publish(session, application, price=8000)
    assert item.pricing_revision == 1

    same_price = _publish(session, application, price=8000)
    assert same_price.id == item.id
    assert same_price.pricing_revision == 1

    changed = _publish(session, application, price=9000)
    assert changed.id == item.id
    assert changed.pricing_revision == 2
    assert changed.unit_price_minor == 9000


def test_upsert_rejects_non_owner_without_disclosing_business(session: Session) -> None:
    application = _seed_business(session)
    result = upsert_catalog_offering(
        session,
        owner_user_id=uuid.uuid4(),
        business_application_id=application.id,
        catalog_item_stable_id="bread",
        offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
        title="Bread",
        unit_price_minor=8000,
    )
    assert isinstance(result, ConsumerCatalogWriteError)
    assert result.code == ConsumerCatalogWriteErrorCode.BUSINESS_NOT_FOUND
    assert session.scalar(select(func.count()).select_from(ConsumerCatalogItem)) == 0


def test_upsert_rejects_unverified_business(session: Session) -> None:
    application = _seed_business(session, status=VerificationStatus.UNDER_REVIEW)
    result = upsert_catalog_offering(
        session,
        owner_user_id=application.owner_user_id,
        business_application_id=application.id,
        catalog_item_stable_id="bread",
        offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
        title="Bread",
        unit_price_minor=8000,
    )
    assert isinstance(result, ConsumerCatalogWriteError)
    assert result.code == ConsumerCatalogWriteErrorCode.BUSINESS_NOT_VERIFIED


@pytest.mark.parametrize("price", [-1, True, 1_000_000_001])
def test_upsert_rejects_invalid_prices(session: Session, price: int) -> None:
    application = _seed_business(session)
    result = upsert_catalog_offering(
        session,
        owner_user_id=application.owner_user_id,
        business_application_id=application.id,
        catalog_item_stable_id="bread",
        offering_kind=ConsumerCatalogOfferingKind.PRODUCT,
        title="Bread",
        unit_price_minor=price,
    )
    assert isinstance(result, ConsumerCatalogWriteError)
    assert result.code == ConsumerCatalogWriteErrorCode.VALIDATION_FAILED


# --- HTTP integration ---------------------------------------------------------


@pytest.fixture
def catalog_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[Engine, None, None]:
    url = f"sqlite:///{(tmp_path / 'catalog_api.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    monkeypatch.setenv("QOSHNI_AUTH_SECRET_DIGEST_KEY", _DIGEST_KEY)
    get_settings.cache_clear()
    engine = create_engine(url, connect_args={"check_same_thread": False})
    Base.metadata.create_all(engine)
    yield engine
    engine.dispose()
    get_settings.cache_clear()


@pytest.fixture
def fake_provider() -> FakeOtpProvider:
    return FakeOtpProvider()


def _client(engine: Engine, fake_provider: FakeOtpProvider) -> Generator[TestClient, None, None]:
    factory = sessionmaker(bind=engine, autoflush=False, autocommit=False)

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
def enabled_client(
    catalog_engine: Engine,
    fake_provider: FakeOtpProvider,
    monkeypatch: pytest.MonkeyPatch,
) -> Generator[TestClient, None, None]:
    monkeypatch.setenv("QOSHNI_CONSUMER_CATALOG_ENABLED", "true")
    get_settings.cache_clear()
    yield from _client(catalog_engine, fake_provider)


@pytest.fixture
def default_client(
    catalog_engine: Engine,
    fake_provider: FakeOtpProvider,
) -> Generator[TestClient, None, None]:
    yield from _client(catalog_engine, fake_provider)


@pytest.fixture
def verified_business(catalog_engine: Engine) -> BusinessOnboardingApplication:
    with Session(catalog_engine) as db:
        application = _seed_business(db)
        _publish(db, application, item_id="bread", price=8000)
        db.commit()
        db.refresh(application)
        db.expunge(application)
        return application


def _auth_headers(client: TestClient, fake_provider: FakeOtpProvider) -> dict[str, str]:
    challenge = client.post("/api/v1/auth/otp/challenges", json={"phone": _BUYER_PHONE})
    assert challenge.status_code == 202, challenge.text
    code = fake_provider.last_code
    assert code is not None
    verify = client.post(
        "/api/v1/auth/otp/verify",
        json={"challenge_id": challenge.json()["challenge_id"], "code": code},
    )
    assert verify.status_code == 200, verify.text
    return {"Authorization": f"Bearer {verify.json()['access_token']}"}


def _lines(business: BusinessOnboardingApplication, quantity: int = 2) -> list[dict[str, object]]:
    return [
        {
            "business_stable_id": stable_id_for_application(business.id),
            "catalog_item_stable_id": "bread",
            "quantity": quantity,
        }
    ]


def _issue_quote(
    client: TestClient,
    headers: dict[str, str],
    business: BusinessOnboardingApplication,
) -> dict[str, object]:
    response = client.post(
        "/api/v1/checkout/quotes",
        json={"fulfillment_type": "pickup", "lines": _lines(business)},
        headers=headers,
    )
    assert response.status_code == 200, response.text
    return response.json()


def _place(
    client: TestClient,
    headers: dict[str, str],
    business: BusinessOnboardingApplication,
    quote: dict[str, object],
    *,
    key: str,
    revision: object | None = None,
):
    return client.post(
        "/api/v1/orders",
        json={
            "fulfillment_type": "pickup",
            "checkout_correlation_id": "corr-wp1",
            "server_quote_id": quote["quote_id"],
            "server_quote_revision": quote["pricing_revision"] if revision is None else revision,
            "lines": _lines(business),
        },
        headers={**headers, "Idempotency-Key": key},
    )


def _set_price(engine: Engine, business: BusinessOnboardingApplication, price: int) -> None:
    with Session(engine) as db:
        _publish(db, db.get(BusinessOnboardingApplication, business.id), price=price)
        db.commit()


def test_prepare_prices_from_sql_catalog_and_ignores_client_total(
    enabled_client: TestClient,
    fake_provider: FakeOtpProvider,
    verified_business: BusinessOnboardingApplication,
) -> None:
    headers = _auth_headers(enabled_client, fake_provider)
    response = enabled_client.post(
        "/api/v1/checkout/prepare",
        json={
            "fulfillment_type": "pickup",
            "lines": _lines(verified_business),
            "client_submitted_total_minor": 1,
        },
        headers=headers,
    )
    assert response.status_code == 200, response.text
    body = response.json()
    assert body["is_demo_pricing"] is False
    assert body["total_minor"] == 16000
    assert body["lines"][0]["unit_price_minor"] == 8000


def test_quote_records_catalog_pricing_revision(
    enabled_client: TestClient,
    fake_provider: FakeOtpProvider,
    verified_business: BusinessOnboardingApplication,
    catalog_engine: Engine,
) -> None:
    _set_price(catalog_engine, verified_business, 8500)
    headers = _auth_headers(enabled_client, fake_provider)

    quote = _issue_quote(enabled_client, headers, verified_business)

    assert quote["pricing_revision"] == 2
    assert quote["total_minor"] == 17000
    with Session(catalog_engine) as db:
        line = db.scalars(select(CheckoutQuoteLine)).one()
        assert line.catalog_pricing_revision == 2
        assert line.unit_price_minor == 8500


@pytest.mark.parametrize("path", ["/api/v1/checkout/prepare", "/api/v1/checkout/quotes"])
def test_client_supplied_line_price_is_rejected(
    enabled_client: TestClient,
    fake_provider: FakeOtpProvider,
    verified_business: BusinessOnboardingApplication,
    path: str,
) -> None:
    headers = _auth_headers(enabled_client, fake_provider)
    tampered = _lines(verified_business)
    tampered[0]["unit_price_minor"] = 1
    response = enabled_client.post(
        path,
        json={"fulfillment_type": "pickup", "lines": tampered},
        headers=headers,
    )
    assert response.status_code == 422


def test_client_supplied_line_price_is_rejected_on_place_order(
    enabled_client: TestClient,
    fake_provider: FakeOtpProvider,
    verified_business: BusinessOnboardingApplication,
    catalog_engine: Engine,
) -> None:
    headers = _auth_headers(enabled_client, fake_provider)
    quote = _issue_quote(enabled_client, headers, verified_business)
    tampered = _lines(verified_business)
    tampered[0]["unit_price_minor"] = 1
    response = enabled_client.post(
        "/api/v1/orders",
        json={
            "fulfillment_type": "pickup",
            "checkout_correlation_id": "corr-wp1",
            "server_quote_id": quote["quote_id"],
            "server_quote_revision": quote["pricing_revision"],
            "lines": tampered,
        },
        headers={**headers, "Idempotency-Key": "tamper-1"},
    )
    assert response.status_code == 422
    with Session(catalog_engine) as db:
        assert db.scalar(select(func.count()).select_from(ConsumerOrder)) == 0


def test_place_order_rejects_quote_after_price_change(
    enabled_client: TestClient,
    fake_provider: FakeOtpProvider,
    verified_business: BusinessOnboardingApplication,
    catalog_engine: Engine,
) -> None:
    headers = _auth_headers(enabled_client, fake_provider)
    quote = _issue_quote(enabled_client, headers, verified_business)
    _set_price(catalog_engine, verified_business, 9000)

    response = _place(enabled_client, headers, verified_business, quote, key="drift-1")

    assert response.status_code == 400, response.text
    assert response.json()["code"] == "stale_quote"
    assert "pricing changed" in response.json()["message"]
    with Session(catalog_engine) as db:
        assert db.scalar(select(func.count()).select_from(ConsumerOrder)) == 0
        assert db.scalar(select(func.count()).select_from(OrderIdempotencyRecord)) == 0


def test_place_order_rejects_stale_client_pricing_revision(
    enabled_client: TestClient,
    fake_provider: FakeOtpProvider,
    verified_business: BusinessOnboardingApplication,
) -> None:
    headers = _auth_headers(enabled_client, fake_provider)
    quote = _issue_quote(enabled_client, headers, verified_business)

    response = _place(
        enabled_client,
        headers,
        verified_business,
        quote,
        key="stale-rev-1",
        revision=int(quote["pricing_revision"]) + 1,
    )

    assert response.status_code == 400
    assert response.json()["code"] == "stale_quote"


@pytest.mark.parametrize(
    "mutation",
    ["archive_item", "suspend_business"],
)
def test_place_order_rejects_quote_when_offering_disappears(
    enabled_client: TestClient,
    fake_provider: FakeOtpProvider,
    verified_business: BusinessOnboardingApplication,
    catalog_engine: Engine,
    mutation: str,
) -> None:
    headers = _auth_headers(enabled_client, fake_provider)
    quote = _issue_quote(enabled_client, headers, verified_business)
    with Session(catalog_engine) as db:
        if mutation == "archive_item":
            item = db.scalars(select(ConsumerCatalogItem)).one()
            item.status = ConsumerCatalogItemStatus.ARCHIVED.value
        else:
            application = db.get(BusinessOnboardingApplication, verified_business.id)
            application.verification_status = VerificationStatus.SUSPENDED.value
        db.commit()

    response = _place(enabled_client, headers, verified_business, quote, key=f"gone-{mutation}")

    assert response.status_code == 400
    assert response.json()["code"] == "stale_quote"
    assert "no longer available" in response.json()["message"]


def test_quote_rejected_for_unverified_business(
    enabled_client: TestClient,
    fake_provider: FakeOtpProvider,
    catalog_engine: Engine,
) -> None:
    with Session(catalog_engine) as db:
        application = _seed_business(db)
        _publish(db, application)
        application.verification_status = VerificationStatus.UNDER_REVIEW.value
        db.commit()
        db.refresh(application)
        db.expunge(application)
    headers = _auth_headers(enabled_client, fake_provider)

    response = enabled_client.post(
        "/api/v1/checkout/quotes",
        json={"fulfillment_type": "pickup", "lines": _lines(application)},
        headers=headers,
    )

    assert response.status_code == 400
    assert response.json()["code"] == "validation_failed"


def test_place_order_fails_closed_without_authoritative_inventory(
    enabled_client: TestClient,
    fake_provider: FakeOtpProvider,
    verified_business: BusinessOnboardingApplication,
    catalog_engine: Engine,
) -> None:
    headers = _auth_headers(enabled_client, fake_provider)
    quote = _issue_quote(enabled_client, headers, verified_business)

    response = _place(enabled_client, headers, verified_business, quote, key="inv-1")

    assert response.status_code == 503
    assert response.json()["code"] == "authoritative_inventory_unavailable"
    with Session(catalog_engine) as db:
        assert db.scalar(select(func.count()).select_from(ConsumerOrder)) == 0


@pytest.mark.parametrize(
    "path",
    ["/api/v1/checkout/prepare", "/api/v1/checkout/quotes", "/api/v1/orders"],
)
def test_default_settings_keep_catalog_fail_closed(
    default_client: TestClient,
    fake_provider: FakeOtpProvider,
    verified_business: BusinessOnboardingApplication,
    path: str,
) -> None:
    headers = _auth_headers(default_client, fake_provider)
    body: dict[str, object] = {"fulfillment_type": "pickup", "lines": _lines(verified_business)}
    if path == "/api/v1/orders":
        headers["Idempotency-Key"] = "default-1"
        body.update(
            checkout_correlation_id="corr-default",
            server_quote_id=str(uuid.uuid4()),
            server_quote_revision=1,
        )

    response = default_client.post(path, json=body, headers=headers)

    assert response.status_code == 503
    assert response.json()["code"] == "authoritative_catalog_unavailable"


def test_default_dependency_is_unavailable_authority(monkeypatch: pytest.MonkeyPatch) -> None:
    get_settings.cache_clear()
    authority = get_consumer_catalog_authority(session=None, settings=get_settings())  # type: ignore[arg-type]
    assert isinstance(authority, UnavailableConsumerCatalogAuthority)


# --- Migration ------------------------------------------------------------------


@pytest.fixture
def alembic_engine(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Generator[tuple[Config, Engine], None, None]:
    url = f"sqlite:///{(tmp_path / 'catalog_migration.db').as_posix()}"
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("QOSHNI_DATABASE_URL", url)
    get_settings.cache_clear()
    config = Config()
    config.set_main_option("script_location", str(BACKEND_ROOT / "alembic"))
    engine = create_engine(url)
    yield config, engine
    engine.dispose()
    get_settings.cache_clear()


def test_migration_creates_catalog_and_quote_revision_column(
    alembic_engine: tuple[Config, Engine],
) -> None:
    config, engine = alembic_engine
    command.upgrade(config, "head")
    inspector = inspect(engine)
    assert CATALOG_TABLE in inspector.get_table_names()
    quote_line_columns = {column["name"] for column in inspector.get_columns("checkout_quote_lines")}
    assert "catalog_pricing_revision" in quote_line_columns
    migrated_checks = {ck["name"] for ck in inspector.get_check_constraints(CATALOG_TABLE)}
    declared_checks = {
        constraint.name
        for constraint in Base.metadata.tables[CATALOG_TABLE].constraints
        if isinstance(constraint, CheckConstraint)
    }
    assert migrated_checks == declared_checks


def test_migration_downgrade_removes_catalog(alembic_engine: tuple[Config, Engine]) -> None:
    config, engine = alembic_engine
    command.upgrade(config, "head")
    command.downgrade(config, "b0a1f0180001")
    inspector = inspect(engine)
    assert CATALOG_TABLE not in inspector.get_table_names()
    quote_line_columns = {column["name"] for column in inspector.get_columns("checkout_quote_lines")}
    assert "catalog_pricing_revision" not in quote_line_columns
    command.upgrade(config, "head")
    assert CATALOG_TABLE in inspect(engine).get_table_names()
