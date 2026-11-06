# Phase 18 Closure WP3 — Business catalog and inventory API

Backend only. Flutter Business Center UI is WP4. No commit, push, merge, or deploy.

## Endpoints

All owner routes require the signed-in user. A missing business and a business owned by someone else both return **404** `business_not_found`. An unverified application returns **403** `business_not_verified`. The checkout flag does not gate these routes.

| Method | Path | Effect |
| --- | --- | --- |
| POST | `/api/v1/business/onboarding/applications/{application_id}/catalog/items` | Create a product or service. Duplicate stable id is **409** `catalog_item_exists`. |
| GET | same `/items` and `/items/{catalog_item_id}` | Owner sees active, inactive, and archived rows. |
| PATCH | `.../price` | Changes `unit_price_minor`. `pricing_revision` increases only when the price changes. |
| PATCH | `.../status` | `active`, `inactive`, or `archived`. Status does not change `pricing_revision`. Archive is reversible because no existing rule makes it terminal. |
| POST | `.../inventory` | Opens the balance once with an explicit `quantity_on_hand` and a reason. A second open is **409**. |
| POST | `.../inventory/replenishments` | Adds a positive quantity to on-hand. Reserved quantity is unchanged. |
| POST | `.../inventory/counts` | Sets on-hand to a counted value. Rejected when the result would be below `reserved_quantity`. |
| GET | `.../inventory` | Returns on-hand, reserved, and available. Also sweeps due holds. |
| GET | `.../inventory/events` | Append-only audit. |
| GET, POST | `/api/v1/internal/inventory/reservation-maintenance` | Reviewer only. Health, and an explicit sweep that records a run. |
| POST | `/api/v1/business/onboarding/applications/{application_id}/orders/{order_id}/rejection` | Owner moves `pending_acceptance` to `rejected` and releases the hold. A second call does not release again. |

Checkout still prices only **active** items of a **verified** business through `SqlConsumerCatalogAuthority`. With the catalog flag off, checkout and orders stay **503**.

## Authorization

- Owner routes use `get_current_principal`. The actor id stored on an inventory event is that principal, not a client field.
- Maintenance uses the existing `require_business_onboarding_reviewer` role. There is no new shared secret.
- Owners cannot set `reserved_quantity`. Reservations stay on the order engine.

## Inventory audit

Migration `b0a1f0180004` adds `consumer_catalog_inventory_events` and `inventory_maintenance_runs`.

Each owner change stores kind (`opened`, `replenished`, `count_corrected`), signed delta, on-hand after, reserved after, reason, and `actor_user_id`. The row is written in the same transaction as the balance change.

## Reservation lifecycle (existing rules, not new ones)

The 15-minute value is `INVENTORY_RESERVATION_TTL` on `inventory_reservations.expires_at`, set when a pending order is placed. It is the hold lifetime. It is not a payment window and not an accepted-order window.

| Question | What the current code does |
| --- | --- |
| Which state owns the 15-minute hold? | `pending_acceptance`. The hold is `held` until cancel, rejection, expiry, or a future consume step. |
| Order becomes `accepted` | No code consumes or releases the hold. `accepted` has no outgoing transition. Expiry skips that order, so the hold stays reserved after 15 minutes. |
| Buyer cancels a pending order | The existing cancel path releases the held quantity and marks the reservation `released`. |
| Business rejects a pending order | `POST .../orders/{order_id}/rejection` uses the existing `pending_acceptance → rejected` transition. Held rows are claimed, stock is released, and the order is marked `rejected` in one transaction. A repeat call is a replay and does not release again. |
| Hold expires | `expire_stale_reservations` releases stock, marks the reservation `expired`, and moves that `pending_acceptance` order to `expired` with reason `reservation_expired`. |

`consumed` exists on the reservation enum. Placement does not set it. Payment and delivery are not implemented in this phase.

### Accepted orders and the later fulfillment step

