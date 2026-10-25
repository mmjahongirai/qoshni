# Phase 17 — WP2: Saved Places, Opt-in Geocoding & Nearby Search

## Data ownership (as implemented)

| Data | Owner / source of truth |
| --- | --- |
| **User saved places** | New `user_saved_places` table, scoped by authenticated `users.id` (backend derives owner; client cannot set arbitrary owner). |
| **User profile** | Existing `user_profiles` — display identity only; **no** address fields. |
| **Business / branch coordinates** | **Not** on onboarding applications today. Search index rows have optional `branch_latitude` / `branch_longitude` for **trusted** coordinates only; projector leaves them `NULL`. No silent geocoding of postal addresses. |
| **Transient device location** | WP1 in-memory session only — never auto-persisted. |

## Saved-place API

- `GET/POST /api/v1/saved-places`
- `PATCH/DELETE /api/v1/saved-places/{id}`
- Auth: `get_current_principal` (same as Phase 16 search).
- Validation: lat/lng bounds, label/address length caps (`domain/saved_places.py`).
- Cross-user access returns **404** (no leakage).

**Migration:** `b0a1f0160001_location_wp2_saved_places_and_branch_coords.py` (not applied in this work package).

**Operational status:** Code + SQLite tests are implemented; production PostgreSQL requires applying the migration.

## Geocoding

- Flutter `QoshniGeocodingProvider` → `MapboxQoshniGeocodingProvider` using existing public `MAPBOX_ACCESS_TOKEN` (same model as map).
- Triggered only from **Search address** on the map sheet (`showQoshniGeocodeSaveSheet`).
- Suggestions are **not** saved until the user confirms label in a dialog.
- No automatic geocoding of GPS fixes; no background enrichment.
- If token missing → clear message; manual map use remains.

## Nearby search (Phase 16 extension)

**Request** (unchanged path `POST /api/v1/search/discovery`):

- Optional `search_latitude`, `search_longitude`, `max_distance_meters` (meters).
- Bounds: radius **100–50 000 m**; lat/lng must be provided together; distance requires coordinates.
- Cursor fingerprint includes location + radius (incompatible cursors rejected).

**Spatial filtering:**

- **PostGIS: not used** (not in `requirements.txt`; not verified in this environment).
- Backend applies **haversine** filtering in Python (`spatial.py`) **before** `rank_records`.
- Index rows **without** valid branch coordinates are excluded from location-filtered results (not treated as nearby).
- Eligibility rules unchanged (`eligible` only; suspended/deleted excluded).

**Branch coordinate trust:** Only explicit nullable columns on `search_index_records`; onboarding projection does **not** populate them. Nearby business results require a future trusted coordinate source (WP3+).

## Flutter integration

- Map: existing My location; **Search address** toolbar; saved-place count (loads via `QoshniSavedPlacesController`).
- Search: **Nearby search** bar — explicit enable, saved-place picker, radius slider, optional device fix from map session.
- Remote search sends lat/lng; **no silent fallback** from remote to demo when remote is enabled.
- In-memory saved places when API/auth unavailable (session-scoped demo).

## Privacy

- GPS never creates saved places automatically.
- Geocoding queries not logged in app code.
- Saved places API owner-scoped; coordinates not sent to analytics/AI memory.

## Tests

| Suite | Status |
| --- | --- |
| Flutter `test/location/*` (WP1 + WP2) | Run in verification |
| Flutter `test/search/search_remote_location_dto_test.dart` | Added |
| Backend `tests/test_saved_places.py` | Added (SQLite fixture) |
| Backend `tests/test_search_discovery_location.py` | Added |
| Backend full pytest | **Blocked** — Windows `python.exe` is Store stub; no project `.venv` (same as Phase 16) |

## Deferred (explicit)

Delivery/service polygons, geofencing, clustering, routing/ETA, courier tracking, PostGIS production rollout, trusted branch coordinate ingestion pipeline.

## Recommended WP3

Trusted branch coordinate ingestion (verified onboarding or branch admin), optional PostGIS index once extension is approved, map list parity for nearby results, saved-place sync UX polish.
