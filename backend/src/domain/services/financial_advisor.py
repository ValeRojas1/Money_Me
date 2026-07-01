from collections import defaultdict
from datetime import date, timedelta
from typing import Any

from src.domain.models.movement import Movement, MovementStatus, MovementType


class FinancialAdvisor:

    def generate_tips(
        self,
        movements: list[Movement],
        budgets: list[dict] | None = None,
    ) -> list[dict[str, Any]]:
        tips: list[dict[str, Any]] = []

        tips.extend(self._savings_tip(movements))
        tips.extend(self._category_diversification_tip(movements))
        tips.extend(self._recurring_review_tip(movements))

        if budgets:
            tips.extend(self._budget_tips(budgets))

        return tips

    def _savings_tip(self, movements: list[Movement]) -> list[dict[str, Any]]:
        today = date.today()
        three_months_ago = today - timedelta(days=90)

        incomes = [
            m.amount_cents / 100
            for m in movements
            if m.type == MovementType.INCOME
            and m.status == MovementStatus.COMPLETED
            and m.transaction_date >= three_months_ago
        ]

        expenses = [
            m.amount_cents / 100
            for m in movements
            if m.type == MovementType.EXPENSE
            and m.status == MovementStatus.COMPLETED
            and m.transaction_date >= three_months_ago
        ]

        if not incomes or not expenses:
            return []

        avg_income = sum(incomes) / len(incomes)
        avg_expenses = sum(expenses) / len(expenses)
        savings_rate = (avg_income - avg_expenses) / max(avg_income, 1) * 100

        if savings_rate < 10:
            return [{
                "type": "savings_rate",
                "priority": "high",
                "icon": "savings",
                "title": "Increase your savings rate",
                "message": (
                    f"Your savings rate is {savings_rate:.1f}%. "
                    f"Try to save at least 20% of your income. "
                    f"Consider reducing discretionary expenses."
                ),
            }]
        elif savings_rate < 20:
            return [{
                "type": "savings_rate",
                "priority": "medium",
                "icon": "savings",
                "title": "Good savings rate",
                "message": (
                    f"Your savings rate is {savings_rate:.1f}%. "
                    f"Great progress! Aim for 20% to build a strong emergency fund."
                ),
            }]

        return [{
            "type": "savings_rate",
            "priority": "low",
            "icon": "savings",
            "title": "Excellent savings rate",
            "message": (
                f"Your savings rate is {savings_rate:.1f}%. "
                f"You are on track for strong financial health!"
            ),
        }]

    def _category_diversification_tip(self, movements: list[Movement]) -> list[dict[str, Any]]:
        today = date.today()
        month_ago = today - timedelta(days=30)

        expenses = [
            m for m in movements
            if m.type == MovementType.EXPENSE
            and m.status == MovementStatus.COMPLETED
            and m.transaction_date >= month_ago
        ]

        if not expenses:
            return []

        by_category: dict[int, int] = defaultdict(int)
        for m in expenses:
            by_category[m.category_id] += m.amount_cents

        total = sum(by_category.values())
        if total == 0:
            return []

        dominant = max(by_category, key=by_category.get)
        dominant_pct = by_category[dominant] / total * 100

        if dominant_pct > 50:
            return [{
                "type": "category_concentration",
                "priority": "medium",
                "icon": "category",
                "title": "High spending concentration",
                "message": (
                    f"Category {dominant} represents {dominant_pct:.0f}% of your "
                    f"monthly spending. Diversifying could help you find savings."
                ),
            }]
        return []

    def _recurring_review_tip(self, movements: list[Movement]) -> list[dict[str, Any]]:
        recurring = [m for m in movements if m.is_recurring and m.status == MovementStatus.COMPLETED]

        if len(recurring) < 2:
            return []

        total_monthly = sum(
            m.amount_cents for m in recurring
        ) / 100

        if total_monthly > 500:
            return [{
                "type": "recurring_review",
                "priority": "low",
                "icon": "subscriptions",
                "title": "Review your subscriptions",
                "message": (
                    f"You have {len(recurring)} recurring payments totaling "
                    f"${total_monthly:.2f}/month. Review if all are still needed."
                ),
            }]
        return []

    def _budget_tips(self, budgets: list[dict]) -> list[dict[str, Any]]:
        tips: list[dict[str, Any]] = []
        for b in budgets:
            spent_pct = b.get("spent_cents", 0) / max(b.get("limit_cents", 1), 1) * 100
            if spent_pct > 90:
                tips.append({
                    "type": "budget_overspend",
                    "priority": "high",
                    "icon": "warning",
                    "title": f"Budget nearly exceeded: {b.get('name', '')}",
                    "message": (
                        f"You've used {spent_pct:.0f}% of your {b.get('name', '')} budget "
                        f"(${b.get('spent_cents', 0) / 100:.2f} of ${b.get('limit_cents', 0) / 100:.2f})."
                    ),
                })
            elif spent_pct < 50 and b.get("period") == "monthly":
                tips.append({
                    "type": "budget_underspend",
                    "priority": "low",
                    "icon": "check_circle",
                    "title": f"Under budget: {b.get('name', '')}",
                    "message": (
                        f"Great job! You've only used {spent_pct:.0f}% of your "
                        f"{b.get('name', '')} budget this month."
                    ),
                })
        return tips
