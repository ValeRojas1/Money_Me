from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models.movement import Movement, MovementStatus
from src.infrastructure.analysis.trend_calculator import TrendCalculator
from src.infrastructure.analysis.statistical_analyzer import StatisticalAnalyzer
from src.domain.services.alert_generator import AlertGenerator


class AnalysisUseCase:

    def __init__(
        self,
        trend_calc: TrendCalculator | None = None,
        stats: StatisticalAnalyzer | None = None,
        alert_gen: AlertGenerator | None = None,
    ) -> None:
        self._trend_calc = trend_calc or TrendCalculator()
        self._stats = stats or StatisticalAnalyzer()
        self._alert_gen = alert_gen or AlertGenerator()

    async def get_movements(self, db: AsyncSession, user_id: int) -> list[Movement]:
        stmt = select(Movement).where(
            Movement.user_id == user_id,
            Movement.status == MovementStatus.COMPLETED,
        ).order_by(Movement.transaction_date.desc())
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def spending_analysis(self, db: AsyncSession, user_id: int) -> dict:
        movements = await self.get_movements(db, user_id)

        return {
            "income_vs_expenses": self._trend_calc.income_vs_expenses(movements),
            "monthly_comparison": self._trend_calc.monthly_comparison(movements),
            "category_breakdown": self._trend_calc.category_trend(movements),
            "spending_trend": self._trend_calc.spending_trend(movements),
            "frequency": self._trend_calc.movement_frequency(movements),
            "weekday_distribution": self._trend_calc.weekday_distribution(movements),
        }

    async def category_analysis(self, db: AsyncSession, user_id: int) -> list[dict]:
        movements = await self.get_movements(db, user_id)
        return self._stats.spending_by_category(movements)

    async def trends(self, db: AsyncSession, user_id: int) -> dict:
        movements = await self.get_movements(db, user_id)

        return {
            "monthly_trend": self._trend_calc.spending_trend(movements, months=12),
            "category_trends": self._trend_calc.category_trend(movements, months=6),
            "frequency": self._trend_calc.movement_frequency(movements),
            "recurring_patterns": self._stats.recurring_patterns(movements),
        }

    async def generate_alerts(
        self,
        db: AsyncSession,
        user_id: int,
        budget_alerts: list[dict] | None = None,
    ) -> list[dict]:
        movements = await self.get_movements(db, user_id)
        return self._alert_gen.generate_alerts(movements, budget_alerts)
