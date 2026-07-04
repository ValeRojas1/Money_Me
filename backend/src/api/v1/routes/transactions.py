from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.api.v1.dependencies import get_current_user
from src.application.use_cases.transaction_use_case import TransactionUseCase
from src.core.errors import NotFoundError
from src.domain.schemas.movement import MovementCreate, MovementUpdate

router = APIRouter()


@router.get("/", summary="List transactions with search, filter, sort, pagination")
async def list_transactions(
    search: str | None = Query(None, description="Search by description"),
    category_id: int | None = Query(None),
    type_filter: str | None = Query(None, alias="type"),
    wallet_id: int | None = Query(None),
    status_filter: str | None = Query(None, alias="status"),
    start_date: str | None = Query(None),
    end_date: str | None = Query(None),
    sort_by: str = Query("date", regex="^(date|amount|description|created)$"),
    sort_order: str = Query("desc", regex="^(asc|desc)$"),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = TransactionUseCase()
    return await use_case.list_transactions(
        db, user_id, search, category_id, type_filter, wallet_id,
        status_filter, start_date, end_date, sort_by, sort_order, page, limit,
    )


@router.get("/{movement_id}", summary="Get transaction by ID")
async def get_transaction(
    movement_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = TransactionUseCase()
    try:
        return await use_case.get_transaction(db, user_id, movement_id)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/", summary="Create a new transaction")
async def create_transaction(
    body: MovementCreate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = TransactionUseCase()
    return await use_case.create_transaction(db, user_id, body.model_dump())


@router.put("/{movement_id}", summary="Update a transaction")
async def update_transaction(
    movement_id: int,
    body: MovementUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = TransactionUseCase()
    try:
        return await use_case.update_transaction(db, user_id, movement_id, body.model_dump(exclude_none=True))
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.delete("/{movement_id}", summary="Delete a transaction")
async def delete_transaction(
    movement_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = TransactionUseCase()
    try:
        return await use_case.delete_transaction(db, user_id, movement_id)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/{movement_id}/categorize-suggestion", summary="Get AI category suggestion")
async def categorize_suggestion(
    movement_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = TransactionUseCase()
    try:
        return await use_case.categorize_suggestion(db, user_id, movement_id)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
