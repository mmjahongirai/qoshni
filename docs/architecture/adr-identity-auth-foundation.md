# ADR: Identity and authentication foundation (Phase 05)

**Status:** Accepted (OTP, session refresh, listing, and revocation implemented)
**Date:** 2026-10-14 (updated Part 3)
**Scope:** `backend/` — identity models, Alembic through `b0a1f0060001`, `/api/v1/auth`

## Context

QO'SHNI is phone-first. Authentication must keep secrets off clients, out of logs, and separate from authorization.

## Decision

### Data ownership

All four records belong to the identity domain (`app/db/models/identity.py`).

| Record | Owns | Does not own |
|--------|------|--------------|
| `users` | Stable UUID, normalized E.164 phone (unique), phone verification time, account status | Roles, permissions, business ownership, KYC |
| `otp_challenges` | Phone, purpose, keyed code digest, expiry, attempts, consumed time | SMS provider state |
| `auth_sessions` | User FK, access/refresh digests (unique), expiries, revocation, display-only device fields | Device trust |
| `auth_audit_events` | Event type, user/target refs, correlation ID, minimal JSON | Phones, codes, tokens, digests |

### Authentication vs authorization

Authentication answers who the caller is (`AuthenticatedPrincipal`: `user_id`, `session_id`). Authorization (business roles, KYC) is deferred. Clients cannot assert identity via request body fields.

### Access-token validation

- Header: `Authorization: Bearer <opaque access token>` only.
- Dependency: `get_current_principal` (`app/api/deps/access.py`).
- Lookup by HMAC digest (`access_token` domain) on `auth_sessions.access_token_digest`.
- Rejects missing/malformed bearer, unknown digest, revoked session, expired access or refresh window, or non-`active` user status.
- Never logs raw tokens or Authorization headers.

### Refresh rotation

- `POST /api/v1/auth/sessions/refresh` locks the session row (`SELECT … FOR UPDATE`) by refresh digest.
- On success, rotates **both** access and refresh tokens and updates digests and expiries atomically in one transaction.
- Prior raw tokens stop working immediately after commit.
- **Reuse detection is incomplete:** a stolen refresh token used after rotation fails (digest no longer matches), but we do not retain prior refresh digests for explicit reuse/revoke-all detection. That requires a follow-up (e.g. `previous_refresh_token_digest` or family ID).

### Session listing and revocation

- `GET /api/v1/auth/sessions` requires access token; returns only the caller's sessions, newest first, with derived `active` / `expired` / `revoked` state. No digests or raw tokens.
- `DELETE /api/v1/auth/sessions/current` revokes the bearer session (`logout`).
- `DELETE /api/v1/auth/sessions/{session_id}` revokes only if owned by the caller; otherwise **404** `session_not_found` (no cross-user enumeration).
- Repeat logout on the same revoked bearer returns **401** (token no longer valid).

### Concurrency

PostgreSQL: row locks during refresh/revoke give single-winner rotation. SQLite tests use the same ORM patterns; locking semantics may differ slightly under high concurrency.

### Secrets and tokens

Opaque tokens + HMAC-SHA256 digests (`app/core/auth/secrets.py`). No JWT. Policy via `Settings` (OTP TTL, access 15 min, refresh 30 days, rate windows).

### OTP delivery

Runtime default `UnconfiguredOtpDeliveryProvider` → 503. Test-only `FakeOtpProvider`. No dev OTP in logs or HTTP.

### Mounted endpoints

All `/api/v1/auth` contracts in `AUTH_ENDPOINT_CONTRACTS` are implemented: OTP challenge/verify, refresh, session list, current logout, revoke by ID.

## Still deferred

- Real SMS provider wiring.
- IP-based rate limits; refresh reuse detection with stored prior digests.
- Access-token middleware applied to non-auth business routes; Flutter auth UI.
- Account recovery flow; trusted devices; authorization roles; audit retention jobs.
