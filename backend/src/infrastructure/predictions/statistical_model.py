import math
from collections import defaultdict
from datetime import date, timedelta
from typing import Any

from src.domain.models.movement import Movement, MovementStatus, MovementType


class StatisticalModel:

    @staticmethod
    def linear_regression(x_vals: list[float], y_vals: list[float]) -> dict:
        n = len(x_vals)
        if n < 2:
            return {"slope": 0, "intercept": 0, "r_squared": 0, "prediction": 0}

        sum_x = sum(x_vals)
        sum_y = sum(y_vals)
        sum_xy = sum(x * y for x, y in zip(x_vals, y_vals))
        sum_x2 = sum(x ** 2 for x in x_vals)

        denom = n * sum_x2 - sum_x ** 2
        if denom == 0:
            return {"slope": 0, "intercept": sum_y / n, "r_squared": 0, "prediction": sum_y / n}

        slope = (n * sum_xy - sum_x * sum_y) / denom
        intercept = (sum_y - slope * sum_x) / n

        y_pred = [slope * x + intercept for x in x_vals]
        ss_res = sum((y - yp) ** 2 for y, yp in zip(y_vals, y_pred))
        ss_tot = sum((y - sum_y / n) ** 2 for y in y_vals)
        r_squared = 1 - ss_res / ss_tot if ss_tot > 0 else 0

        next_x = n
        prediction = slope * next_x + intercept

        return {
            "slope": round(slope, 4),
            "intercept": round(intercept, 2),
            "r_squared": round(r_squared, 4),
            "prediction": round(prediction, 2),
        }

    @staticmethod
    def weighted_moving_average(values: list[float], weights: list[float] | None = None) -> float:
        if not values:
            return 0.0
        if weights is None:
            n = len(values)
            weights = [(i + 1) / (n * (n + 1) / 2) for i in range(n)]
        if len(weights) != len(values):
            weights = [1 / len(values)] * len(values)
        return sum(v * w for v, w in zip(values, weights))

    @staticmethod
    def predict_next_month_spending(
        movements: list[Movement],
        months_history: int = 6,
    ) -> dict:
        today = date.today()
        cutoff = today - timedelta(days=months_history * 31)

        expenses = [
            m for m in movements
            if m.type == MovementType.EXPENSE
            and m.status == MovementStatus.COMPLETED
            and m.transaction_date >= cutoff
        ]

        monthly_totals: dict[str, float] = defaultdict(float)
        for m in expenses:
            key = m.transaction_date.strftime("%Y-%m")
            monthly_totals[key] += m.amount_cents / 100

        months = sorted(monthly_totals.keys())
        if len(months) < 2:
            avg = sum(monthly_totals.values()) / max(len(monthly_totals), 1)
            return {
                "predicted_amount_cents": round(avg * 100),
                "predicted_amount": round(avg, 2),
                "confidence": 0.3,
                "method": "average",
            }

        values = [monthly_totals[m] for m in months]
        x_vals = list(range(len(values)))

        lr = StatisticalModel.linear_regression(x_vals, values)

        recent_3 = values[-3:] if len(values) >= 3 else values
        wma = StatisticalModel.weighted_moving_average(recent_3)

        prediction = (lr["prediction"] * 0.4 + wma * 0.6)

        residuals = [abs(values[i] - (lr["slope"] * i + lr["intercept"])) for i in range(len(values))]
        mae = sum(residuals) / len(residuals) if residuals else 0
        rel_error = mae / max(abs(prediction), 1)
        confidence = max(0.3, min(0.95, 1.0 - rel_error))

        return {
            "predicted_amount_cents": round(prediction * 100),
            "predicted_amount": round(prediction, 2),
            "confidence": round(confidence, 2),
            "method": "hybrid",
            "linear_trend_cents": round(lr["prediction"] * 100),
            "wma_cents": round(wma * 100),
            "r_squared": lr["r_squared"],
            "monthly_data": [
                {"month": m, "total_cents": round(monthly_totals[m] * 100)}
                for m in months[-12:]
            ],
        }

    @staticmethod
    def predict_category_spending(
        movements: list[Movement],
        category_id: int,
        months_history: int = 6,
    ) -> dict:
        today = date.today()
        cutoff = today - timedelta(days=months_history * 31)

        cat_expenses = [
            m for m in movements
            if m.type == MovementType.EXPENSE
            and m.status == MovementStatus.COMPLETED
            and m.category_id == category_id
            and m.transaction_date >= cutoff
        ]

        monthly: dict[str, float] = defaultdict(float)
        for m in cat_expenses:
            key = m.transaction_date.strftime("%Y-%m")
            monthly[key] += m.amount_cents / 100

        months = sorted(monthly.keys())
        if not months:
            return {
                "category_id": category_id,
                "predicted_amount_cents": 0,
                "predicted_amount": 0,
                "confidence": 0,
            }

        values = [monthly[m] for m in months]
        avg = sum(values) / len(values)

        x_vals = list(range(len(values)))
        lr = StatisticalModel.linear_regression(x_vals, values)

        prediction = (lr["prediction"] * 0.3 + avg * 0.7)
        confidence = min(0.5 + len(months) * 0.05, 0.9) if len(values) >= 2 else 0.3

        return {
            "category_id": category_id,
            "predicted_amount_cents": round(prediction * 100),
            "predicted_amount": round(prediction, 2),
            "confidence": round(confidence, 2),
            "historical_avg_cents": round(avg * 100),
            "trend_direction": "increasing" if lr["slope"] > 1 else "decreasing" if lr["slope"] < -1 else "stable",
        }

    @staticmethod
    def predict_income(
        movements: list[Movement],
        months_history: int = 6,
    ) -> dict:
        today = date.today()
        cutoff = today - timedelta(days=months_history * 31)

        incomes = [
            m for m in movements
            if m.type == MovementType.INCOME
            and m.status == MovementStatus.COMPLETED
            and m.transaction_date >= cutoff
        ]

        if not incomes:
            return {
                "predicted_income_cents": 0,
                "predicted_income": 0,
                "confidence": 0,
                "is_regular": False,
            }

        monthly: dict[str, list[float]] = defaultdict(list)
        for m in incomes:
            key = m.transaction_date.strftime("%Y-%m")
            monthly[key].append(m.amount_cents / 100)

        monthly_totals = {k: sum(v) for k, v in monthly.items()}
        months = sorted(monthly_totals.keys())
        values = [monthly_totals[m] for m in months]

        avg = sum(values) / len(values) if values else 0

        monthly_counts = [len(monthly[m]) for m in months]
        avg_count = sum(monthly_counts) / len(monthly_counts) if monthly_counts else 0
        is_regular = 1 <= avg_count <= 4

        confidence = min(0.3 + len(months) * 0.08, 0.95) if is_regular else 0.4

        return {
            "predicted_income_cents": round(avg * 100),
            "predicted_income": round(avg, 2),
            "confidence": round(confidence, 2),
            "is_regular": is_regular,
            "avg_monthly_count": round(avg_count, 1),
            "monthly_data": [
                {"month": m, "total_cents": round(monthly_totals[m] * 100)}
                for m in months[-12:]
            ],
        }

    @staticmethod
    def predict_wallet_balance(
        movements: list[Movement],
        wallet_id: int,
        current_balance_cents: int,
    ) -> dict:
        today = date.today()
        three_months_ago = today - timedelta(days=90)

        wallet_mov = [
            m for m in movements
            if m.wallet_id == wallet_id
            and m.status == MovementStatus.COMPLETED
            and m.transaction_date >= three_months_ago
        ]

        if not wallet_mov:
            return {
                "wallet_id": wallet_id,
                "current_balance_cents": current_balance_cents,
                "projected_30d_cents": current_balance_cents,
                "projected_balance_cents": current_balance_cents,
                "monthly_net_cents": 0,
            }

        daily_net: dict[str, int] = defaultdict(int)
        for m in wallet_mov:
            key = m.transaction_date.isoformat()
            if m.type == MovementType.INCOME:
                daily_net[key] += m.amount_cents
            elif m.type == MovementType.EXPENSE:
                daily_net[key] -= m.amount_cents

        total_net = sum(daily_net.values())
        avg_daily_net = total_net / max(len(daily_net), 1)
        monthly_net = round(avg_daily_net * 30)

        return {
            "wallet_id": wallet_id,
            "current_balance_cents": current_balance_cents,
            "current_balance": round(current_balance_cents / 100, 2),
            "projected_30d_cents": current_balance_cents + monthly_net,
            "projected_balance": round((current_balance_cents + monthly_net) / 100, 2),
            "monthly_net_cents": monthly_net,
            "monthly_net": round(monthly_net / 100, 2),
            "avg_daily_net_cents": round(avg_daily_net * 100),
        }

    @staticmethod
    def savings_goal_projection(
        goal_amount_cents: int,
        current_savings_cents: int,
        movements: list[Movement],
    ) -> dict:
        remaining = goal_amount_cents - current_savings_cents
        if remaining <= 0:
            return {
                "goal_amount_cents": goal_amount_cents,
                "current_savings_cents": current_savings_cents,
                "remaining_cents": 0,
                "goal_achieved": True,
                "estimated_months": 0,
                "estimated_date": date.today().isoformat(),
            }

        today = date.today()
        six_months_ago = today - timedelta(days=180)
        incomes = [
            m for m in movements
            if m.type == MovementType.INCOME
            and m.status == MovementStatus.COMPLETED
            and m.transaction_date >= six_months_ago
        ]

        expenses = [
            m for m in movements
            if m.type == MovementType.EXPENSE
            and m.status == MovementStatus.COMPLETED
            and m.transaction_date >= six_months_ago
        ]

        monthly_income = sum(m.amount_cents for m in incomes) / 6 if incomes else 0
        monthly_expense = sum(m.amount_cents for m in expenses) / 6 if expenses else 0
        monthly_savings = monthly_income - monthly_expense

        if monthly_savings <= 0:
            monthly_savings = max(remaining * 0.05, 1)

        months_needed = math.ceil(remaining / monthly_savings)
        estimated_date = today + timedelta(days=months_needed * 30)

        return {
            "goal_amount_cents": goal_amount_cents,
            "current_savings_cents": current_savings_cents,
            "remaining_cents": remaining,
            "goal_achieved": False,
            "estimated_monthly_savings_cents": round(monthly_savings),
            "estimated_months": months_needed,
            "estimated_date": estimated_date.isoformat(),
        }
