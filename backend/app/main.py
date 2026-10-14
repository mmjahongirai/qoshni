"""FastAPI application entry point."""

from contextlib import asynccontextmanager

from fastapi import FastAPI, Request

from app.api.auth_responses import auth_error_response
from app.api.deps.access import AuthenticationRequired
from app.api.router import api_router
from app.api.routes.health import router as health_router
from app.core.config import get_settings
from app.core.database import dispose_engine


@asynccontextmanager
async def lifespan(_: FastAPI):
    """Application lifespan hooks."""

    yield
    dispose_engine()


def create_app() -> FastAPI:
    """Create and configure the QO'SHNI backend application."""

    settings = get_settings()
    application = FastAPI(
        title=settings.app_name,
        version=settings.app_version,
        lifespan=lifespan,
    )

    @application.exception_handler(AuthenticationRequired)
    async def authentication_required_handler(
        _request: Request,
        exc: AuthenticationRequired,
    ):
        return auth_error_response(exc.error)

    application.include_router(health_router)
    application.include_router(api_router, prefix=settings.api_v1_prefix)
    return application


app = create_app()
