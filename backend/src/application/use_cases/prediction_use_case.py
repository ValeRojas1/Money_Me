from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models.movement import Movement, MovementStatus
from src.infrastructure.predictions.statistical_model import StatisticalModel


class PredictionUseCase:

    def __init__(self, model: StatisticalModel | None = None) -> None:
        self._model = model or StatisticalModel()

    async def get_completed_movements(
        self, db: AsyncSession, user_id: int
    ) -> list[Movement]:
        stmt = select(Movement).where(
            Movement.user_id == user_id,
            Movement.status == MovementStatus.COMPLETED,
        ).order_by(Movement.transaction_date.asc())
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def predict_monthly_spending(
        self, db: AsyncSession, user_id: int
    ) -> dict:
        movements = await self.get_completed_movements(db, user_id)
        return self._model.predict_next_month_spending(movements)

    async def predict_category_spending(
        self, db: AsyncSession, user_id: int, category_id: int
    ) -> dict:
        movements = await self.get_completed_movements(db, user_id)
        return self._model.predict_category_spending(movements, category_id)

    async def predict_income(
        self, db: AsyncSession, user_id: int
    ) -> dict:
        movements = await self.get_completed_movements(db, user_id)
        return self._model.predict_income(movements)

    async def predict_wallet_balance(
        self,
        db: AsyncSession,
        user_id: int,
        wallet_id: int,
        current_balance_cents: int,
    ) -> dict:
        movements = await self.get_completed_movements(db, user_id)
        return self._model.predict_wallet_balance(movements, wallet_id, current_balance_cents)

    async def savings_goal_projection(
        self,
        db: AsyncSession,
        user_id: int,
        goal_amount_cents: int,
        current_savings_cents: int,
    ) -> dict:
        movements = await self.get_completed_movements(db, user_id)
        return self._model.savings_goal_projection(
            goal_amount_cents, current_savings_cents, movements
        )

    async def budget_recommendations(
        self,
        db: AsyncSession,
        user_id: int,
        budgets: list[dict] | None = None,
    ) -> list[dict]:
        movements = await self.get_completed_movements(db, user_id)
        from src.domain.services.financial_advisor import FinancialAdvisor
        advisor = FinancialAdvisor()
        tips = advisor.generate_tips(movements, budgets)

        categories = set(m.category_id for m in movements if m.type.name == "EXPENSE")
        predictions = []
        for cat_id in list(categories)[:5]:
            pred = self._model.predict_category_spending(movements, cat_id)
            predictions.append(pred)

        return {
            "tips": tips,
            "category_predictions": predictions,
        }
