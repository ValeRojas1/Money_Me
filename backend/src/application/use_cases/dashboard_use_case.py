from calendar import monthrange
from collections import defaultdict
from datetime import date, datetime, timedelta

from sqlalchemy import case, extract, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models.movement import Movement, MovementStatus, MovementType


class DashboardUseCase:

    async def summary(self, db: AsyncSession, user_id: int, month: str | None = None) -> dict:
        if month:
            year, m = map(int, month.split("-"))
        else:
            today = date.today()
            year, m = today.year, today.month

        _, last_day = monthrange(year, m)
        start = date(year, m, 1)
        end = date(year, m, last_day)

        stmt = select(
            func.coalesce(
                func.sum(case((Movement.type == MovementType.INCOME, Movement.amount_cents), else_=0)),
                0,
            ),
            func.coalesce(
                func.sum(case((Movement.type == MovementType.EXPENSE, Movement.amount_cents), else_=0)),
                0,
            ),
            func.count(Movement.id),
        ).where(
            Movement.user_id == user_id,
            Movement.status == MovementStatus.COMPLETED,
            Movement.transaction_date >= start,
            Movement.transaction_date <= end,
        )
        row = (await db.execute(stmt)).one()
        income_cents = int(row[0] or 0)
        expense_cents = int(row[1] or 0)
        count = int(row[2] or 0)
        balance = income_cents - expense_cents

        prev_start = start - timedelta(days=last_day)
        prev_end = start - timedelta(days=1)
        prev = await self._month_totals(db, user_id, prev_start, prev_end)
        prev_income = prev["income_cents"]
        prev_expense = prev["expense_cents"]

        income_var = self._variation(income_cents, prev_income)
        expense_var = self._variation(expense_cents, prev_expense)

        return {
            "month": month or f"{year}-{m:02d}",
            "income_cents": income_cents,
            "income": round(income_cents / 100, 2),
            "expense_cents": expense_cents,
            "expense": round(expense_cents / 100, 2),
            "balance_cents": balance,
            "balance": round(balance / 100, 2),
            "transaction_count": count,
            "income_variation": income_var,
            "expense_variation": expense_var,
        }

    async def top_categories(
        self, db: AsyncSession, user_id: int, limit: int = 5
    ) -> dict:
        stmt = select(
            Movement.category_id,
            func.sum(Movement.amount_cents).label("total"),
            func.count(Movement.id).label("count"),
        ).where(
            Movement.user_id == user_id,
            Movement.status == MovementStatus.COMPLETED,
            Movement.type == MovementType.EXPENSE,
        ).group_by(Movement.category_id).order_by(func.sum(Movement.amount_cents).desc()).limit(
            limit
        )
        rows = (await db.execute(stmt)).all()
        items = []
        total_expense = 0
        for r in rows:
            total_expense += int(r.total or 0)
            items.append(
                {
                    "category_id": int(r.category_id),
                    "total_cents": int(r.total or 0),
                    "total": round(int(r.total or 0) / 100, 2),
                    "count": int(r.count or 0),
                }
            )
        return {
            "items": items,
            "total_expense_cents": total_expense,
            "total_expense": round(total_expense / 100, 2),
        }

    async def monthly_trend(
        self, db: AsyncSession, user_id: int, months: int = 12
    ) -> dict:
        today = date.today()
        start = date(today.year - 1 if months > 12 else today.year, 1, 1)
        if months <= 12:
            m = today.month - months + 1
            y = today.year
            if m < 1:
                m += 12
                y -= 1
            start = date(y, m, 1)

        stmt = select(
            extract("year", Movement.transaction_date).label("year"),
            extract("month", Movement.transaction_date).label("month"),
            func.coalesce(
                func.sum(case((Movement.type == MovementType.INCOME, Movement.amount_cents), else_=0)), 0
            ).label("income"),
            func.coalesce(
                func.sum(case((Movement.type == MovementType.EXPENSE, Movement.amount_cents), else_=0)), 0
            ).label("expense"),
        ).where(
            Movement.user_id == user_id,
            Movement.status == MovementStatus.COMPLETED,
            Movement.transaction_date >= start,
            Movement.transaction_date <= today,
        ).group_by("year", "month").order_by("year", "month")
        rows = (await db.execute(stmt)).all()

        months_data = []
        for r in rows:
            y = int(r.year)
            m = int(r.month)
            inc = int(r.income or 0)
            exp = int(r.expense or 0)
            months_data.append(
                {
                    "month": f"{y}-{m:02d}",
                    "label": date(y, m, 1).strftime("%b %Y"),
                    "income_cents": inc,
                    "income": round(inc / 100, 2),
                    "expense_cents": exp,
                    "expense": round(exp / 100, 2),
                    "balance_cents": inc - exp,
                    "balance": round((inc - exp) / 100, 2),
                }
            )
        return {"months": months_data}

    async def category_breakdown(
        self, db: AsyncSession, user_id: int, month: str | None = None
    ) -> dict:
        if month:
            year, m = map(int, month.split("-"))
        else:
            today = date.today()
            year, m = today.year, today.month
        _, last_day = monthrange(year, m)
        start = date(year, m, 1)
        end = date(year, m, last_day)

        stmt = select(
            Movement.category_id,
            func.sum(Movement.amount_cents).label("total"),
        ).where(
            Movement.user_id == user_id,
            Movement.status == MovementStatus.COMPLETED,
            Movement.type == MovementType.EXPENSE,
            Movement.transaction_date >= start,
            Movement.transaction_date <= end,
        ).group_by(Movement.category_id).order_by(func.sum(Movement.amount_cents).desc())
        rows = (await db.execute(stmt)).all()
        items = []
        grand_total = 0
        for r in rows:
            total = int(r.total or 0)
            grand_total += total
            items.append(
                {
                    "category_id": int(r.category_id),
                    "total_cents": total,
                    "total": round(total / 100, 2),
                }
            )
        if grand_total > 0:
            for item in items:
                item["percentage"] = round(item["total_cents"] / grand_total * 100, 1)
            items[0]["percentage"] = round(
                100 - sum(i["percentage"] for i in items[1:]), 1
            )
        return {"items": items, "grand_total_cents": grand_total, "grand_total": round(grand_total / 100, 2)}

    async def wallet_breakdown(
        self, db: AsyncSession, user_id: int
    ) -> dict:
        stmt = select(
            Movement.wallet_id,
            func.coalesce(
                func.sum(case((Movement.type == MovementType.INCOME, Movement.amount_cents), else_=0)), 0
            ).label("income"),
            func.coalesce(
                func.sum(case((Movement.type == MovementType.EXPENSE, Movement.amount_cents), else_=0)), 0
            ).label("expense"),
        ).where(
            Movement.user_id == user_id,
            Movement.status == MovementStatus.COMPLETED,
        ).group_by(Movement.wallet_id)
        rows = (await db.execute(stmt)).all()
        items = []
        for r in rows:
            inc = int(r.income or 0)
            exp = int(r.expense or 0)
            items.append(
                {
                    "wallet_id": int(r.wallet_id),
                    "income_cents": inc,
                    "income": round(inc / 100, 2),
                    "expense_cents": exp,
                    "expense": round(exp / 100, 2),
                    "balance_cents": inc - exp,
                    "balance": round((inc - exp) / 100, 2),
                }
            )
        return {"items": items}

    async def _month_totals(
        self, db: AsyncSession, user_id: int, start: date, end: date
    ) -> dict:
        stmt = select(
            func.coalesce(
                func.sum(case((Movement.type == MovementType.INCOME, Movement.amount_cents), else_=0)), 0
            ),
            func.coalesce(
                func.sum(case((Movement.type == MovementType.EXPENSE, Movement.amount_cents), else_=0)), 0
            ),
        ).where(
            Movement.user_id == user_id,
            Movement.status == MovementStatus.COMPLETED,
            Movement.transaction_date >= start,
            Movement.transaction_date <= end,
        )
        row = (await db.execute(stmt)).one()
        income_cents = int(row[0] or 0)
        expense_cents = int(row[1] or 0)
        return {"income_cents": income_cents, "expense_cents": expense_cents}

    def _variation(self, current: int, previous: int) -> float | None:
        if previous == 0:
            return None if current == 0 else 100.0
        return round((current - previous) / previous * 100, 1)
