# Phase 18 — WP2: Inventory Reservation & Idempotent Order Placement

## Prerequisite verification (unchanged through WP3)

| Dependency | Status |
| --- | --- |
| Backend consumer SKU/catalog | **Still absent** in production |
| Authoritative server-side consumer pricing | **Still absent** (`POST /checkout/prepare` and `POST /checkout/quotes` → **503**) |
| Authoritative consumer inventory | **Still absent** (Business Center inventory is owner-demo plane only) |
| Operational purchase flow | **Not available** until catalog + applied migrations |

Production **`POST /api/v1/orders` fails closed** with `503 authoritative_catalog_unavailable` via `UnavailableConsumerCatalogAuthority` in `get_consumer_catalog_authority()`.

`FakeConsumerCatalogAuthority` is wired **only** through explicit FastAPI test overrides — never in production DI.

## Implemented in WP2 (service contracts)

### Backend

- **`ConsumerCatalogAuthority` port** + production `UnavailableConsumerCatalogAuthority`.
- **`place_order` service** — idempotency (buyer + operation + key), line validation, multi-business rejection, integer minor-unit totals from catalog port (never client totals), inventory reservation hook.
- **Order lifecycle fields** — separate order, `payment_status` (defaults `unpaid`), and `fulfillment_status` (`not_started`).
- **Immutable line snapshots** on order records.
- **`POST /api/v1/orders`** — requires `Idempotency-Key` header + authenticated principal.
- **In-memory placement store** (`InMemoryOrderPlacementStore`) and **in-memory inventory ledger** used in **service-layer unit tests** before WP3 SQL wiring.

### Flutter

- **`QoshniOrderPlacementService`** — calls remote `/api/v1/orders` when API configured; **never** falls back to demo order on failure.
- Checkout UI — server placement section + explicit demo separation notice.

## WP3 extensions (same Phase 18 branch — see `order_checkout_wp3.md`)

WP3 added durable persistence **without** enabling production ordering:

| WP2 (initial) | WP3 (durable) |
| --- | --- |
| In-memory idempotency in service tests | SQL `order_idempotency_records` + unique `(buyer, operation, key)` |
| No order tables | Migration **`b0a1f0180001`**: `consumer_orders`, items, status events, `checkout_quotes`, `inventory_reservations` |
| No server quotes | `POST /api/v1/checkout/quotes` + `validate_quote_for_placement` |
| API in-memory store (WP2 report) | **`SqlAlchemyOrderPlacementStore`** on HTTP routes; commit on first success |

**Production default is unchanged:** catalog unavailable → **503** before any SQL order row or reservation.

### Reservations — honest limits

- Stock checks on the placement path still use a **process-local in-memory ledger** (`InventoryReservationService`) when catalog is operational (tests/future).
- SQL `inventory_reservations` rows are written with the order in the same DB session — they **do not** represent atomic multi-worker stock control until a real inventory authority exists.
- No operational scheduler or message broker; `expire_stale_reservations()` is a callable hook only.

### Migrations

- **`b0a1f0180001`** is committed as source (revises `b0a1f0170001`).
- Phase 16–18 migrations remain **unapplied** in operations on typical dev hosts unless explicitly run.

## Idempotency

- Scope: `(buyer_user_id, operation=place_order, idempotency_key)`.
- Same key + same request fingerprint → replay existing order (`idempotent_replay: true`).
- Same key + different fingerprint → `409 idempotency_conflict`.
- Fingerprint ignores client-submitted totals.
- Durable uniqueness when SQL path commits; concurrent insert-or-replay hardening is a **pre-production** follow-up (see WP3 activation blockers).

## Multi-business

- **Rejected** at placement (`unsupported_multi_business`) until parent/child order model is defined.

## Demo vs production

| Path | Behavior |
| --- | --- |
| Demo checkout quote (Flutter) | Local mock catalog calculator (`isDemoPricing: true`) |
| Demo order confirm | Local `DemoOrderController` only |
| Server quote + place-order | Issue quote then place — **503** on quote issue today; demo quote IDs are **not** sent as server credentials |

## Verification

- Flutter: `test/checkout/` including server quote contract mapping tests; full suite in checkpoint report.
- Backend pytest: requires a usable Python interpreter / project venv — **not verified** on all Windows dev hosts (see WP3 doc).

## Related documentation

- **`docs/order_checkout_wp1.md`** — cart, demo pricing, prepare API.
- **`docs/order_checkout_wp3.md`** — durable schema, quote TTL, cancellation, activation blockers.