Reserved quantity becomes sold quantity only when a future fulfillment step consumes the hold: decrease `quantity_on_hand` and `reserved_quantity` by the same amount and mark the reservation `consumed`. Available quantity stays the same, because those units were already unsellable. Nothing in this phase does that. `fulfillment_status` (`not_started`, `in_progress`, `fulfilled`) is stored separately and is not connected to inventory.

A pending order that is cancelled, rejected, or expired returns the hold to available quantity. An accepted order cannot use those transitions: `accepted` has an empty outgoing set. Leaving the hold reserved is the current rule, because the business already agreed to sell the units. Auto-expiring an accepted hold would sell the same units twice. Releasing it would require a new transition, which belongs with delivery failure, not with this package.

The delivery phase should connect like this:

- Fulfillment completes: consume the hold. On-hand and reserved both drop. The reservation becomes `consumed`.
- Delivery fails before fulfillment: add an explicit transition out of `accepted` and release the hold in that same transaction. That transition is not added here.
- Until that phase, accepted stock remains reserved and is not available to another buyer.

### Rejection

The unpaid outcome matches cancel. `reserved_quantity` decreases by the held quantity, `available_quantity` is `quantity_on_hand - reserved_quantity`, and on-hand itself does not change. Consuming the hold on reject was rejected as a rule: it would remove stock for a sale that did not happen. No payment system is involved.

A business that does not own the application, and an order whose lines are not that business, both receive **404** `not_found`. `accepted`, `cancelled`, and `expired` receive **409** `invalid_transition`.

## Scheduler

`expire_stale_reservations` claims each hold before releasing stock:

1. `UPDATE … SET status = expired WHERE id = ? AND status = held AND expires_at <= now` inside a savepoint.
2. Rowcount 1 is the only worker that calls the stock release.
3. A failed release rolls the savepoint back, so the hold stays `held` and the next attempt can claim it.
4. A crash before the outer commit rolls the claim and the release back together.

A second worker’s update matches zero rows and does not release. The batch limit is 50. Accepted orders are still skipped.

The API process does not start a loop. `create_app` only disposes the engine on shutdown. Request traffic still sweeps on order placement, cancel, and an owner inventory read, so holds move even when the worker is off.

The periodic process is `python -m app.services.checkout.reservation_maintenance_worker`. It sweeps only when `QOSHNI_RESERVATION_MAINTENANCE_ENABLED=true`. The default is false, including production. A disabled process exits without expiring anything. Interval and worker id are `QOSHNI_RESERVATION_MAINTENANCE_INTERVAL_SECONDS` (default 60) and `QOSHNI_RESERVATION_MAINTENANCE_WORKER_ID`.

Each iteration commits a row in `inventory_maintenance_runs`. On failure the sweep rolls back, a `failed` row is committed in a new transaction, and the next iteration can claim the same holds. Reviewer `GET /api/v1/internal/inventory/reservation-maintenance` returns overdue held count, the oldest overdue `expires_at`, and the last run.

## PostgreSQL

This machine has no PostgreSQL client, service, or install directory. `tests/test_consumer_inventory_postgres.py` is skipped unless `QOSHNI_TEST_POSTGRES_URL` names a disposable database whose URL contains `test`. It covers row-lock reservation of the last unit and idempotent replay. It was not executed. Do not point it at production and do not apply these migrations to a shared database.

Safe local option: install PostgreSQL, create a database whose name contains `test`, export only that URL, then run the file. SQLite remains the executed proof for the conditional update and the claim.

## Flutter Business Center — WP4 contract

No Dart files change in this stabilization pass.

What exists:

