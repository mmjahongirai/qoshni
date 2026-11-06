# Phase 18 — WP3: Durable Order Lifecycle, Quote Integrity & Recovery

## Authoritative prerequisites (updated by Phase 18 Closure WP1)

| Dependency | Status |
| --- | --- |
| Backend consumer catalog | **Implemented, off by default** — `SqlConsumerCatalogAuthority` over `consumer_catalog_items`, enabled only by `QOSHNI_CONSUMER_CATALOG_ENABLED=true` |
| Authoritative server pricing | **Implemented when enabled**; default remains `UnavailableConsumerCatalogAuthority` |
| Authoritative consumer inventory | **Implemented when a balance row exists** (`consumer_catalog_inventory`, migration `b0a1f0180003`). A missing row still returns **503** `authoritative_inventory_unavailable` |
| Owner catalog management API | **Not in WP2** — service-layer only; HTTP API and Flutter Business Center are the next package |
| Flutter demo quotes | **Not authoritative** |

**Production default (flag unset):** `POST /api/v1/checkout/prepare`, `POST /api/v1/checkout/quotes` and `POST /api/v1/orders` return **503** `authoritative_catalog_unavailable`, before any quote or order row is created.

**Catalog enabled:** prepare and quotes are priced from SQL. Orders reserve `consumer_catalog_inventory` when a balance row exists; without one they still return **503** `authoritative_inventory_unavailable`.

Test-only `FakeConsumerCatalogAuthority` is injected via FastAPI overrides in pytest — **never** wired in `get_consumer_catalog_authority()`.

## Durable schema (migration added, not applied)

**Revision:** `b0a1f0180001` (parent `b0a1f0170001`)

| Table | Purpose |
| --- | --- |
| `checkout_quotes` + `checkout_quote_lines` | Server-issued quotes when catalog is operational; bound to buyer + fingerprint + expiry |
| `consumer_orders` + `consumer_order_items` | Authoritative purchase record with **immutable line snapshots** (stable catalog refs, no product FK) |
| `consumer_order_status_events` | Audited status transitions |
| `order_idempotency_records` | Unique `(buyer_user_id, operation, idempotency_key)` + fingerprint + `order_id` |
| `inventory_reservations` | Held/released/expired reservations tied to `order_id` |

Order and quote lines store `business_stable_id` + `catalog_item_stable_id` strings plus snapshots — no FK to `consumer_catalog_items`, so order history survives catalog edits.

Earlier migrations (`b0a1f015`–`b0a1f017`) through `b0a1f0180003` remain **unapplied** operationally.

## Server quotes

- Issued only via `issue_checkout_quote()` when `catalog.is_operational()` is true.
- 15-minute TTL (`CHECKOUT_QUOTE_TTL`).
- Placement requires matching buyer, revision, fingerprint, fulfillment, and non-expired quote (`validate_quote_for_placement`).
- **No quote rows** are written when catalog is unavailable.
- Each quote line stores `catalog_pricing_revision`; the quote's `pricing_revision` is the highest line revision.
- At placement every quoted line is re-resolved from the catalog. A changed price, changed revision, archived/inactive item or no-longer-verified business returns **400** `stale_quote` — the client must request a new quote.

## Idempotency & recovery

- Scope: authenticated **buyer** + operation `place_order` + `Idempotency-Key` header.
- Same fingerprint → replay same order (HTTP 200, `idempotent_replay: true`).
- Different fingerprint → **409** `idempotency_conflict`.
- Durable uniqueness: DB constraint `uq_order_idempotency_buyer_operation_key`.
- API uses `SqlAlchemyOrderPlacementStore` + commit on first success; replay does not re-commit side effects.
- A concurrent insert that hits `uq_order_idempotency_buyer_operation_key` rolls the loser back (including its stock hold) and returns the committed order.
- Timeout recovery: client retries with the **same** key to load the committed order/idempotency row.

## Reservations

- SQL catalog orders hold stock in `consumer_catalog_inventory` (`quantity_on_hand`, `reserved_quantity`) inside the order transaction. PostgreSQL locks the balance with `SELECT … FOR UPDATE`; other dialects use one conditional `UPDATE`. The in-memory ledger remains only for test catalog overrides.
- **Durable `inventory_reservations` rows** are written with a required `expires_at` (15 minutes).
- States: `held`, `consumed`, `released`, `expired` (`InventoryReservationStatus`).
- `available = quantity_on_hand - reserved_quantity`, enforced by `reserved_quantity <= quantity_on_hand`.
- `SqlOrderLifecycleService.cancel_order` returns held units and marks reservations `released`; idempotent if already cancelled.
- `expire_stale_reservations()` returns held units for rows whose `expires_at` has passed. No scheduler ships in the repo — call it from ops.

## Order lifecycle

