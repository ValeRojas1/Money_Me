from collections import Counter, defaultdict
from datetime import date, datetime, timedelta

from src.domain.models.movement import Movement, MovementStatus, MovementType


class TrendCalculator:

    @staticmethod
    def spending_trend(
        movements: list[Movement],
        months: int = 6,
    ) -> list[dict]:
        today = date.today()
        cutoff = today - timedelta(days=months * 30)
        filtered = [
            m for m in movements
            if m.transaction_date >= cutoff
            and m.type == MovementType.EXPENSE
            and m.status == MovementStatus.COMPLETED
        ]

        monthly: dict[str, int] = defaultdict(int)
        for m in filtered:
            key = m.transaction_date.strftime("%Y-%m")
            monthly[key] += m.amount_cents

        result = []
        for i in range(months):
            dt = today.replace(day=1) - timedelta(days=30 * (months - 1 - i))
            key = dt.strftime("%Y-%m")
            result.append({
                "month": key,
                "total_cents": monthly.get(key, 0),
                "total": round(monthly.get(key, 0) / 100, 2),
            })

        return result

    @staticmethod
    def category_trend(
        movements: list[Movement],
        months: int = 3,
    ) -> list[dict]:
        today = date.today()
        cutoff = today - timedelta(days=months * 30)
        filtered = [
            m for m in movements
            if m.transaction_date >= cutoff
            and m.type == MovementType.EXPENSE
            and m.status == MovementStatus.COMPLETED
        ]

        cats: dict[int, dict] = {}
        for m in filtered:
            if m.category_id not in cats:
                cats[m.category_id] = {
                    "category_id": m.category_id,
                    "total_cents": 0,
                    "count": 0,
                    "months": set(),
                }
            cats[m.category_id]["total_cents"] += m.amount_cents
            cats[m.category_id]["count"] += 1
            cats[m.category_id]["months"].add(m.transaction_date.strftime("%Y-%m"))

        return [
            {
                "category_id": v["category_id"],
                "total_cents": v["total_cents"],
                "total": round(v["total_cents"] / 100, 2),
                "count": v["count"],
                "active_months": len(v["months"]),
                "avg_per_month": round(
                    v["total_cents"] / max(len(v["months"]), 1) / 100, 2
                ),
            }
            for v in sorted(cats.values(), key=lambda x: x["total_cents"], reverse=True)
        ]

    @staticmethod
    def movement_frequency(
        movements: list[Movement],
        days: int = 90,
    ) -> dict:
        today = date.today()
        cutoff = today - timedelta(days=days)
        filtered = [
            m for m in movements
            if m.transaction_date >= cutoff
            and m.status == MovementStatus.COMPLETED
        ]

        if not filtered:
            return {"avg_per_day": 0, "avg_per_week": 0, "avg_per_month": 0, "total": 0}

        expense_count = sum(1 for m in filtered if m.type == MovementType.EXPENSE)
        income_count = sum(1 for m in filtered if m.type == MovementType.INCOME)

        return {
            "avg_per_day": round(len(filtered) / max(days, 1), 2),
            "avg_per_week": round(len(filtered) / max(days / 7, 1), 2),
            "avg_per_month": round(len(filtered) / max(days / 30, 1), 2),
            "total": len(filtered),
            "expense_count": expense_count,
            "income_count": income_count,
        }

    @staticmethod
    def monthly_comparison(
        movements: list[Movement],
    ) -> list[dict]:
        today = date.today()
        current_month = today.strftime("%Y-%m")

        monthly: dict[str, dict] = defaultdict(
            lambda: {"income_cents": 0, "expense_cents": 0, "count": 0}
        )

        for m in movements:
            if m.status != MovementStatus.COMPLETED:
                continue
            key = m.transaction_date.strftime("%Y-%m")
            if key > current_month:
                continue

            if m.type == MovementType.INCOME:
                monthly[key]["income_cents"] += m.amount_cents
            elif m.type == MovementType.EXPENSE:
                monthly[key]["expense_cents"] += m.amount_cents
            monthly[key]["count"] += 1

        return [
            {
                "month": k,
                "income_cents": v["income_cents"],
                "expense_cents": v["expense_cents"],
                "income": round(v["income_cents"] / 100, 2),
                "expenses": round(v["expense_cents"] / 100, 2),
                "balance_cents": v["income_cents"] - v["expense_cents"],
                "balance": round((v["income_cents"] - v["expense_cents"]) / 100, 2),
                "count": v["count"],
            }
            for k, v in sorted(monthly.items(), reverse=True)[:12]
        ]

    @staticmethod
    def weekday_distribution(
        movements: list[Movement],
    ) -> dict[str, int]:
        days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        counts: dict[str, int] = {d: 0 for d in days}
        for m in movements:
            if m.status == MovementStatus.COMPLETED:
                day_name = m.transaction_date.strftime("%A")
                if day_name in counts:
                    counts[day_name] += 1
        return counts

    @staticmethod
    def income_vs_expenses(
        movements: list[Movement],
        months: int = 6,
    ) -> dict:
        today = date.today()
        cutoff = today - timedelta(days=months * 30)
        filtered = [
            m for m in movements
            if m.transaction_date >= cutoff and m.status == MovementStatus.COMPLETED
        ]

        income_cents = sum(m.amount_cents for m in filtered if m.type == MovementType.INCOME)
        expense_cents = sum(m.amount_cents for m in filtered if m.type == MovementType.EXPENSE)

        return {
            "total_income_cents": income_cents,
            "total_expense_cents": expense_cents,
            "total_income": round(income_cents / 100, 2),
            "total_expenses": round(expense_cents / 100, 2),
            "balance_cents": income_cents - expense_cents,
            "balance": round((income_cents - expense_cents) / 100, 2),
            "expense_ratio": round(expense_cents / max(income_cents, 1) * 100, 2),
        }
