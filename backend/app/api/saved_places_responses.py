from fastapi.responses import JSONResponse

from app.api.schemas.saved_places import SavedPlaceErrorDetail, SavedPlaceErrorResponse
from app.services.saved_places.saved_place_service import SavedPlaceErrorCode, SavedPlaceServiceError


def saved_place_error_response(error: SavedPlaceServiceError) -> JSONResponse:
    status = 400
    if error.code == SavedPlaceErrorCode.NOT_FOUND:
        status = 404
    elif error.code == SavedPlaceErrorCode.FORBIDDEN:
        status = 403
    return JSONResponse(
        status_code=status,
        content=SavedPlaceErrorResponse(
            error=SavedPlaceErrorDetail(code=error.code.value, message=error.message),
        ).model_dump(mode="json"),
    )
