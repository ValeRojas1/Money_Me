from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.api.v1.dependencies import get_current_user
from src.application.use_cases.wallet_use_case import WalletUseCase
from src.core.errors import NotFoundError
from src.domain.schemas.wallet import WalletCreate, WalletUpdate

router = APIRouter()


@router.get("/", summary="List all wallets")
async def list_wallets(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = WalletUseCase()
    return await use_case.list_wallets(db, user_id)


@router.post("/", summary="Create a new wallet")
async def create_wallet(
    body: WalletCreate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = WalletUseCase()
    return await use_case.create_wallet(db, user_id, body)


@router.put("/{wallet_id}", summary="Update a wallet")
async def update_wallet(
    wallet_id: int,
    body: WalletUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = WalletUseCase()
    try:
        return await use_case.update_wallet(db, user_id, wallet_id, body)
    except NotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.delete("/{wallet_id}", summary="Delete a wallet")
async def delete_wallet(
    wallet_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = WalletUseCase()
    try:
        return await use_case.delete_wallet(db, user_id, wallet_id)
    except NotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
