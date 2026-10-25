# Phase 16 WP2 — Search execution, ranking & cursor pagination

## Scope delivered (demo / client)

WP2 adds a **single execution pipeline** on top of Phase 16 WP1 query understanding:

1. Sync demo search index records from `buildSearchCatalog` (no second catalog).
2. Hard eligibility filters (suspended/removed, open-only, distance cap when location is supplied).
3. Deterministic relevance ranking with explainable reason codes.
4. Keyset cursor pagination with validation.
5. `SearchPage` consumes `QoshniSearchExecutionService` (first page + load more).

## Not production backend search

The Python backend still has **no search HTTP route, PostgreSQL search table, or event-driven indexer**. WP2 defines typed DTOs in `qoshni_search_backend_contract.dart` as the future integration boundary only.

Authoritative business data remains in existing domain sources; the in-memory index is a **derived demo read model**, rebuilt when catalog stable IDs change.

## Ranking inputs

| Signal | Source (demo) | When it affects order |
|--------|---------------|------------------------|
| Text / title / prefix | WP1 `matchTerms` + normalized haystack | Always when matched |
| Category implied | WP1 synonym vocabulary | When category ID matches |
| Open | `QoshniSearchRankingSignals.isOpen` | Only when `true` (unknown ignored) |
| Distance | `distanceMeters` + lat/lng + `QoshniSearchFilters.searchLocation` | Never without all three |
| Rating | `averageRating` | Only when ≥ 4.5 |
| Trust | `demoTrustScore` | Only when ≥ 85 (demo-only field) |
| Sponsored | `isSponsored` explicit flag | Capped +0.05 when relevance ≥ 0.45 |

Hard filters run **before** scoring. Suspended demo business `MockBusinessId.shifoPlus` is excluded via `QoshniSearchEligibility`.

## Stable ordering

Primary sort when relevance differs by more than **0.08**: higher `relevanceScore` wins (prevents sponsorship from displacing clearly better matches).

Otherwise: higher `totalScore`, then higher `relevanceScore`, then ascending `stableId` (`category:{id}` / `business:{routeParam}`).

## Sponsored policy

- No invented sponsorship records; only demo metadata in `qoshni_search_demo_ranking_signals.dart`.
- Sponsored results show localized `searchSponsoredLabel` (EN/RU/UZ).
- Sponsorship does not bypass eligibility, open filters, or relevance hard gates.
- No billing, campaigns, or ad serving in WP2.

## Cursor pagination

- Opaque **Base64url JSON** keyset (`v`, query fingerprint `q`, catalog generation `g`, last `totalScore`, `relevanceScore`, `stableId`). **This is not integrity protection** — see WP3 for HMAC-signed backend cursors.
- Page size bounds: 1–20 (default 8).
- Invalid JSON, version mismatch, fingerprint mismatch, or catalog generation mismatch → `invalidCursor` (empty items).
- `nextCursor` is omitted when no further rows exist.
- **Consistency limit (demo):** if catalog content or ranking metadata changes between requests (generation bump), existing cursors are invalidated by design. This is not database snapshot isolation.

## Reused WP1 components

- `QoshniSearchQuery`, validation, `QoshniSearchQueryProcessor`, synonym/spelling/autocomplete vocabulary.
- `SearchCatalogEntry`, `buildSearchCatalog`, `filterSearchCatalogWithUnderstanding` (regression-tested).
- Existing DI and localization patterns.

## Deferred / missing for production

- FastAPI search endpoint with server-side authorization.
- PostgreSQL derived index + idempotent domain-event consumers.
- Real Trust Score model wired from reputation domain (not demo UI scores).
- Phase 17 geolocation permissions and map/list clients.
- Search history, click signals, personalization.

## Acceptance tests when backend exists

- Duplicate event delivery does not double-apply index mutations.
- Stale event revision cannot overwrite newer indexed state.
- Deleted/suspended businesses removed from eligibility.
- Route-level authz and filter validation enforced on the server.
