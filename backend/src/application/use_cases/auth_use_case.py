from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.config.settings import settings
from src.core.errors import ConflictError, NotFoundError, UnauthorizedError
from src.core.security import create_access_token, decode_access_token, hash_password, verify_password
from src.domain.models.user import User, UserStatus


class AuthUseCase:

    async def register(
        self, db: AsyncSession, email: str, password: str, name: str
    ) -> dict:
        stmt = select(User).where(User.email == email)
        result = await db.execute(stmt)
        existing = result.scalar_one_or_none()
        if existing:
            raise ConflictError("Email already registered")

        user = User(
            email=email,
            password_hash=hash_password(password),
            status=UserStatus.ACTIVE,
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)

        from src.domain.models.profile import Profile
        profile = Profile(
            user_id=user.id,
            name=name,
        )
        db.add(profile)
        await db.commit()

        token = create_access_token({"sub": str(user.id), "email": user.email})

        return {
            "access_token": token,
            "token_type": "bearer",
            "user": {"id": user.id, "email": user.email, "name": name},
        }

    async def login(self, db: AsyncSession, email: str, password: str) -> dict:
        stmt = select(User).where(User.email == email)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user or not verify_password(password, user.password_hash):
            raise UnauthorizedError("Invalid email or password")

        if user.status != UserStatus.ACTIVE:
            raise UnauthorizedError("Account is inactive or suspended")

        user.last_login_at = datetime.now(timezone.utc)
        await db.commit()

        token = create_access_token({"sub": str(user.id), "email": user.email})

        from src.domain.models.profile import Profile
        stmt = select(Profile).where(Profile.user_id == user.id)
        result = await db.execute(stmt)
        profile = result.scalar_one_or_none()

        return {
            "access_token": token,
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "email": user.email,
                "name": profile.name if profile else "",
            },
        }

    async def get_me(self, db: AsyncSession, user_id: int) -> dict:
        stmt = select(User).where(User.id == user_id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        if not user:
            raise NotFoundError("User not found")

        from src.domain.models.profile import Profile
        from src.domain.models.wallet import Wallet

        stmt = select(Profile).where(Profile.user_id == user_id)
        result = await db.execute(stmt)
        profile = result.scalar_one_or_none()

        stmt = select(Wallet).where(Wallet.user_id == user_id)
        result = await db.execute(stmt)
        wallets = result.scalars().all()

        return {
            "id": user.id,
            "email": user.email,
            "status": user.status.value,
            "profile": {
                "name": profile.name if profile else "",
                "avatar_url": profile.avatar_url if profile else None,
                "phone": profile.phone if profile else None,
                "preferred_currency": profile.preferred_currency if profile else "USD",
                "locale": profile.locale if profile else "en-US",
                "timezone": profile.timezone if profile else "UTC",
            } if profile else None,
            "wallets": [
                {
                    "id": w.id,
                    "name": w.name,
                    "type": w.type.value,
                    "currency": w.currency,
                    "balance_cents": w.balance_cents,
                    "is_default": w.is_default,
                }
                for w in wallets
            ],
            "created_at": user.created_at.isoformat(),
        }

    async def refresh_token(self, db: AsyncSession, token: str) -> dict:
        payload = decode_access_token(token)
        if not payload:
            raise UnauthorizedError("Invalid or expired token")

        user_id = int(payload.get("sub", 0))
        stmt = select(User).where(User.id == user_id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user or user.status != UserStatus.ACTIVE:
            raise UnauthorizedError("User not found or inactive")

        new_token = create_access_token({"sub": str(user.id), "email": user.email})
        return {"access_token": new_token, "token_type": "bearer"}

    async def update_profile(
        self,
        db: AsyncSession,
        user_id: int,
        name: str | None = None,
        phone: str | None = None,
        preferred_currency: str | None = None,
        locale: str | None = None,
        timezone: str | None = None,
    ) -> dict:
        from src.domain.models.profile import Profile

        stmt = select(Profile).where(Profile.user_id == user_id)
        result = await db.execute(stmt)
        profile = result.scalar_one_or_none()

        if not profile:
            profile = Profile(user_id=user_id, name=name or "")
            db.add(profile)
        else:
            if name is not None:
                profile.name = name
            if phone is not None:
                profile.phone = phone
            if preferred_currency is not None:
                profile.preferred_currency = preferred_currency.upper()
            if locale is not None:
                profile.locale = locale
            if timezone is not None:
                profile.timezone = timezone

        await db.commit()
        await db.refresh(profile)

        return {
            "name": profile.name,
            "phone": profile.phone,
            "preferred_currency": profile.preferred_currency,
            "locale": profile.locale,
            "timezone": profile.timezone,
        }

    async def change_password(
        self,
        db: AsyncSession,
        user_id: int,
        current_password: str,
        new_password: str,
    ) -> dict:
        stmt = select(User).where(User.id == user_id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user or not verify_password(current_password, user.password_hash):
            raise UnauthorizedError("Current password is incorrect")

        user.password_hash = hash_password(new_password)
        await db.commit()

        return {"message": "Password updated successfully"}

    async def delete_account(self, db: AsyncSession, user_id: int) -> dict:
        from src.domain.models.budget import Budget
        from src.domain.models.capture import ProcessedCapture
        from src.domain.models.movement import Movement
        from src.domain.models.profile import Profile
        from src.domain.models.wallet import Wallet

        stmt = select(User).where(User.id == user_id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        if not user:
            raise NotFoundError("User not found")

        for model in [Movement, ProcessedCapture, Budget, Wallet, Profile]:
            stmt = select(model).where(model.user_id == user_id)
            result = await db.execute(stmt)
            for row in result.scalars().all():
                await db.delete(row)

        await db.delete(user)
        await db.commit()
        return {"message": "Account permanently deleted"}
