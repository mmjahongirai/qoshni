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

Database migrations, authentication, business features, Docker, and deployment
workflows are intentionally outside this phase.

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
