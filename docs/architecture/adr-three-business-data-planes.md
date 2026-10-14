# ADR: Three business data planes (consumer, samples, owner)

**Status:** Accepted  
**Date:** 2026-03-24  
**Context:** Business Center and consumer discovery must not share storage or confuse demo content with real owner records before authentication and backend persistence exist.

## Decision

Maintain three isolated data planes:

| Plane | Source of truth | Used by |
|-------|-----------------|---------|
| **Consumer demo catalog** | Static builders (`buildAllMockBusinesses`, catalog mock data) | Home, search, business detail, cart demo commerce |
| **Business Center samples** | Read-only builders (`buildBusinessProfileSamples`, `buildSampleOfferingsForProfile`) gated by `AppConfig` | Business Center when viewing sample demo profiles |
| **Business-owner session data** | `BusinessProfileRepository`, `BusinessOfferingRepository`, `BusinessInventoryRepository` (in-memory today) | Business Center drafts, offerings, inventory |

## Rules

1. **No mixing:** Owner drafts and offerings never flow into consumer mock catalog or public search results. Sample IDs are stable and distinct from user draft IDs.
2. **Samples are optional UI:** `AppConfig.enableBusinessProfileSamples` and `enableBusinessOfferingSamples` only control whether sample builders return data. Disabling flags hides examples; it does not delete repository-backed user data.
3. **Ownership:** Repositories scope offerings and inventory by `businessProfileId` / `offeringId`. Inventory validates against the offering repository; deleting an offering removes its inventory record.
4. **Samples ≠ repository:** Sample builders are not registered as repositories and are never written through owner CRUD APIs.

## Later (auth + backend)

- Replace in-memory repository implementations with API-backed adapters using the same domain contracts.
- Authenticated user ID becomes the ownership key; server validates profile/offering/inventory relationships.
- Consumer catalog will be fed by a separate catalog/search service, not owner draft storage.
- `AppConfig` sample flags remain compile-time / deploy-time toggles for demos; production defaults stay off unless explicitly enabled.

## References

- `lib/core/config/app_config.dart`
- `lib/features/business_platform/domain/repositories/`
- `docs/ARCHITECTURE.md` (layering and DI)
