from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.api.v1.dependencies import get_current_user
from src.application.use_cases.prediction_use_case import PredictionUseCase

router = APIRouter()


@router.get("/monthly-spending", summary="Predict next month spending")
async def predict_monthly_spending(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = PredictionUseCase()
    return await use_case.predict_monthly_spending(db, user_id)


@router.get("/income", summary="Predict future income")
async def predict_income(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = PredictionUseCase()
    return await use_case.predict_income(db, user_id)


@router.get("/category/{category_id}", summary="Predict category spending")
async def predict_category(
    category_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = PredictionUseCase()
    return await use_case.predict_category_spending(db, user_id, category_id)


@router.get("/wallet/{wallet_id}", summary="Predict wallet balance")
async def predict_wallet(
    wallet_id: int,
    current_balance_cents: int = Query(..., description="Current balance in cents"),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = PredictionUseCase()
    return await use_case.predict_wallet_balance(
        db, user_id, wallet_id, current_balance_cents
    )


@router.get("/budget-recommendations", summary="Get budget recommendations and tips")
async def budget_recommendations(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = PredictionUseCase()
    return await use_case.budget_recommendations(db, user_id)


@router.get("/savings-goal", summary="Predict time to reach savings goal")
async def predict_savings_goal(
    goal_amount_cents: int = Query(..., gt=0, description="Goal amount in cents"),
    current_savings_cents: int = Query(..., ge=0, description="Current savings in cents"),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user.get("sub", 0)
    use_case = PredictionUseCase()
    return await use_case.savings_goal_projection(
        db, user_id, goal_amount_cents, current_savings_cents
    )
