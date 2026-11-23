# Backend deployment (production foundation)

This describes how to run the QO'SHNI FastAPI backend on a container host.
It does **not** cover database creation or migrations: those are separate,
explicitly approved steps.

## Image

`backend/Dockerfile` builds a provider-neutral image (Python 3.12, the same
version CI tests with). Build context is the `backend` directory.

- Entrypoint: `uvicorn app.main:app`, listening on `$PORT` (default `8000`).
- The container never runs `alembic upgrade` on startup.
- Runs as a non-root user.

Any host that builds a Dockerfile works (for example Render or Railway
"Docker" services). Point the service at `backend/Dockerfile` with
`backend` as the root/context directory.

## Health check

`GET /api/v1/health` (also `GET /health`) returns
`{"status": "ok", "service": "...", "version": "..."}`.

It does not touch the database, so it passes before a database is attached.
Configure the platform health check path as `/api/v1/health`.

## Environment variables

Set these in the hosting platform's secret/env settings. Never commit values.

### Required for a production process to start

| Variable | Value | Notes |
|---|---|---|
| `QOSHNI_ENVIRONMENT` | `production` | Enables production validation. |
| `QOSHNI_MALWARE_SCANNER_PROVIDER` | `clamav` | Startup fails in production without it. The scanner is only contacted when a document is uploaded. |

### Required before the matching features are used

| Variable | Secret | Notes |
|---|---|---|
| `QOSHNI_DATABASE_URL` (alias `DATABASE_URL`) | yes | PostgreSQL URL, e.g. `postgresql+psycopg://...`. Leave unset to run without a database: health works, data endpoints fail. Use the provider's pooled URL for the app and a direct/session URL for migrations. |
| `QOSHNI_AUTH_SECRET_DIGEST_KEY` | yes | Server-only HMAC key for OTP and refresh-token digests. Generate per environment. |
| `QOSHNI_MALWARE_SCANNER_HOST` / `_PORT` / `_TIMEOUT_SECONDS` | no | Self-hosted ClamAV address. |
| `QOSHNI_OBJECT_STORAGE_PROVIDER` (`s3`), `_BUCKET`, `_REGION`, `_ENDPOINT` | no | Private bucket for onboarding documents. `local` is rejected in production. |
| `QOSHNI_OBJECT_STORAGE_ACCESS_KEY_ID`, `QOSHNI_OBJECT_STORAGE_SECRET_ACCESS_KEY` | yes | Bucket credentials. |

### Optional (safe defaults)

`QOSHNI_APP_NAME`, `QOSHNI_SERVICE_NAME`, `QOSHNI_APP_VERSION`,
`QOSHNI_API_V1_PREFIX`, `QOSHNI_DATABASE_POOL_SIZE`,
`QOSHNI_DATABASE_MAX_OVERFLOW`, `QOSHNI_DATABASE_POOL_TIMEOUT`,
`QOSHNI_DATABASE_POOL_RECYCLE`, `QOSHNI_DATABASE_ECHO` (keep `false`),
`QOSHNI_AUTH_*` TTL and limit settings.

### Feature switches — keep off

| Variable | Keep | Why |
|---|---|---|
| `QOSHNI_CONSUMER_CATALOG_ENABLED` | `false` | Only after catalog migrations are applied and approved. |
| `QOSHNI_RESERVATION_MAINTENANCE_ENABLED` | `false` | Separate worker process; not deployed. |

## Known gaps before the web app can call this API

- **CORS is not configured.** The app has no `CORSMiddleware`, so browsers on
  the Vercel domain cannot call it yet. This needs a code change with an
  allow-list of frontend origins.
- **`/docs` and `/openapi.json` are public.** Decide whether to keep them in
  production.
- **Wallet and payment routes are mounted without a feature flag.** They need
  the Phase 19 tables; until migrations run they return server errors.
- The frontend only calls the API when Vercel builds it with
  `QOSHNI_API_BASE_URL` set.
