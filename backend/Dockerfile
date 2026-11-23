# QO'SHNI FastAPI backend — provider-neutral production image.
# Build from the backend directory:  docker build -t qoshni-backend backend
#
# The container only serves the API. It never runs Alembic migrations on
# startup; migrations are a separate, explicitly approved operator step.

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PORT=8000

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app ./app
COPY alembic ./alembic
COPY alembic.ini .

RUN useradd --system --no-create-home --uid 10001 qoshni
USER qoshni

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD python -c "import os, urllib.request; urllib.request.urlopen(f'http://127.0.0.1:{os.environ.get(\"PORT\", \"8000\")}/api/v1/health', timeout=4)"

# Hosting platforms inject PORT; proxy headers keep client scheme/IP correct
# behind the platform's TLS load balancer.
CMD ["sh", "-c", "exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT} --proxy-headers --forwarded-allow-ips='*'"]
