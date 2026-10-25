"""Versioned API router composition."""

from fastapi import APIRouter

from app.api.routes.auth import router as auth_router
from app.api.routes.business_onboarding import router as business_onboarding_router
from app.api.routes.business_onboarding_documents import (
    router as business_onboarding_documents_router,
)
from app.api.routes.business_onboarding_review import router as business_onboarding_review_router
from app.api.routes.health import router as health_router
from app.api.routes.me import router as me_router
from app.api.routes.saved_places import router as saved_places_router
from app.api.routes.search_discovery import router as search_discovery_router
from app.api.routes.checkout import router as checkout_router
from app.api.routes.orders import router as orders_router


api_router = APIRouter()
api_router.include_router(health_router)
api_router.include_router(auth_router)
api_router.include_router(me_router)
api_router.include_router(business_onboarding_router)
api_router.include_router(business_onboarding_documents_router)
api_router.include_router(business_onboarding_review_router)
api_router.include_router(search_discovery_router)
api_router.include_router(saved_places_router)
api_router.include_router(checkout_router)
api_router.include_router(orders_router)
