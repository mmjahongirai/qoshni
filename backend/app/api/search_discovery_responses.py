"""Search discovery error responses."""

from __future__ import annotations

from fastapi.responses import JSONResponse

from app.api.schemas.search_discovery import SearchDiscoveryErrorDetail, SearchDiscoveryErrorResponse
from app.domain.search_discovery import SearchDiscoveryErrorCode
from app.services.search_discovery.execution_service import SearchExecutionError


def search_discovery_error_response(error: SearchExecutionError) -> JSONResponse:
    status = 400
    if error.code == SearchDiscoveryErrorCode.INVALID_CURSOR:
        status = 400
    return JSONResponse(
        status_code=status,
        content=SearchDiscoveryErrorResponse(
            error=SearchDiscoveryErrorDetail(code=error.code.value, message=error.message),
        ).model_dump(),
    )
