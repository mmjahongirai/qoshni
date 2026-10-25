# Phase 16 WP3 — Backend search API & index integration

## Architecture discovered

| Area | Repository reality |
|------|---------------------|
| Backend | FastAPI app with `/api/v1` router, SQLAlchemy sessions, Alembic migrations |
| Authoritative business data | `business_onboarding_applications` (verification lifecycle) — **not** a separate public listings catalog |
| AuthN | Bearer access tokens via `get_current_principal` |
| AuthZ | Route-level authentication required for search; no anonymous search bypass |
| Events / broker | **No** message broker; append-only onboarding audit events in PostgreSQL only |
| Flutter catalog | Localized demo catalog remains client-side for UI richness |

WP3 adds a **derived search read model** fed from verified/suspended onboarding applications plus static category rows. It does **not** create a second source of truth.

## Implementation decision

- **Implemented:** `POST /api/v1/search/discovery` (authenticated), PostgreSQL/SQLite read model, in-process projection hook on reviewer status transitions, HMAC-signed cursors using existing `QOSHNI_AUTH_SECRET_DIGEST_KEY`.
- **Not implemented:** Message broker consumers, PostGIS/location search, open-now filters, sponsored billing, Trust Score/ratings/coordinates on backend rows (never invented).
- **Flutter:** Demo execution remains default. Remote adapter activates only with `--dart-define=ENABLE_REMOTE_SEARCH_DISCOVERY=true` **and** `QOSHNI_API_BASE_URL` — **no silent fallback** to demo when remote is enabled.

## Endpoint contract

Path: `POST /api/v1/search/discovery`

Request JSON aligns with `QoshniSearchBackendSearchRequestDto` (snake_case on wire):

- `query`, `page_size`, `cursor`, `category_scope`, `only_open`, `max_distance_meters`, optional lat/lng (rejected until Phase 17).

Response aligns with `QoshniSearchBackendSearchResponseDto`:

- `items[]`: `stable_id`, `kind`, `title`, `is_sponsored` (always `false` until real sponsorship exists)
- `next_cursor`, `query_fingerprint`, `catalog_generation`

Errors: `{ "error": { "code", "message" } }` with HTTP 400 for validation/cursor issues, 401 when unauthenticated.

## Read model

Tables (migration `b0a1f0150001`):

- `search_index_records` — denormalized eligible rows
- `search_index_metadata` — `catalog_generation` counter
- `search_index_projection_receipts` — idempotent consumer receipts (`event_id` PK)

Stable IDs:

- Business: `business:onboarding:{application_uuid}`
- Category seed: `category:{service_category}`

Projection:

- `sync_search_index_for_application` runs after reviewer status transitions (same DB transaction).
- `consume_search_index_projection_event` provides idempotent processing for tests/future async wiring.

Rebuild strategy: call `rebuild_from_verified_applications(session)` in ops tooling (not auto-run on every request).

## Cursor integrity

| Surface | Model |
|---------|--------|
| Flutter demo (WP2) | Base64url JSON keyset — **encoding only**, documented as non-production |
| Backend API | HMAC-SHA256 over canonical JSON payload (`search_cursor_v1` domain) using auth digest key |

Client-supplied scores inside cursors are **never** trusted for authorization or eligibility; server re-ranks from DB state on every request.

## Authorization

Search requires a valid bearer token. Missing/invalid tokens return 401 via existing auth exception handlers. Flutter remote mode returns `remoteUnauthorized` when remote is enabled but no session token is present.

## Tests

- Backend: `backend/tests/test_search_discovery.py` (auth, ranking eligibility, signed cursor tampering, idempotent consumer).
- Flutter: existing WP1/WP2 tests + `test/search/qoshni_search_remote_adapter_test.dart`.

Run backend tests from `backend/` with project venv Python:

```powershell
python -m pytest tests/test_search_discovery.py -q
```

## Runnable vs proposed

| Component | Status |
|-----------|--------|
| FastAPI search route | Runnable in dev/test with DB + digest key |
| PostgreSQL migration | Present; apply via Alembic |
| Event broker consumer | **Proposed seam only** (in-process sync + receipt table) |
| Flutter remote search | Runnable when defines + signed-in session |
| Demo search UI | Default (`ENABLE_REMOTE_SEARCH_DISCOVERY` off) |

## Limitations & follow-up

- Index content depends on onboarding verification data, not Flutter mock businesses.
- No full Phase 16 completion audit in this WP.
- Future: async projection worker, public `BusinessProfile` domain linkage, location filters, sponsorship integration, reconciliation job scheduling.
