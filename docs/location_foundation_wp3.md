# Phase 17 — WP3: Trusted Branch Coordinates & Map/Search Parity

## Authoritative ownership decision

| Question | Answer in this codebase |
| --- | --- |
| Who owns a public business location? | **`business_onboarding_applications`** is the authoritative record projected into Phase 16 search (`stable_id = business:onboarding:{id}`). Flutter **Business Center branches** are in-memory demo only — not the production catalog. |
| Where are trusted coordinates stored? | New table **`business_onboarding_branch_coordinates`** (1:1 with application_id). |
| Who proposes? | Authenticated **application owner** via `PUT /api/v1/business/onboarding/applications/{id}/branch-coordinates`. |
| Who verifies? | **`business_onboarding_reviewer`** platform role via internal `POST .../branch-coordinates/verify` or `reject`. |
| When are coordinates public? | Only when `verification_status=verified`, `verified_revision == revision`, and onboarding application is **verified** and index row **eligible**. |

No duplicate business catalog was introduced.

## Provenance and states

- **Sources:** `manual_map_pin`, `owner_confirmed_pin` (enum `BranchCoordinateSource`).
- **Verification:** `proposed` → reviewer `verified` | `rejected` | (future `revoked`).
- **Revision:** monotonic `revision`; optional `expected_revision` on propose prevents stale overwrites (409).
- Unverified geocoding suggestions and saved user places **never** write branch coordinates.

## Search projection

`sync_branch_coordinates_to_search_index()` updates:

- `search_index_records.branch_latitude/longitude`
- `branch_coordinate_revision`

Called after propose/verify/reject and after `project_application()`.

Only **verified** coordinates are non-NULL in the index. Rejection clears projected coordinates.

## Nearby search

- Unchanged endpoint: `POST /api/v1/search/discovery`.
- Haversine filter (WP2) uses **projected** index coordinates only.
- Response items optionally include `branch_latitude` / `branch_longitude` when present on the index row (for map/list parity).
- **PostGIS:** not configured; Haversine remains documented interim behavior.

## Map / list parity (Flutter)

- Search results expose `verifiedBranchLocation` when the API returns branch coordinates.
- **Show on map** sets `QoshniSearchMapFocusController` and opens the existing map route — same stable result identity as the list, no invented markers.
- Map label: localized “Verified branch … — not your GPS”.
- Business branch editor (demo) shows **proposed-only** notice when lat/lng fields are filled.

## Migrations (not applied in WP3 work)

1. `b0a1f0150001` — search index (Phase 16, still unapplied in ops)
2. `b0a1f0160001` — saved places + branch lat/lng columns
3. `b0a1f0170001` — branch coordinate table + `branch_coordinate_revision`

## Tests

| Suite | Notes |
| --- | --- |
| `backend/tests/test_branch_coordinates.py` | Propose vs verify projection |
| Flutter `test/search/search_verified_branch_location_test.dart` | DTO parsing |
| Full Flutter suite | Run in verification |
| Backend pytest | **Blocked** if no usable Python env (unchanged) |

## Live data status

Until owners propose and reviewers verify coordinates for verified onboarding applications, **nearby search will return few or no distance-qualified businesses** — honest empty/narrow results, not fabricated locations.

## Deferred

Geofencing, service polygons, clustering, routing/ETA, courier tracking, PostGIS production rollout, full Flutter↔backend sync for demo Business Center branches.
