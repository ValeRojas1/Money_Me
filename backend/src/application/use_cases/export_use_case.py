import csv
import io
from datetime import date

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer

from src.core.errors import NotFoundError
from src.domain.models.movement import Movement, MovementStatus


class ExportUseCase:

    async def export_csv(
        self,
        db: AsyncSession,
        user_id: int,
        start_date: str | None = None,
        end_date: str | None = None,
    ) -> str:
        stmt = select(Movement).where(
            Movement.user_id == user_id,
            Movement.status == MovementStatus.COMPLETED,
        ).order_by(Movement.transaction_date.desc())
        if start_date:
            stmt = stmt.where(Movement.transaction_date >= date.fromisoformat(start_date))
        if end_date:
            stmt = stmt.where(Movement.transaction_date <= date.fromisoformat(end_date))

        result = await db.execute(stmt)
        movements = result.scalars().all()

        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(["Date", "Type", "Description", "Amount", "Currency", "Category", "Notes", "Tags"])

        for m in movements:
            writer.writerow([
                m.transaction_date.isoformat(),
                m.type.value,
                m.description,
                round(m.amount_cents / 100, 2),
                m.currency,
                m.category_id,
                m.notes or "",
                m.tags or "",
            ])

        return output.getvalue()

    async def export_pdf(
        self,
        db: AsyncSession,
        user_id: int,
        start_date: str | None = None,
        end_date: str | None = None,
    ) -> bytes:
        stmt = select(Movement).where(
            Movement.user_id == user_id,
            Movement.status == MovementStatus.COMPLETED,
        ).order_by(Movement.transaction_date.desc())
        if start_date:
            stmt = stmt.where(Movement.transaction_date >= date.fromisoformat(start_date))
        if end_date:
            stmt = stmt.where(Movement.transaction_date <= date.fromisoformat(end_date))

        result = await db.execute(stmt)
        movements = result.scalars().all()

        buf = io.BytesIO()
        doc = SimpleDocTemplate(buf, pagesize=landscape(letter))
        styles = getSampleStyleSheet()
        elements = []

        elements.append(Paragraph(f"Transaction Report", styles["Title"]))
        if start_date and end_date:
            elements.append(Paragraph(f"Period: {start_date} to {end_date}", styles["Normal"]))
        elif start_date:
            elements.append(Paragraph(f"From: {start_date}", styles["Normal"]))
        elif end_date:
            elements.append(Paragraph(f"Until: {end_date}", styles["Normal"]))
        elements.append(Spacer(1, 12))

        data = [["Date", "Type", "Description", "Amount", "Currency"]]
        for m in movements:
            data.append([
                m.transaction_date.isoformat(),
                m.type.value,
                m.description[:40] if m.description else "",
                f"${round(m.amount_cents / 100, 2):.2f}",
                m.currency,
            ])

        table = Table(data)
        table.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#4A90D9")),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("FONTSIZE", (0, 0), (-1, -1), 9),
            ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
            ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F5F5F5")]),
            ("ALIGN", (3, 0), (3, -1), "RIGHT"),
        ]))
        elements.append(table)

        total_income = sum(m.amount_cents for m in movements if m.type.value == "income")
        total_expense = sum(m.amount_cents for m in movements if m.type.value == "expense")
        elements.append(Spacer(1, 12))
        elements.append(Paragraph(f"Total Income: ${round(total_income / 100, 2):.2f}", styles["Normal"]))
        elements.append(Paragraph(f"Total Expense: ${round(total_expense / 100, 2):.2f}", styles["Normal"]))
        elements.append(Paragraph(f"Balance: ${round((total_income - total_expense) / 100, 2):.2f}", styles["Normal"]))

        doc.build(elements)
        buf.seek(0)
        return buf.getvalue()
