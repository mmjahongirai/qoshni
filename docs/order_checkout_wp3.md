# Phase 18 — WP3: Durable Order Lifecycle, Quote Integrity & Recovery

## Authoritative prerequisites (verified — unchanged)

| Dependency | Status |
| --- | --- |
| Backend consumer catalog / SKU API | **Not available** |
| Authoritative server pricing | **Not available** (default `UnavailableConsumerCatalogAuthority`) |
| Authoritative consumer inventory | **Not available** |
| Flutter demo quotes | **Not authoritative** |

**Production default:** `POST /api/v1/checkout/quotes` and `POST /api/v1/checkout/prepare` return **503** `authoritative_catalog_unavailable`.

**Production default:** `POST /api/v1/orders` returns **503** before any order row is created.

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

**No product catalog table** — lines store `business_stable_id` + `catalog_item_stable_id` strings plus snapshots.

Earlier migrations (`b0a1f015`–`b0a1f017`) remain **unapplied** operationally.

## Server quotes

- Issued only via `issue_checkout_quote()` when `catalog.is_operational()` is true.
- 15-minute TTL (`CHECKOUT_QUOTE_TTL`).
- Placement requires matching buyer, revision, fingerprint, fulfillment, and non-expired quote (`validate_quote_for_placement`).
- **No quote rows** are written when catalog is unavailable.

## Idempotency & recovery

- Scope: authenticated **buyer** + operation `place_order` + `Idempotency-Key` header.
- Same fingerprint → replay same order (HTTP 200, `idempotent_replay: true`).
- Different fingerprint → **409** `idempotency_conflict`.
- Durable uniqueness: DB constraint `uq_order_idempotency_buyer_operation_key`.
- API uses `SqlAlchemyOrderPlacementStore` + commit on first success; replay does not re-commit side effects.
- Timeout recovery: client retries with the **same** key to load the committed order/idempotency row.

## Reservations

- Production API still uses in-memory ledger for stock checks until an authoritative inventory service exists; **durable `inventory_reservations` rows** are written when SQL order persistence runs (test/future path).
- States: `held`, `consumed`, `released`, `expired` (`InventoryReservationStatus`).
- `SqlOrderLifecycleService.cancel_order` releases held reservations; idempotent if already cancelled.
- `expire_stale_reservations()` — callable maintenance hook (no scheduler in repo).

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

1. **No authoritative consumer catalog, pricing, or stock source** on the backend production DI path.
2. **In-memory stock reservation** (`InventoryReservationService`) is not safe for multi-worker production and is **not rolled back** if SQL persistence fails after an in-memory hold.
3. **Concurrent SQL idempotency** needs robust insert-or-replay / conflict handling before catalog is enabled (unique constraint exists; route-level race handling is incomplete).
4. **`inventory_reservations.expires_at`** is not populated on the successful persistence path — `expire_stale_reservations()` is not an operational expiry worker (no scheduler in repo).
5. **Real backend order placement** remains unavailable until authoritative dependencies are live **and** migrations through `b0a1f0180001` are applied on the target database.
6. Backend pytest on this branch was **not executed** on hosts without Python/venv — treat API/service tests as unverified until run.

## Verification (this workspace)

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

1. Implement real `ConsumerCatalogAuthority` (consumer catalog service).
2. Apply migrations through `b0a1f0180001` on PostgreSQL.
3. Replace in-memory inventory with an authoritative inventory port + transaction-safe holds.
4. Harden idempotency under concurrency; populate reservation expiry or add scheduler.

## Next Phase 18 step

Payment capture integration, refund/cancellation financial lifecycle, and operational reconciliation tooling — only after catalog + inventory are live.
