# QO'SHNI Backend

Minimal FastAPI foundation for the QO'SHNI platform.

## Current scope

- Application factory
- Environment-based configuration with safe defaults
- Public health endpoint at `/health`
- Versioned health endpoint at `/api/v1/health`
- Health endpoint tests

Database, authentication, business features, Docker, and deployment workflows
are intentionally outside this phase.

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
