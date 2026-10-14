# QO'SHNI Backend

Minimal FastAPI foundation for the QO'SHNI platform.

## Current scope

- Application factory
- Environment-based configuration with safe defaults
- Public health endpoint at `/health`
- Versioned health endpoint at `/api/v1/health`
- Optional database URL configuration via environment variables
- Lazy SQLAlchemy engine and request-scoped session dependency (no connection until used)
- Health endpoint tests

- Identity schema (users, OTP challenges, sessions, auth audit) in revision
  `b0a1f0050001`, plus typed `/api/v1/auth` contracts in `app/api/schemas/auth.py`.
  Auth endpoints are **not** mounted yet; see
  `docs/architecture/adr-identity-auth-foundation.md`.

OTP delivery, working auth endpoints, business features, Docker, and deployment
workflows are intentionally left to later phases.

## Local setup

From the `backend` directory:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
Copy-Item .env.example .env
```

## Run

```powershell
python -m uvicorn app.main:app --reload
```

Interactive API documentation is available at `/docs` while the server runs.

## Test

```powershell
python -m pytest
```

Use `.env` only for local values. Never commit secrets or credentials.

## Database configuration notes

- Set `QOSHNI_DATABASE_URL` (or `DATABASE_URL`) before process startup in normal
  deployments. The engine is created lazily on first database use.
- If database settings change at runtime, call `dispose_engine()` before the new
  settings are used. Otherwise the application raises a configuration conflict
  error rather than silently reusing a mismatched cached engine.
- `QOSHNI_DATABASE_ECHO=true` enables SQLAlchemy statement logging for controlled
  local debugging only. Keep it disabled in production.

## Database migrations (Alembic)

- Migrations are **never** run automatically during FastAPI startup.
- Run Alembic manually from the `backend/` directory when schema work is ready.
- Alembic reads `QOSHNI_DATABASE_URL` (or `DATABASE_URL`) through the same
  application settings layer used by the API.
- The baseline revision is an empty anchor and does not create business tables.
- PostGIS may already be enabled on managed Supabase projects. This repository
  does not run `CREATE EXTENSION postgis` in the baseline migration.
- For Supabase, use a **direct/session** database connection string when running
  `alembic upgrade head`. Avoid transaction-pooler URLs for DDL migrations.

```powershell
# Requires QOSHNI_DATABASE_URL in the environment or backend/.env
alembic upgrade head
alembic current
alembic history
```

Autogenerate workflow for future schema changes:

```powershell
alembic revision --autogenerate -m "describe change"
```

Review generated SQL carefully before applying it to shared environments.
