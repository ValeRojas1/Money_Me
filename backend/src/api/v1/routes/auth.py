from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.api.v1.dependencies import get_current_user
from src.application.use_cases.auth_use_case import AuthUseCase
from src.core.errors import NotFoundError, UnauthorizedError, ConflictError
from src.domain.schemas.user import UserCreate, UserLogin, UserProfileUpdate

router = APIRouter()


@router.post("/register", summary="Register a new user")
async def register(body: UserCreate, db: AsyncSession = Depends(get_db)):
    use_case = AuthUseCase()
    try:
        return await use_case.register(db, body.email, body.password, body.name)
    except ConflictError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))


@router.post("/login", summary="Authenticate user and return JWT")
async def login(body: UserLogin, db: AsyncSession = Depends(get_db)):
    use_case = AuthUseCase()
    try:
        return await use_case.login(db, body.email, body.password)
    except UnauthorizedError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))


@router.post("/refresh", summary="Refresh access token")
async def refresh_token(
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db),
):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token format")
    token = authorization.removeprefix("Bearer ")
    use_case = AuthUseCase()
    try:
        return await use_case.refresh_token(db, token)
    except UnauthorizedError as e:
        raise HTTPException(status_code=401, detail=str(e))


@router.get("/me", summary="Get current authenticated user with profile and wallets")
async def get_me(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = AuthUseCase()
    try:
        return await use_case.get_me(db, user_id)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.put("/profile", summary="Update user profile")
async def update_profile(
    body: UserProfileUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = AuthUseCase()
    return await use_case.update_profile(
        db,
        user_id,
        name=body.name,
        phone=body.phone,
        preferred_currency=body.preferred_currency,
        locale=body.locale,
        timezone=body.timezone,
    )


@router.post("/change-password", summary="Change user password")
async def change_password(
    body: dict,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = AuthUseCase()
    try:
        return await use_case.change_password(
            db,
            user_id,
            body.get("current_password", ""),
            body.get("new_password", ""),
        )
    except UnauthorizedError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/account", summary="Permanently delete user account and all data")
async def delete_account(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = AuthUseCase()
    return await use_case.delete_account(db, user_id)
