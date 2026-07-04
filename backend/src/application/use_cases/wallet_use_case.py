from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.errors import ConflictError, NotFoundError
from src.domain.models.wallet import Wallet, WalletStatus, WalletType
from src.domain.schemas.wallet import WalletCreate, WalletUpdate


class WalletUseCase:

    async def list_wallets(self, db: AsyncSession, user_id: int) -> list[dict]:
        stmt = select(Wallet).where(
            Wallet.user_id == user_id,
        ).order_by(Wallet.is_default.desc(), Wallet.created_at)
        result = await db.execute(stmt)
        wallets = result.scalars().all()
        return [
            {
                "id": w.id,
                "name": w.name,
                "type": w.type.value,
                "currency": w.currency,
                "balance_cents": w.balance_cents,
                "credit_limit_cents": w.credit_limit_cents,
                "status": w.status.value,
                "is_default": w.is_default,
                "color": w.color,
                "icon": w.icon,
                "institution": w.institution,
                "created_at": w.created_at.isoformat(),
            }
            for w in wallets
        ]

    async def create_wallet(
        self, db: AsyncSession, user_id: int, data: WalletCreate
    ) -> dict:
        if data.is_default:
            stmt = select(Wallet).where(
                Wallet.user_id == user_id,
                Wallet.is_default == True,
            )
            result = await db.execute(stmt)
            for w in result.scalars().all():
                w.is_default = False

        wallet = Wallet(
            user_id=user_id,
            name=data.name,
            type=data.type,
            currency=data.currency,
            balance_cents=data.balance_cents,
            credit_limit_cents=data.credit_limit_cents,
            is_default=data.is_default,
            color=data.color,
            icon=data.icon,
            institution=data.institution,
        )
        db.add(wallet)
        await db.commit()
        await db.refresh(wallet)

        return {
            "id": wallet.id,
            "name": wallet.name,
            "type": wallet.type.value,
            "currency": wallet.currency,
            "balance_cents": wallet.balance_cents,
            "credit_limit_cents": wallet.credit_limit_cents,
            "is_default": wallet.is_default,
            "color": wallet.color,
            "icon": wallet.icon,
            "institution": wallet.institution,
        }

    async def get_wallet(self, db: AsyncSession, user_id: int, wallet_id: int) -> dict:
        stmt = select(Wallet).where(
            Wallet.id == wallet_id,
            Wallet.user_id == user_id,
        )
        result = await db.execute(stmt)
        wallet = result.scalar_one_or_none()
        if not wallet:
            raise NotFoundError("Wallet not found")
        return {
            "id": wallet.id,
            "name": wallet.name,
            "type": wallet.type.value,
            "currency": wallet.currency,
            "balance_cents": wallet.balance_cents,
            "credit_limit_cents": wallet.credit_limit_cents,
            "status": wallet.status.value,
            "is_default": wallet.is_default,
            "color": wallet.color,
            "icon": wallet.icon,
            "institution": wallet.institution,
            "created_at": wallet.created_at.isoformat(),
        }

    async def update_wallet(
        self, db: AsyncSession, user_id: int, wallet_id: int, data: WalletUpdate
    ) -> dict:
        stmt = select(Wallet).where(
            Wallet.id == wallet_id,
            Wallet.user_id == user_id,
        )
        result = await db.execute(stmt)
        wallet = result.scalar_one_or_none()
        if not wallet:
            raise NotFoundError("Wallet not found")

        if data.is_default == True:
            stmt = select(Wallet).where(
                Wallet.user_id == user_id,
                Wallet.is_default == True,
                Wallet.id != wallet_id,
            )
            result = await db.execute(stmt)
            for w in result.scalars().all():
                w.is_default = False
            wallet.is_default = True

        if data.name is not None:
            wallet.name = data.name
        if data.balance_cents is not None:
            wallet.balance_cents = data.balance_cents
        if data.status is not None:
            wallet.status = data.status
        if data.color is not None:
            wallet.color = data.color
        if data.icon is not None:
            wallet.icon = data.icon

        await db.commit()
        await db.refresh(wallet)

        return {"message": "Wallet updated", "id": wallet.id}

    async def delete_wallet(
        self, db: AsyncSession, user_id: int, wallet_id: int
    ) -> dict:
        stmt = select(Wallet).where(
            Wallet.id == wallet_id,
            Wallet.user_id == user_id,
        )
        result = await db.execute(stmt)
        wallet = result.scalar_one_or_none()
        if not wallet:
            raise NotFoundError("Wallet not found")

        await db.delete(wallet)
        await db.commit()

        return {"message": "Wallet deleted"}
