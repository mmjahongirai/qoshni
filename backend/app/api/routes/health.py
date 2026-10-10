"""Service health endpoint."""

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from app.core.config import Settings, get_settings


router = APIRouter(tags=["health"])


class HealthResponse(BaseModel):
    """Public health response without operational secrets."""

    status: str
    service: str
    version: str


@router.get("/health", response_model=HealthResponse)
def get_health(settings: Settings = Depends(get_settings)) -> HealthResponse:
    """Report whether the API process is available."""

    return HealthResponse(
        status="ok",
        service=settings.service_name,
        version=settings.app_version,
    )
