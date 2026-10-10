"""Tests for public health endpoints."""

import pytest
from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


@pytest.mark.parametrize("path", ["/health", "/api/v1/health"])
def test_health_endpoint(path: str) -> None:
    response = client.get(path)

    assert response.status_code == 200
    assert response.json() == {
        "status": "ok",
        "service": "qoshni-backend",
        "version": "0.1.0",
    }


def test_health_response_does_not_expose_secrets() -> None:
    response = client.get("/health")
    payload = response.json()

    assert {"secret", "api_key", "password", "token"}.isdisjoint(payload)
