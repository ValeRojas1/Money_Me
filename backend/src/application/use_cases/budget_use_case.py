from datetime import date, datetime
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.errors import NotFoundError
from src.domain.models.budget import Budget, BudgetPeriod, BudgetStatus
from src.domain.models.movement import Movement, MovementStatus, MovementType
from src.domain.schemas.budget import BudgetCreate, BudgetUpdate


class BudgetUseCase:

    async def list_budgets(
        self, db: AsyncSession, user_id: int, month: str | None = None
    ) -> list[dict]:
        stmt = select(Budget).where(
            Budget.user_id == user_id,
            Budget.status == BudgetStatus.ACTIVE,
        ).order_by(Budget.created_at.desc())
        result = await db.execute(stmt)
        budgets = result.scalars().all()

        items = []
        for b in budgets:
            spent = await self._calculate_spent(db, user_id, b, month)
            percentage = round(spent / b.limit_cents * 100, 1) if b.limit_cents > 0 else 0
            items.append(self._to_dict(b, spent, percentage))
        return items

    async def create_budget(self, db: AsyncSession, user_id: int, data: BudgetCreate) -> dict:
        budget = Budget(
            user_id=user_id,
            category_id=data.category_id,
            name=data.name,
            period=data.period,
            limit_cents=data.limit_cents,
            currency=data.currency or "USD",
            start_date=data.start_date or date.today(),
            end_date=data.end_date,
            is_rollover=data.is_rollover or False,
            notify_at_percentage=data.notify_at_percentage or 80,
        )
        db.add(budget)
        await db.commit()
        await db.refresh(budget)
        return self._to_dict(budget, 0, 0)

    async def update_budget(
        self, db: AsyncSession, user_id: int, budget_id: int, data: BudgetUpdate
    ) -> dict:
        stmt = select(Budget).where(Budget.id == budget_id, Budget.user_id == user_id)
        result = await db.execute(stmt)
        budget = result.scalar_one_or_none()
        if not budget:
            raise NotFoundError("Budget not found")

        if data.name is not None:
            budget.name = data.name
        if data.limit_cents is not None:
            budget.limit_cents = data.limit_cents
        if data.period is not None:
            budget.period = BudgetPeriod(data.period)
        if data.start_date is not None:
            budget.start_date = data.start_date
        if data.end_date is not None:
            budget.end_date = data.end_date
        if data.is_rollover is not None:
            budget.is_rollover = data.is_rollover
        if data.notify_at_percentage is not None:
            budget.notify_at_percentage = data.notify_at_percentage
        if data.status is not None:
            budget.status = BudgetStatus(data.status)

        await db.commit()
        await db.refresh(budget)
        spent = await self._calculate_spent(db, user_id, budget, None)
        percentage = round(spent / budget.limit_cents * 100, 1) if budget.limit_cents > 0 else 0
        return self._to_dict(budget, spent, percentage)

    async def delete_budget(self, db: AsyncSession, user_id: int, budget_id: int) -> dict:
        stmt = select(Budget).where(Budget.id == budget_id, Budget.user_id == user_id)
        result = await db.execute(stmt)
        budget = result.scalar_one_or_none()
        if not budget:
            raise NotFoundError("Budget not found")

        await db.delete(budget)
        await db.commit()
        return {"message": "Budget deleted"}

    async def budget_alerts(self, db: AsyncSession, user_id: int) -> list[dict]:
        stmt = select(Budget).where(
            Budget.user_id == user_id,
            Budget.status == BudgetStatus.ACTIVE,
        )
        result = await db.execute(stmt)
        budgets = result.scalars().all()

        alerts = []
        for b in budgets:
            spent = await self._calculate_spent(db, user_id, b, None)
            percentage = round(spent / b.limit_cents * 100, 1) if b.limit_cents > 0 else 0
            if percentage >= b.notify_at_percentage:
                alerts.append({
                    "budget_id": b.id,
                    "name": b.name,
                    "limit_cents": b.limit_cents,
                    "limit": round(b.limit_cents / 100, 2),
                    "spent_cents": spent,
                    "spent": round(spent / 100, 2),
                    "percentage": percentage,
                    "severity": "warning" if percentage < 100 else "danger",
                    "message": (
                        f"You've used {percentage}% of your '{b.name}' budget"
                        if percentage < 100
                        else f"You've exceeded your '{b.name}' budget!"
                    ),
                })
        return alerts

    async def _calculate_spent(
        self, db: AsyncSession, user_id: int, budget: Budget, month: str | None = None
    ) -> int:
        stmt = select(func.coalesce(func.sum(Movement.amount_cents), 0)).where(
            Movement.user_id == user_id,
            Movement.category_id == budget.category_id,
            Movement.type == MovementType.EXPENSE,
            Movement.status == MovementStatus.COMPLETED,
        )

        if month:
            year, m = map(int, month.split("-"))
            from calendar import monthrange
            _, last_day = monthrange(year, m)
            stmt = stmt.where(
                Movement.transaction_date >= date(year, m, 1),
                Movement.transaction_date <= date(year, m, last_day),
            )
        elif budget.period == BudgetPeriod.MONTHLY:
            today = date.today()
            stmt = stmt.where(
                Movement.transaction_date >= date(today.year, today.month, 1),
                Movement.transaction_date <= today,
            )
        elif budget.period == BudgetPeriod.WEEKLY:
            today = date.today()
            monday = today - __import__("datetime").timedelta(days=today.weekday())
            stmt = stmt.where(Movement.transaction_date >= monday)
        elif budget.period == BudgetPeriod.QUARTERLY:
            today = date.today()
            q_start = date(today.year, ((today.month - 1) // 3) * 3 + 1, 1)
            stmt = stmt.where(Movement.transaction_date >= q_start)
        elif budget.period == BudgetPeriod.ANNUAL:
            stmt = stmt.where(
                Movement.transaction_date >= date(date.today().year, 1, 1)
            )
        elif budget.start_date:
            stmt = stmt.where(Movement.transaction_date >= budget.start_date)

        result = await db.execute(stmt)
        return int(result.scalar() or 0)

    def _to_dict(self, b: Budget, spent_cents: int, percentage: float) -> dict:
        return {
            "id": b.id,
            "category_id": b.category_id,
            "name": b.name,
            "period": b.period.value,
            "status": b.status.value,
            "limit_cents": b.limit_cents,
            "limit": round(b.limit_cents / 100, 2),
            "spent_cents": spent_cents,
            "spent": round(spent_cents / 100, 2),
            "percentage": percentage,
            "remaining_cents": b.limit_cents - spent_cents,
            "remaining": round((b.limit_cents - spent_cents) / 100, 2),
            "currency": b.currency,
            "start_date": b.start_date.isoformat(),
            "end_date": b.end_date.isoformat() if b.end_date else None,
            "notify_at_percentage": b.notify_at_percentage,
            "is_rollover": b.is_rollover,
        }
