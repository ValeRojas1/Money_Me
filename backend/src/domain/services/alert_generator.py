from datetime import date, timedelta
from typing import Any

from src.domain.models.alert import AlertSeverity, AlertType
from src.domain.models.movement import Movement, MovementStatus, MovementType
from src.infrastructure.analysis.statistical_analyzer import StatisticalAnalyzer


class AlertGenerator:

    def __init__(self, analyzer: StatisticalAnalyzer | None = None) -> None:
        self._analyzer = analyzer or StatisticalAnalyzer()

    def generate_alerts(
        self,
        movements: list[Movement],
        budget_alerts: list[dict] | None = None,
    ) -> list[dict[str, Any]]:
        alerts: list[dict[str, Any]] = []

        alerts.extend(self._check_unusual_spending(movements))
        alerts.extend(self._check_large_transactions(movements))
        alerts.extend(self._check_low_balance_pattern(movements))

        if budget_alerts:
            for ba in budget_alerts:
                alerts.append(ba)

        return alerts

    def _check_unusual_spending(self, movements: list[Movement]) -> list[dict[str, Any]]:
        alerts: list[dict[str, Any]] = []
        anomalies = self._analyzer.detect_anomalies(movements, z_score_threshold=2.0)

        for a in anomalies[:5]:
            severity = (
                AlertSeverity.CRITICAL
                if abs(a["z_score"]) > 3.0
                else AlertSeverity.WARNING
            )
            alerts.append({
                "type": AlertType.UNUSUAL_ACTIVITY.value,
                "severity": severity.value,
                "title": "Unusual spending detected",
                "message": (
                    f"Movement of ${a['amount']:.2f} in '{a['description']}' "
                    f"is {abs(a['z_score']):.1f} std deviations from your average "
                    f"(avg: ${a['mean']:.2f})"
                ),
                "reference_type": "movement",
                "reference_id": a["movement_id"],
                "threshold_value": a["mean"] + 2 * a["std"],
                "current_value": a["amount"],
            })

        return alerts

    def _check_large_transactions(self, movements: list[Movement]) -> list[dict[str, Any]]:
        alerts: list[dict[str, Any]] = []
        today = date.today()
        week_ago = today - timedelta(days=7)

        recent = [
            m for m in movements
            if m.transaction_date >= week_ago
            and m.status == MovementStatus.COMPLETED
        ]

        amounts = [m.amount_cents / 100 for m in recent]
        if not amounts:
            return alerts

        avg = sum(amounts) / len(amounts)
        threshold = avg * 5

        for m in recent:
            amt = m.amount_cents / 100
            if amt >= threshold and amt >= 500:
                alerts.append({
                    "type": AlertType.LARGE_TRANSACTION.value,
                    "severity": AlertSeverity.WARNING.value,
                    "title": "Large transaction detected",
                    "message": (
                        f"Transaction of ${amt:.2f} in '{m.description}' "
                        f"is significantly above your average"
                    ),
                    "reference_type": "movement",
                    "reference_id": m.id,
                    "threshold_value": round(threshold, 2),
                    "current_value": round(amt, 2),
                })

        return alerts

    def _check_low_balance_pattern(self, movements: list[Movement]) -> list[dict[str, Any]]:
        alerts: list[dict[str, Any]] = []
        today = date.today()
        three_months_ago = today - timedelta(days=90)

        expenses = [
            m.amount_cents / 100
            for m in movements
            if m.type == MovementType.EXPENSE
            and m.status == MovementStatus.COMPLETED
            and m.transaction_date >= three_months_ago
        ]

        incomes = [
            m.amount_cents / 100
            for m in movements
            if m.type == MovementType.INCOME
            and m.status == MovementStatus.COMPLETED
            and m.transaction_date >= three_months_ago
        ]

        total_expenses = sum(expenses)
        total_income = sum(incomes)

        if total_income > 0 and total_expenses > total_income * 0.9:
            alerts.append({
                "type": AlertType.LOW_BALANCE.value,
                "severity": AlertSeverity.WARNING.value,
                "title": "Spending exceeds 90% of income",
                "message": (
                    f"Your expenses (${total_expenses:.2f}) represent "
                    f"{total_expenses / total_income * 100:.1f}% of your "
                    f"income (${total_income:.2f}) in the last 3 months"
                ),
                "reference_type": "trend",
                "reference_id": None,
                "threshold_value": round(total_income * 0.9, 2),
                "current_value": round(total_expenses, 2),
            })

        return alerts
