# Search & Discovery — Phase 16 WP1 (query understanding)

## Scope

WP1 delivers the Flutter **query understanding foundation**: validation, normalization, multilingual synonym expansion, spelling hints, and autocomplete. It is the first layer of the Phase 16 search pipeline; **WP2** adds demo execution/ranking/pagination, and **WP3** adds an authenticated backend API and PostgreSQL read model.

WP1 alone is **not** full production search. Ranking, cursors, and index ownership are defined in [search_discovery_wp2.md](./search_discovery_wp2.md) and [search_discovery_wp3.md](./search_discovery_wp3.md).

## Components

| Area | Location |
|------|----------|
| Query validation & models | `lib/features/search/domain/` |
| Normalization, synonyms, typo hints | `lib/features/search/application/` |
| Demo vocabulary catalogue | `lib/features/search/data/` |
| DI wiring | `lib/di/injection.dart` |
| Search UI | `lib/features/home/presentation/pages/search_page.dart` |
| Localized demo catalog | `lib/features/home/presentation/data/home_mock_data.dart` |

## Reused architecture

- Existing **SearchPage**, **SearchResultTile**, and `buildSearchCatalog` mock data (not a second catalog).
- **Categories** use `ServiceCategoryId` and localized labels.
- Business catalog listing keeps its separate searchable-text helper — not duplicated.

## Query processing

1. Validate length and empty/whitespace input (`kQoshniSearchQueryMaxLength = 120`).
2. Preserve **original** query text.
3. **Normalize**: trim, collapse whitespace, lowercase (Latin + Cyrillic via Dart `toLowerCase()` — no transliteration).
4. Expand **synonym groups** (e.g. `dorixona`, `дорихона`, `apteka`, `аптека` → pharmacy category).
5. Optional **spelling suggestion** (bounded Levenshtein, max distance 2) — original query is never silently replaced.
6. **Autocomplete** from demo vocabulary; empty query returns nothing; default limit 8.

## Phase 16 end-to-end (how WP1 fits)

| Mode | Index / data | Execution |
|------|----------------|-----------|
| **Demo (default)** | In-memory index built from `buildSearchCatalog` | `QoshniSearchExecutionService` (WP2 ranking + demo cursor) |
| **Remote (opt-in)** | PostgreSQL `search_index_records` (WP3) | `POST /api/v1/search/discovery` via `RemoteQoshniSearchDataSource` when `ENABLE_REMOTE_SEARCH_DISCOVERY=true` and `QOSHNI_API_BASE_URL` are set |

Remote mode requires a signed-in session (bearer token). It does **not** silently fall back to demo results on failure.

**Backend eligibility (WP3)** is derived from **verified/suspended onboarding applications** projected into the search read model — not from the Flutter mock business list and not a complete public business catalog.

There is **no operational message broker or async event consumer**; index updates use in-process projection after reviewer status changes (see WP3).

## Limitations (consistent across WP1–WP3)

- Rule-based dictionary — **not** ML intent detection.
- No search history, personalization, or click signals.
- **Sponsored**, Trust Score, ratings, coordinates, and open-now: only where explicit demo or authoritative fields exist; never invented on the backend.
- **Demo cursors** (WP2) are encoding only; **backend cursors** (WP3) are HMAC-signed server-side.
- Location-based search is deferred (Phase 17).
- Flutter-side checks do **not** replace backend authorization on `/api/v1/search/discovery`.

## Backend API (WP3)

Authenticated endpoint: **`POST /api/v1/search/discovery`**

Request/response shapes align with `QoshniSearchBackendSearchRequestDto` / `QoshniSearchBackendSearchResponseDto` in `lib/features/search/domain/qoshni_search_backend_contract.dart`.

Migration `b0a1f0150001` defines the read model; apply via Alembic in environments that use PostgreSQL — not required for Flutter demo mode.

## Tests

- WP1: `test/search/qoshni_search_query_understanding_test.dart`
- WP2: `test/search/qoshni_search_execution_wp2_test.dart`
- WP3 (Flutter): `test/search/qoshni_search_remote_adapter_test.dart`
- Backend: `backend/tests/test_search_discovery.py` (requires project Python venv)
