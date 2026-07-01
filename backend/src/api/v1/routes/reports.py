from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import PlainTextResponse, Response
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.api.v1.dependencies import get_current_user
from src.application.use_cases.export_use_case import ExportUseCase

router = APIRouter()


@router.get("/export/csv", summary="Export transactions as CSV")
async def export_csv(
    start_date: str | None = Query(None, regex=r"^\d{4}-\d{2}-\d{2}$"),
    end_date: str | None = Query(None, regex=r"^\d{4}-\d{2}-\d{2}$"),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = ExportUseCase()
    csv_content = await use_case.export_csv(db, user_id, start_date, end_date)
    return PlainTextResponse(
        content=csv_content,
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename=transactions_{start_date or 'all'}_{end_date or 'all'}.csv"},
    )


@router.get("/export/pdf", summary="Export transactions as PDF")
async def export_pdf(
    start_date: str | None = Query(None, regex=r"^\d{4}-\d{2}-\d{2}$"),
    end_date: str | None = Query(None, regex=r"^\d{4}-\d{2}-\d{2}$"),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = ExportUseCase()
    pdf_bytes = await use_case.export_pdf(db, user_id, start_date, end_date)
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename=transactions_{start_date or 'all'}_{end_date or 'all'}.pdf"},
    )
