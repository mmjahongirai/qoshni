# ADR: User profile and preferences foundation (Phase 06 Part 1)

**Status:** Accepted (schema, contracts, and `/api/v1/me/*` routes — Part 2)
**Date:** 2026-10-14 (updated Part 2)
**Scope:** `backend/` — models through Alembic `b0a1f0070001`, routes in `app/api/routes/me.py`

## Context

Signed-in users need a stable, user-owned profile and explicit personalization settings separate from authentication identity. Phase 06 Part 1 established persistence and contracts. Part 2 mounts authenticated routes and provisions rows on successful OTP sign-in.

## Decision

### Identity vs profile

| Layer | Source of truth | Must not duplicate |
|-------|-----------------|-------------------|
| Authentication | `users` (UUID, E.164 phone, verification, account status) | Display name, locale, avatar bytes |
| Profile | `user_profiles` (display name, avatar storage reference) | Phone, tokens, roles |
| Preferences | `user_preferences` (locale, personalization opt-in) | Search history, favorites, notifications |

One authenticated `User` may have at most one `UserProfile` and one `UserPreferences` row (`UNIQUE(user_id)`). Deleting a user cascades both.

### Schema summary

**`user_profiles`**

- `id` (UUID, PK), `user_id` (FK → `users.id`, unique)
- `display_name` — optional, max 64 chars, not blank when set
- `avatar_storage_ref` — optional opaque object key/path only; **no upload pipeline in Part 1**
- `created_at`, `updated_at` (timestamptz)

**`user_preferences`**

- `id` (UUID, PK), `user_id` (FK → `users.id`, unique)
- `preferred_language` — `en` | `ru` | `uz` (matches Flutter `AppLocalizations.supportedLocales`)
- `personalization_enabled` — boolean, **default `false`** (explicit opt-in before using personalization features)
- `created_at`, `updated_at`

Defaults apply when a preferences row is first created (future provisioning). English is the stored default language until the user changes it.

### Mounted API (Part 2)

All routes require a valid bearer access token (`get_current_principal`). Paths are relative to `/api/v1`:

| Method | Path | Success | Notes |
|--------|------|---------|-------|
| GET | `/me/profile` | 200 | Returns `UserProfileView`; **404** `profile_not_found` if row missing |
| PATCH | `/me/profile` | 200 | Partial update; `clear_*` flags; **404** if missing |
| GET | `/me/preferences` | 200 | **404** `preferences_not_found` if row missing |
| PATCH | `/me/preferences` | 200 | Partial update of explicit fields only |

**Provisioning:** `ensure_user_profile_resources` runs during successful OTP verify before commit. Sign-in returns **503** if provisioning fails. After normal sign-in, rows exist; **404** remains for edge cases (manual deletion, legacy data).

**Authorization:** `user_id` is taken only from the access token, never from the request body. Requests use `extra="forbid"` and must not include `user_id`, phone, or role fields.

**Conflict:** Creating a second profile or preferences row for the same user is prevented by the database; a future create endpoint would return **409** on duplicate insert.

**Privacy:** Responses must not include `phone_e164`, tokens, OTP data, or digests. Avatar responses expose only the storage reference string, not file contents.

### Out of scope (later Phase 06 increments)

- Profile/preferences HTTP handlers and provisioning on sign-in
- Avatar upload, CDN, or image processing
- Favorites, saved places, search history, location-history retention
- Notification preferences, privacy settings APIs, AI memory
- Business-owner profile, KYC, or cross-user profile reads

## Consequences

- Alembic head moves to `b0a1f0070001` (parent `b0a1f0060001`).
- ORM metadata and migrated SQLite test DB must stay in sync via existing migration tests.
- Flutter profile UI and secure avatar handling remain future work.
