from fastapi import Depends, Header
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.core.security import decode_access_token
from src.core.errors import UnauthorizedError


async def get_current_user(
    authorization: str | None = Header(None),
    db: AsyncSession = Depends(get_db),
) -> dict:
    if authorization is None:
        raise UnauthorizedError("Authorization header missing")
    if not authorization.startswith("Bearer "):
        raise UnauthorizedError("Invalid authorization header")

    token = authorization.removeprefix("Bearer ")
    payload = decode_access_token(token)
    if payload is None:
        raise UnauthorizedError("Invalid or expired token")

    return payload
