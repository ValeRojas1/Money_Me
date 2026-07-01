from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.api.v1.dependencies import get_current_user
from src.application.use_cases.dashboard_use_case import DashboardUseCase

router = APIRouter()


@router.get("/summary", summary="Monthly income, expenses, balance, and variation")
async def dashboard_summary(
    month: str | None = Query(None, regex=r"^\d{4}-\d{2}$"),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = DashboardUseCase()
    return await use_case.summary(db, user_id, month)


@router.get("/top-categories", summary="Top expense categories")
async def top_categories(
    limit: int = Query(5, ge=1, le=20),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = DashboardUseCase()
    return await use_case.top_categories(db, user_id, limit)


@router.get("/monthly-trend", summary="Monthly income/expense trend")
async def monthly_trend(
    months: int = Query(12, ge=3, le=24),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = DashboardUseCase()
    return await use_case.monthly_trend(db, user_id, months)


@router.get("/category-breakdown", summary="Expense breakdown by category for a month")
async def category_breakdown(
    month: str | None = Query(None, regex=r"^\d{4}-\d{2}$"),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = DashboardUseCase()
    return await use_case.category_breakdown(db, user_id, month)


@router.get("/wallet-breakdown", summary="Balance breakdown by wallet")
async def wallet_breakdown(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = DashboardUseCase()
    return await use_case.wallet_breakdown(db, user_id)
