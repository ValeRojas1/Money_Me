from datetime import date, datetime
from typing import Any

from sqlalchemy import asc, desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.errors import NotFoundError
from src.domain.models.movement import Movement, MovementStatus, MovementType


class TransactionUseCase:

    async def list_transactions(
        self,
        db: AsyncSession,
        user_id: int,
        search: str | None = None,
        category_id: int | None = None,
        type_filter: str | None = None,
        wallet_id: int | None = None,
        status_filter: str | None = None,
        start_date: str | None = None,
        end_date: str | None = None,
        sort_by: str = "date",
        sort_order: str = "desc",
        page: int = 1,
        limit: int = 20,
    ) -> dict:
        stmt = select(Movement).where(Movement.user_id == user_id)

        if search:
            stmt = stmt.where(Movement.description.ilike(f"%{search}%"))
        if category_id:
            stmt = stmt.where(Movement.category_id == category_id)
        if type_filter:
            stmt = stmt.where(Movement.type == MovementType(type_filter))
        if wallet_id:
            stmt = stmt.where(Movement.wallet_id == wallet_id)
        if status_filter:
            stmt = stmt.where(Movement.status == MovementStatus(status_filter))
        if start_date:
            stmt = stmt.where(Movement.transaction_date >= date.fromisoformat(start_date))
        if end_date:
            stmt = stmt.where(Movement.transaction_date <= date.fromisoformat(end_date))

        sort_columns = {
            "date": Movement.transaction_date,
            "amount": Movement.amount_cents,
            "description": Movement.description,
            "created": Movement.created_at,
        }
        col = sort_columns.get(sort_by, Movement.transaction_date)
        stmt = stmt.order_by(desc(col) if sort_order == "desc" else asc(col))

        total_stmt = select(Movement.id).where(Movement.user_id == user_id)
        if search:
            total_stmt = total_stmt.where(Movement.description.ilike(f"%{search}%"))
        total_result = await db.execute(total_stmt)
        total = len(total_result.scalars().all())

        offset = (page - 1) * limit
        stmt = stmt.offset(offset).limit(limit)
        result = await db.execute(stmt)
        movements = result.scalars().all()

        return {
            "items": [self._to_dict(m) for m in movements],
            "total": total,
            "page": page,
            "limit": limit,
            "pages": max(1, (total + limit - 1) // limit),
        }

    async def get_transaction(self, db: AsyncSession, user_id: int, movement_id: int) -> dict:
        stmt = select(Movement).where(
            Movement.id == movement_id, Movement.user_id == user_id,
        )
        result = await db.execute(stmt)
        movement = result.scalar_one_or_none()
        if not movement:
            raise NotFoundError("Transaction not found")
        return self._to_dict(movement)

    async def create_transaction(self, db: AsyncSession, user_id: int, data: dict) -> dict:
        movement = Movement(
            user_id=user_id,
            wallet_id=data.get("wallet_id", 1),
            category_id=data.get("category_id", 1),
            type=MovementType(data.get("type", "expense")),
            amount_cents=data.get("amount_cents", 0),
            currency=data.get("currency", "USD"),
            description=data.get("description", ""),
            notes=data.get("notes"),
            transaction_date=date.fromisoformat(data.get("transaction_date", str(date.today()))),
            tags=data.get("tags"),
            status=MovementStatus.COMPLETED,
        )
        db.add(movement)
        await db.commit()
        await db.refresh(movement)
        return self._to_dict(movement)

    async def update_transaction(
        self, db: AsyncSession, user_id: int, movement_id: int, data: dict
    ) -> dict:
        stmt = select(Movement).where(
            Movement.id == movement_id, Movement.user_id == user_id,
        )
        result = await db.execute(stmt)
        movement = result.scalar_one_or_none()
        if not movement:
            raise NotFoundError("Transaction not found")

        if "wallet_id" in data:
            movement.wallet_id = data["wallet_id"]
        if "category_id" in data:
            movement.category_id = data["category_id"]
        if "type" in data:
            movement.type = MovementType(data["type"])
        if "amount_cents" in data:
            movement.amount_cents = data["amount_cents"]
        if "currency" in data:
            movement.currency = data["currency"]
        if "description" in data:
            movement.description = data["description"]
        if "notes" in data:
            movement.notes = data["notes"]
        if "tags" in data:
            movement.tags = data["tags"]
        if "status" in data:
            movement.status = MovementStatus(data["status"])
        if "transaction_date" in data:
            movement.transaction_date = date.fromisoformat(data["transaction_date"])

        await db.commit()
        await db.refresh(movement)
        return self._to_dict(movement)

    async def delete_transaction(
        self, db: AsyncSession, user_id: int, movement_id: int
    ) -> dict:
        stmt = select(Movement).where(
            Movement.id == movement_id, Movement.user_id == user_id,
        )
        result = await db.execute(stmt)
        movement = result.scalar_one_or_none()
        if not movement:
            raise NotFoundError("Transaction not found")

        await db.delete(movement)
        await db.commit()
        return {"message": "Transaction deleted"}

    async def categorize_suggestion(
        self, db: AsyncSession, user_id: int, movement_id: int
    ) -> dict:
        stmt = select(Movement).where(
            Movement.id == movement_id, Movement.user_id == user_id,
        )
        result = await db.execute(stmt)
        movement = result.scalar_one_or_none()
        if not movement:
            raise NotFoundError("Transaction not found")

        from src.infrastructure.ocr.classifier import MovementClassifier
        classifier = MovementClassifier()
        suggestion = classifier.classify(movement.description or "", movement.amount_cents)

        return {
            "movement_id": movement_id,
            "suggested_category_id": None,
            "suggested_category_name": suggestion.get("category"),
            "confidence": suggestion.get("confidence"),
        }

    def _to_dict(self, m: Movement) -> dict:
        return {
            "id": m.id,
            "wallet_id": m.wallet_id,
            "category_id": m.category_id,
            "type": m.type.value,
            "amount_cents": m.amount_cents,
            "amount": round(m.amount_cents / 100, 2),
            "currency": m.currency,
            "description": m.description,
            "notes": m.notes,
            "transaction_date": m.transaction_date.isoformat(),
            "status": m.status.value,
            "is_recurring": m.is_recurring,
            "recurring_frequency": m.recurring_frequency,
            "tags": m.tags,
            "capture_id": m.capture_id,
            "created_at": m.created_at.isoformat() if m.created_at else None,
        }