- Separate **order**, **payment**, and **fulfillment** status fields.
- Validated transitions via `order_transitions.can_transition` (`pending_acceptance` → `cancelled`, etc.).
- `POST /api/v1/orders/{order_id}/cancel` — buyer-scoped; does not imply refund/payment change.

## Multi-business

- Still **rejected** (`unsupported_multi_business`) — no parent/child orders.

## Flutter

- Demo checkout/order flows unchanged; server placement remains optional and **does not** fall back to demo on failure.
- No claim of server-confirmed purchase without API success.
- **`QoshniCheckoutQuoteService`** issues a server quote via `POST /api/v1/checkout/quotes` before placement.
- Placement sends `server_quote_id` + `server_quote_revision` from the **server response** (`quote_id`, `pricing_revision`) — never the demo `QoshniPriceQuote.quoteId` or cart revision.
- `cart_revision` may be sent on quote issue for correlation only; it is not a substitute for `pricing_revision` on place-order.

## Mandatory activation blockers (before production ordering)

These must remain true until explicitly resolved — not hidden by schema or UI alone:

1. ~~No authoritative consumer catalog or pricing~~ — **resolved by Closure WP1** behind `QOSHNI_CONSUMER_CATALOG_ENABLED` (default off). **No authoritative stock source** remains.
2. ~~In-memory stock on the SQL catalog path~~ — **replaced in Closure WP2** by `consumer_catalog_inventory` in the order transaction. The in-memory ledger is test-only. No scheduler process ships; ops must call `expire_stale_reservations()`.
3. ~~Concurrent SQL idempotency~~ — a unique-constraint conflict now rolls back and replays the committed order. Two requests that both pass the first read can still both reserve until one commits; the loser is rolled back.
4. ~~`expires_at` unset~~ — new reservation rows set a 15-minute `expires_at`. Expiry still needs an external caller.
5. **Real backend order placement** remains unavailable until the catalog flag is on, each item has an explicit inventory balance, **and** migrations through `b0a1f0180003` are applied on the target database.
6. Backend pytest was not executed for WP3 itself; Closure WP1 ran the full backend suite locally (see below).

## Verification (WP3, historical)

| Check | Result |
| --- | --- |
| `flutter test` | **638 passed** |
| `test/checkout/` | **15 passed** |
| `flutter analyze` | **0 errors**, 11 warnings, 165 infos (176 total) |
| `git diff --check` | clean |
| Backend `pytest` | **Not run** — no usable Python interpreter (`python`/`py` unavailable; no `backend/.venv`) |
| DB migrations applied | **No** (including `b0a1f0180001`) |
| Web release build | **OK** → `C:\Users\Admin\Desktop\QOSHNI_web_phase18_wp3_temp` (outside repo) |

Backend tests to run when Python is available: `test_checkout_preparation.py`, `test_checkout_quote_wp3.py`, `test_order_placement_api.py`, `test_order_placement_service.py`, `test_inventory_reservation.py`.

## Production blockers (summary)

See **Mandatory activation blockers** above. High-level delivery order:

1. ~~Implement real `ConsumerCatalogAuthority`~~ — done in Closure WP1 (`SqlConsumerCatalogAuthority`).
2. Apply migrations through `b0a1f0180003` on PostgreSQL.
3. ~~Replace in-memory inventory~~ — done in Closure WP2 for the SQL catalog path.
4. Call `expire_stale_reservations()` from an external scheduler. Idempotency conflicts replay the committed order.

## Phase 18 Closure — WP1: Authoritative Consumer Catalog

Branch: `feature/phase18-catalog-inventory` (from `d897aeb`). Migration **`b0a1f0180002`** (parent `b0a1f0180001`).

### Source of truth

There is no backend Business Offerings table — Business Center offerings are an in-memory Flutter demo. The only verified business record on the backend is `business_onboarding_applications`, so catalog rows hang off it:

| Requirement | Column / mechanism |
| --- | --- |
| business_id | `business_application_id` → FK `business_onboarding_applications.id` (`ON DELETE CASCADE`); public form `business:onboarding:{uuid}` (same as search) |
| offering_id | `id` (UUID primary key) |
| product/service identifier | `catalog_item_stable_id` (unique per business) + `offering_kind` (`product` / `service`) |
| integer UZS price | `unit_price_minor` (`0 … 1 000 000 000`), `currency_code` fixed to `UZS` by CHECK |
| pricing_revision | starts at 1, incremented by `upsert_catalog_offering` on every price change |
| availability/status | `status`: `active` / `inactive` / `archived` — only `active` is priceable |
| timestamps | `created_at`, `updated_at` |

`checkout_quote_lines.catalog_pricing_revision` (nullable) records the revision each line was quoted at.

### Behaviour