- Route `businessCenter` builds `BusinessCenterPage` (`lib/routing/app_router.dart`).
- Offerings, products, and inventory are `ChangeNotifier` controllers over in-memory repositories (`BusinessOfferingsController`, `BusinessCatalogProductController`, `BusinessCatalogInventoryController`).
- Inventory pages and `BusinessCatalogInventoryRepository` already show on-hand style adjustments. `reservedDelta` on the demo adjustment is a client concept. WP4 must not send it. Reserved quantity is read-only and comes from orders.
- `ApiClient` (`lib/core/network/api_client.dart`) sets JSON headers and maps transport failures to `NetworkException` or `ServerException`. It does not attach a bearer token. Onboarding already passes `Authorization: Bearer <accessToken>` per call from `AuthController`. Business Center has no repository that does this.
- Screen scope is a local `businessProfileId` (`business_profile_offering.dart`, inventory pages). The API path key is `OwnerApplicationViewDto.applicationId` from `GET /api/v1/business/onboarding/applications`. Public catalog id remains `business:onboarding:{applicationId}`.

### Identity

WP4 selects one verified application (`verificationStatus == verified`) owned by the signed-in user. Catalog calls use that `applicationId`. They do not send `businessProfileId`. A local demo profile has no backend application until onboarding returns one.

### Auth and errors

Every catalog, inventory, and rejection call sends `Authorization: Bearer <AuthController access token>`. Missing or invalid sessions return **401** with `{ "error": { "code", "message" } }`. Owner failures use `{ "detail": { "code", "message" } }` for catalog routes and `{ "code", "message" }` for order rejection.

| HTTP | `code` | Meaning for the UI |
| --- | --- | --- |
| 401 | `authentication_required` | Send the user through the existing sign-in flow. |
| 403 | `business_not_verified` | Show the application as not ready to sell. |
| 404 | `business_not_found`, `catalog_item_not_found`, `not_found` | Hide the record. Do not distinguish “exists but not yours”. |
| 409 | `catalog_item_exists`, `inventory_already_open`, `inventory_not_open`, `below_reserved`, `invalid_transition`, `release_failed` | Keep the current screen and show the message. `release_failed` can be retried. |
| 422 | `validation_failed` | Show the field message. |
| 503 | `authoritative_catalog_unavailable` | Checkout only. Owner catalog management still works while this flag is off. |

### Requests the controllers should grow into

Create `POST .../catalog/items`:

```json
{"catalog_item_stable_id":"bread","offering_kind":"product","title":"Bread","unit_price_minor":8000}
```

`offering_kind` is `product` or `service`. Price is an integer count of UZS. The response includes `catalog_item_id`, `pricing_revision` (starts at 1), and `status` (`active`).

Price `PATCH .../price` body is `{ "unit_price_minor": 9000 }`. The same price keeps `pricing_revision`.

Status `PATCH .../status` body is `{ "status": "active" | "inactive" | "archived" }`. Archive can be reopened. Status does not change `pricing_revision`.

Open inventory once: `POST .../inventory` with `{ "quantity_on_hand": 4, "reason": "opening count" }`. Response: `quantity_on_hand`, `reserved_quantity`, `available_quantity`, `updated_at`.

Replenish: `POST .../inventory/replenishments` with `{ "quantity": 3, "reason": "morning delivery" }`. This adds to on-hand and does not change reserved.

Counted correction: `POST .../inventory/counts` with `{ "quantity_on_hand": 6, "reason": "shelf count" }`. The server rejects a count below reserved.

Events `GET .../inventory/events` returns `events[]` with `actor_user_id`, `kind` (`opened`, `replenished`, `count_corrected`), `quantity_delta`, both after-quantities, `reason`, and `created_at`.

Rejection, when the center later shows incoming orders: `POST .../orders/{order_id}/rejection` with `{ "reason": "out of stock" }`. Success body is the order snapshot. `idempotent_replay: true` means the hold was already released.

`ChangeNotifier` controllers stay. WP4 adds a remote repository beside the in-memory one and keeps demo seeds off the authoritative path. The controllers display server `pricing_revision`, `available_quantity`, and the event list. They do not keep a second reservation state machine.

## Verification

See the WP3 report for the commands actually run. PostgreSQL tests are skipped on this machine. Migrations are not applied to any shared database.
