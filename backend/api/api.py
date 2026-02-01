from .routes.health import router as healthRouter
from .routes.auth import router as authRouter
from fastapi import APIRouter

router=APIRouter()
router.include_router(healthRouter)
router.include_router(authRouter)
api_router = APIRouter(prefix="/api")
api_router.include_router(router)


