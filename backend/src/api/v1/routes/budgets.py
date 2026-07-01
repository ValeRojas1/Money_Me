from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.api.v1.dependencies import get_current_user
from src.application.use_cases.budget_use_case import BudgetUseCase
from src.core.errors import NotFoundError
from src.domain.schemas.budget import BudgetCreate, BudgetUpdate

router = APIRouter()


@router.get("/", summary="List active budgets with spent tracking")
async def list_budgets(
    month: str | None = Query(None, regex=r"^\d{4}-\d{2}$"),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = BudgetUseCase()
    return await use_case.list_budgets(db, user_id, month)


@router.post("/", summary="Create a budget")
async def create_budget(
    body: BudgetCreate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = BudgetUseCase()
    return await use_case.create_budget(db, user_id, body)


@router.put("/{budget_id}", summary="Update a budget")
async def update_budget(
    budget_id: int,
    body: BudgetUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = BudgetUseCase()
    try:
        return await use_case.update_budget(db, user_id, budget_id, body)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.delete("/{budget_id}", summary="Delete a budget")
async def delete_budget(
    budget_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = BudgetUseCase()
    try:
        return await use_case.delete_budget(db, user_id, budget_id)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.get("/alerts", summary="Budget alerts when near or over limit")
async def budget_alerts(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = BudgetUseCase()
    return await use_case.budget_alerts(db, user_id)
