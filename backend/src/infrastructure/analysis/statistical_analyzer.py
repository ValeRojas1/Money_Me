import math
from collections import defaultdict
from datetime import date, timedelta
from typing import Any

from src.domain.models.movement import Movement, MovementStatus, MovementType


class StatisticalAnalyzer:

    @staticmethod
    def descriptive_stats(values: list[float]) -> dict[str, float]:
        if not values:
            return {"mean": 0, "median": 0, "std": 0, "min": 0, "max": 0, "count": 0}

        n = len(values)
        sorted_v = sorted(values)
        mean = sum(values) / n

        if n % 2 == 0:
            median = (sorted_v[n // 2 - 1] + sorted_v[n // 2]) / 2
        else:
            median = sorted_v[n // 2]

        variance = sum((x - mean) ** 2 for x in values) / n
        std = math.sqrt(variance)

        return {
            "mean": round(mean, 2),
            "median": round(median, 2),
            "std": round(std, 2),
            "min": round(min(values), 2),
            "max": round(max(values), 2),
            "count": n,
        }

    @staticmethod
    def spending_by_category(
        movements: list[Movement],
    ) -> list[dict[str, Any]]:
        by_category: dict[int, list[int]] = defaultdict(list)
        for m in movements:
            if m.type == MovementType.EXPENSE and m.status == MovementStatus.COMPLETED:
                by_category[m.category_id].append(m.amount_cents)

        result = []
        for cat_id, amounts in by_category.items():
            amounts_f = [a / 100 for a in amounts]
            stats = StatisticalAnalyzer.descriptive_stats(amounts_f)
            result.append({
                "category_id": cat_id,
                "total_cents": sum(amounts),
                "total": round(sum(amounts) / 100, 2),
                "stats": stats,
            })

        return sorted(result, key=lambda x: x["total_cents"], reverse=True)

    @staticmethod
    def detect_anomalies(
        movements: list[Movement],
        z_score_threshold: float = 2.0,
    ) -> list[dict[str, Any]]:
        expenses = [
            m for m in movements
            if m.type == MovementType.EXPENSE
            and m.status == MovementStatus.COMPLETED
        ]

        if len(expenses) < 3:
            return []

        amounts = [m.amount_cents / 100 for m in expenses]
        n = len(amounts)
        mean = sum(amounts) / n
        variance = sum((x - mean) ** 2 for x in amounts) / n
        std = math.sqrt(variance)

        if std == 0:
            return []

        anomalies = []
        for m in expenses:
            x = m.amount_cents / 100
            z_score = (x - mean) / std
            if abs(z_score) > z_score_threshold:
                anomalies.append({
                    "movement_id": m.id,
                    "amount": round(x, 2),
                    "amount_cents": m.amount_cents,
                    "date": m.transaction_date.isoformat(),
                    "description": m.description,
                    "category_id": m.category_id,
                    "z_score": round(z_score, 2),
                    "mean": round(mean, 2),
                    "std": round(std, 2),
                })

        return sorted(anomalies, key=lambda a: abs(a["z_score"]), reverse=True)

    @staticmethod
    def recurring_patterns(
        movements: list[Movement],
    ) -> list[dict[str, Any]]:
        today = date.today()
        patterns = []

        for m in movements:
            if m.is_recurring and m.status == MovementStatus.COMPLETED:
                patterns.append({
                    "movement_id": m.id,
                    "amount_cents": m.amount_cents,
                    "amount": round(m.amount_cents / 100, 2),
                    "description": m.description,
                    "category_id": m.category_id,
                    "frequency": m.recurring_frequency,
                    "next_date": StatisticalAnalyzer._estimate_next_date(
                        m.transaction_date, m.recurring_frequency
                    ),
                })

        same_amount: dict[str, list[int]] = defaultdict(list)
        for m in movements:
            if m.status == MovementStatus.COMPLETED:
                key = f"{m.amount_cents}_{m.category_id}"
                same_amount[key].append(m.amount_cents)

        for key, amounts in same_amount.items():
            if len(amounts) >= 3:
                cat_id = int(key.split("_")[1])
                amount_cents = int(key.split("_")[0])
                same_desc = [
                    m for m in movements
                    if m.amount_cents == amount_cents
                    and m.category_id == cat_id
                    and m.status == MovementStatus.COMPLETED
                ]
                if len(same_desc) >= 3:
                    descs = [m.description for m in same_desc if m.description]
                    most_common = max(set(descs), key=descs.count) if descs else ""
                    patterns.append({
                        "movement_id": same_desc[0].id,
                        "amount_cents": amount_cents,
                        "amount": round(amount_cents / 100, 2),
                        "description": most_common,
                        "category_id": cat_id,
                        "frequency": "detected_recurring",
                        "next_date": today.isoformat(),
                    })

        return patterns

    @staticmethod
    def _estimate_next_date(last_date: date, frequency: str | None) -> str:
        from dateutil.relativedelta import relativedelta
        if frequency == "monthly":
            return (last_date + relativedelta(months=1)).isoformat()
        elif frequency == "weekly":
            return (last_date + timedelta(weeks=1)).isoformat()
        elif frequency == "biweekly":
            return (last_date + timedelta(weeks=2)).isoformat()
        elif frequency == "yearly":
            return (last_date + relativedelta(years=1)).isoformat()
        return last_date.isoformat()
