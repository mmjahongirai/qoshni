from fastapi.responses import JSONResponse

from app.api.schemas.branch_coordinates import BranchCoordinateView
from app.db.models.branch_coordinates import BusinessOnboardingBranchCoordinate
from app.domain.branch_coordinates import BranchCoordinateSource, BranchCoordinateVerificationStatus
from pydantic import BaseModel


class BranchCoordinateErrorDetail(BaseModel):
    code: str
    message: str


class BranchCoordinateErrorResponse(BaseModel):
    error: BranchCoordinateErrorDetail


def branch_coordinate_view(row: BusinessOnboardingBranchCoordinate) -> BranchCoordinateView:
    return BranchCoordinateView(
        application_id=row.application_id,
        latitude=row.latitude,
        longitude=row.longitude,
        coordinate_source=BranchCoordinateSource(row.coordinate_source),
        verification_status=BranchCoordinateVerificationStatus(row.verification_status),
        revision=row.revision,
        verified_revision=row.verified_revision,
        verified_at=row.verified_at,
        proposed_at=row.proposed_at,
        updated_at=row.updated_at,
    )


def branch_coordinate_error_response(code: str, message: str, status: int) -> JSONResponse:
    return JSONResponse(
        status_code=status,
        content=BranchCoordinateErrorResponse(
            error=BranchCoordinateErrorDetail(code=code, message=message),
        ).model_dump(mode="json"),
    )
