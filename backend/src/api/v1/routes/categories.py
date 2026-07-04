from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.api.v1.dependencies import get_current_user
from src.application.use_cases.category_use_case import CategoryUseCase
from src.core.errors import NotFoundError
from src.domain.schemas.category import CategoryCreate, CategoryUpdate

router = APIRouter()


@router.get("/", summary="List all active categories")
async def list_categories(
    type_filter: str | None = Query(None, alias="type"),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    use_case = CategoryUseCase()
    items = await use_case.list_categories(db, type_filter)
    return {"items": items}


@router.post("/", summary="Create a custom category")
async def create_category(
    body: CategoryCreate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    use_case = CategoryUseCase()
    return await use_case.create_category(db, body)


@router.put("/{category_id}", summary="Update a category")
async def update_category(
    category_id: int,
    body: CategoryUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    use_case = CategoryUseCase()
    try:
        return await use_case.update_category(db, category_id, body)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.delete("/{category_id}", summary="Delete a custom category")
async def delete_category(
    category_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    use_case = CategoryUseCase()
    try:
        return await use_case.delete_category(db, category_id)
    except (NotFoundError, ValueError) as e:
        raise HTTPException(status_code=400 if isinstance(e, ValueError) else 404, detail=str(e))
