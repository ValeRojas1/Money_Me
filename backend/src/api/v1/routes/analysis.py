from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.api.v1.dependencies import get_current_user
from src.application.use_cases.analysis_use_case import AnalysisUseCase

router = APIRouter()


@router.get("/spending", summary="Get spending analysis by category")
async def spending_analysis(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = AnalysisUseCase()
    return await use_case.spending_analysis(db, user_id)


@router.get("/trends", summary="Get spending trends over time")
async def spending_trends(
    months: int = Query(12, ge=1, le=24),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = AnalysisUseCase()
    result = await use_case.trends(db, user_id)
    return result


@router.get("/categories", summary="Get category breakdown")
async def category_breakdown(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = AnalysisUseCase()
    return await use_case.category_analysis(db, user_id)


@router.get("/income-vs-expenses", summary="Compare income vs expenses")
async def income_vs_expenses(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = AnalysisUseCase()
    result = await use_case.spending_analysis(db, user_id)
    return result["income_vs_expenses"]


@router.get("/alerts", summary="Get spending alerts and anomalies")
async def get_alerts(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = AnalysisUseCase()
    return await use_case.generate_alerts(db, user_id)
