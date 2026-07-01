import asyncio
from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.exceptions import HTTPException as StarletteHTTPException

from src.api.deps import get_db
from src.api.v1.routes import auth, transactions, analysis, predictions, reports, ocr, wallets, categories, dashboard, budgets
from src.config.database import init_db
from src.config.settings import settings
from src.core.error_handlers import global_exception_handler, http_exception_handler
from src.infrastructure.ocr.cleanup_service import cleanup_loop


cleanup_task: asyncio.Task | None = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global cleanup_task
    await init_db()
    cleanup_task = asyncio.create_task(cleanup_loop(interval_hours=24))
    yield
    if cleanup_task:
        cleanup_task.cancel()
        try:
            await cleanup_task
        except asyncio.CancelledError:
            pass


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url=f"{settings.api_prefix}/openapi.json",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(Exception, global_exception_handler)


@app.get("/health", tags=["Health"])
async def health():
    return {
        "status": "ok",
        "app": settings.app_name,
        "version": settings.app_version,
    }


@app.get(f"{settings.api_prefix}/health/db", tags=["Health"])
async def health_db(db: AsyncSession = Depends(get_db)):
    await db.execute(text("SELECT 1"))
    return {"status": "ok", "database": "connected"}


app.include_router(auth.router, prefix=f"{settings.api_prefix}/auth", tags=["Auth"])
app.include_router(
    transactions.router, prefix=f"{settings.api_prefix}/transactions", tags=["Transactions"]
)
app.include_router(
    analysis.router, prefix=f"{settings.api_prefix}/analysis", tags=["Analysis"]
)
app.include_router(
    predictions.router, prefix=f"{settings.api_prefix}/predictions", tags=["Predictions"]
)
app.include_router(reports.router, prefix=f"{settings.api_prefix}/reports", tags=["Reports"])
app.include_router(ocr.router, prefix=f"{settings.api_prefix}/ocr", tags=["OCR"])
app.include_router(wallets.router, prefix=f"{settings.api_prefix}/wallets", tags=["Wallets"])
app.include_router(
    categories.router, prefix=f"{settings.api_prefix}/categories", tags=["Categories"]
)
app.include_router(
    dashboard.router, prefix=f"{settings.api_prefix}/dashboard", tags=["Dashboard"]
)
app.include_router(
    budgets.router, prefix=f"{settings.api_prefix}/budgets", tags=["Budgets"]
)