- `SqlConsumerCatalogAuthority` resolves a line only when the item is `active` **and** its business is currently `verified`. An item ID requested under a different business never resolves.
- `upsert_catalog_offering` (service layer) requires the caller to own the business; non-owners get `business_not_found`. Unverified businesses get `business_not_verified`.
- `get_consumer_catalog_authority()` returns the SQL authority only when `QOSHNI_CONSUMER_CATALOG_ENABLED=true`; otherwise `UnavailableConsumerCatalogAuthority` (503).
- `POST /checkout/prepare` returns a server-priced `CheckoutPrepareSuccessResponse` (`is_demo_pricing: false`) when enabled.
- Cart lines reject unknown fields (`extra="forbid"`): a client-sent `unit_price_minor` is **422**. `client_submitted_total_minor` is accepted but never used.
- With no `consumer_catalog_inventory` row, `available_quantity` stays `None` and `place_order` returns **503** `authoritative_inventory_unavailable` before any reservation or order row. A balance row returns `quantity_on_hand - reserved_quantity`.

### Verification (Closure WP1)

| Check | Result |
| --- | --- |
| Backend `pytest` (full suite, Python 3.12.13 temp venv outside repo) | **411 passed, 6 skipped** (5 Windows symlink, 1 pagination fixture) |
| `tests/test_consumer_catalog_wp1.py` | **40 passed** |
| `flutter test` | **647 passed** |
| `flutter analyze` | **0 errors**, 179 issues (unchanged baseline) |
| `git diff --check` | clean |
| DB migrations applied | **No** |

## Phase 18 Closure — WP2: Database-backed Inventory

Migration **`b0a1f0180003`** (parent `b0a1f0180002`). No owner HTTP API and no Flutter Business Center work in this package.

### Balance

`consumer_catalog_inventory` is one row per catalog item (`catalog_item_id` primary key, `ON DELETE CASCADE`). It stores `quantity_on_hand` and `reserved_quantity` with **no server default** — a missing row is not zero and not unlimited. Opening a balance passes the counted on-hand quantity explicitly and sets reserved to 0 because nothing is held yet.

`available_quantity = quantity_on_hand - reserved_quantity`. A check constraint keeps reserved within on-hand, so available cannot be negative.

The row follows the catalog item. Today the item points at a verified onboarding application. A future canonical Business Profile can replace that parent reference without rewriting inventory rows. This package does not build that profile.

### Holds

`POST /orders` uses `SqlCatalogInventoryService` only when the catalog authority is the SQL one. Test overrides still use the in-memory ledger.

- PostgreSQL: `SELECT … FOR UPDATE` on the balance, then increment reserved.
- SQLite (tests) and other dialects: one conditional `UPDATE … WHERE on_hand - reserved >= quantity`.
- The reservation row is written in the same transaction with `expires_at` set 15 minutes ahead.
- Cancel and `expire_stale_reservations()` move the units back and set `released` or `expired`. Expiry also moves a still-`pending_acceptance` order to `expired`, so the order does not keep a claim on stock that was returned. Holds on any other order status are left alone.
- Any error before commit rolls the hold back with the order.
- A missing balance still returns **503** `authoritative_inventory_unavailable` and writes nothing. Catalog disabled still returns **503** `authoritative_catalog_unavailable`.

Closure WP3 adds a claim-safe sweep on order placement, cancel, and owner inventory reads, plus `POST/GET /api/v1/internal/inventory/reservation-maintenance`. See `docs/business_catalog_inventory_wp3.md`.

### Idempotency

If two placements commit the same buyer/operation/key, the loser hits `uq_order_idempotency_buyer_operation_key`, the request rolls back (stock included), and the response is the committed order. A different body is still **409**.

### Not in this package

Owner catalog/inventory HTTP API and Flutter Business Center stay service-layer only. That is the next package, before payment capture.

### Verification (Closure WP2)

Recorded after the commands below. PostgreSQL was **not** available, so `SELECT … FOR UPDATE` was not executed; SQLite covered the conditional update, including parallel placements.

| Check | Result |
| --- | --- |
| Backend `pytest` (full suite, before the final “expire the pending order too” change) | **425 passed, 6 skipped** (5 Windows symlink, 1 pagination fixture) |
| `tests/test_consumer_inventory_wp2.py` after that change | **14 passed** |
| WP1 + checkout regression subset, earlier in this WP | **59 passed** |
| `flutter test` | **647 passed** |
| `flutter analyze` | **0 errors**, 179 issues (unchanged baseline) |
| PostgreSQL / `SELECT … FOR UPDATE` | **Not run** — no PostgreSQL on this machine; SQLite conditional `UPDATE` covered the parallel cases |
| DB migrations applied | **No** |

## Next package

Owner catalog and inventory HTTP is Closure WP3 (`docs/business_catalog_inventory_wp3.md`). Flutter Business Center UI is WP4. Payment capture stays later. Migrations through `b0a1f0180004` are still not applied to any shared database.
