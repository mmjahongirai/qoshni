# Phase 18 — WP1: Cart, Checkout & Pricing Foundation

## Authoritative sources discovered

| Question | Answer in this repository |
| --- | --- |
| Product/service IDs and prices (consumer) | **Consumer demo catalog** only: `buildAllCatalogItems()` in `lib/features/home/presentation/data/business_catalog_mock_data.dart` with stable `MockBusinessId` / `MockCatalogItemId` and optional `samplePriceUzs` (integer UZS som). |
| Backend consumer catalog | **Not implemented.** Phase 16 search indexes onboarding businesses; it does not expose purchasable SKU prices. |
| Business Center catalog/pricing | **Owner-session demo plane** (`BusinessCatalogPrice`, in-memory repositories, `resolveCatalogPrice`) — isolated from consumer cart per ADR three data planes. |
| Inventory authority | Business Center in-memory inventory only; **no consumer stock API** and no reservation in WP1. |
| Stable business IDs for cart | Consumer: `MockBusinessId.routeParam`. Search/onboarding: `stable_id` strings (not wired to cart in WP1). |
| Promotions / tax / delivery fees | Business Center has illustrative promo/discount/fee demos; **not applied** to consumer checkout WP1. |
| Ownership validation for ordering | Auth exists for API users; **no line-level catalog ownership** on backend for consumer items yet. |

## Cart domain

- `lib/features/checkout/domain/` — universal cart (`QoshniUniversalCart`), line references, limits, business grouping.
- `QoshniCartService` — in-memory session cart with monotonic **revision** (not persisted, not an order).
- `CartController` — existing Home UI facade; delegates to cart + pricing services.

Rules enforced:

- Positive integer quantities (`1…99`), max distinct lines `50`.
- Add fails when demo catalog line missing or has no price.
- Stale/unpriced lines purged on resolve.
- Multi-business grouping by **stable business id** (`groupCartItemsByBusiness`).

## Checkout session

- `QoshniCheckoutSessionService` + `QoshniCheckoutController`.
- States: `draft`, `priced`, `stale`, `invalid`.
- Correlation reference per prepare call; **does not place orders**.
- Cart revision mismatch → `stale` (must recalculate before demo confirm).
- Fulfillment validation (consumer demo):
  - `delivery` rejected when cart contains **service** items.
  - `serviceAtLocation` rejected for **product-only** carts.
  - `pickup` supports mixed demo catalog kinds.

## Pricing

- `QoshniCheckoutPricingService` — deterministic **integer som** arithmetic (UZS), no floats.
- Prices read only from consumer demo catalog resolver (`resolveConsumerCatalogLine`).
- `discountSom`, `deliveryFeeSom`, `taxSom` remain **zero** (not invented).
- Client-submitted totals are ignored for authority; quoted snapshot stored on session.
- `QoshniPriceQuote` / line snapshots immutably capture titles and unit prices at quote time.
- Demo order confirmation (existing flow) may consume the **checkout quote** snapshot; that remains a **local demo record**, not backend order placement.

## Backend boundary

- `POST /api/v1/checkout/prepare` (authenticated) — typed request/validation.
- Returns **503** `authoritative_catalog_unavailable` until a real consumer catalog pricing source exists.
- **No database migration** in WP1; no cart persistence on server.

## Flutter UI

- Checkout page: fulfillment selector, preparation notice, quote total from pricing service, stale/invalid banners, multi-business notice.
- Cart page unchanged in navigation; totals use pricing service.
- Localized strings (en/ru/uz) for new checkout preparation copy.

## Explicitly not in WP1

Payment, wallet, ledger, inventory hold/reservation, idempotent place-order, production tax/promo engines, backend cart storage.

## Prerequisites for production ordering

1. Authoritative consumer catalog + price API (or projection from verified business catalog).
2. Backend pricing service replacing demo adapter.
3. Inventory validation/reservation WP.
4. Idempotent place-order and payment WP.

## Next WP

**WP2 (recommended):** inventory validation/reservation hooks + idempotent place-order lifecycle on top of checkout session and price snapshots.

## Verification notes

- Flutter: `test/checkout/*` plus full `flutter test`.
- Backend pytest: requires project Python venv (often unavailable on Windows dev machines); tests live in `backend/tests/test_checkout_preparation.py`.
