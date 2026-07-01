from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.deps import get_db
from src.api.v1.dependencies import get_current_user
from src.application.use_cases.capture_use_case import CaptureUseCase
from src.application.use_cases.ocr_use_case import OcrUseCase
from src.core.errors import NotFoundError
from src.domain.models.capture import ProcessedCapture
from src.infrastructure.ocr.image_processor import ImageValidationError

router = APIRouter()


@router.post("/scan-receipt", summary="Scan and extract data from receipt image")
async def scan_receipt(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    file_data = await file.read()
    user_id = int(current_user.get("sub", 0))

    use_case = OcrUseCase()
    try:
        results = await use_case.process_receipt(
            db=db, user_id=user_id, file_data=file_data, filename=file.filename or "receipt.png",
        )
        return {"items": [r.to_dict() for r in results]}
    except ImageValidationError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Processing failed: {str(e)}",
        )


@router.post("/scan-multiple", summary="Scan multiple images at once")
async def scan_multiple(
    files: list[UploadFile] = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = OcrUseCase()
    results = []

    for file in files:
        file_data = await file.read()
        try:
            image_results = await use_case.process_receipt(
                db=db, user_id=user_id, file_data=file_data, filename=file.filename or "receipt.png",
            )
            for r in image_results:
                results.append(r.to_dict())
        except Exception as e:
            results.append({
                "filename": file.filename,
                "status": "error",
                "message": str(e),
            })

    return {"results": results, "total": len(results), "successful": sum(1 for r in results if r.get("status") != "error")}


@router.post("/{capture_id}/confirm", summary="Confirm capture and create movement")
async def confirm_capture(
    capture_id: int,
    edits: dict | None = None,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = CaptureUseCase()
    try:
        return await use_case.confirm_capture(db, user_id, capture_id, edits)
    except NotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.post("/{capture_id}/reject", summary="Reject/discard a capture")
async def reject_capture(
    capture_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = CaptureUseCase()
    try:
        return await use_case.reject_capture(db, user_id, capture_id)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/{capture_id}/reprocess", summary="Reprocess a capture")
async def reprocess_capture(
    capture_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = CaptureUseCase()
    try:
        return await use_case.reprocess_capture(db, user_id, capture_id)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.get("/history", summary="Get OCR scan history with statuses")
async def ocr_history(
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = CaptureUseCase()
    return await use_case.list_history(db, user_id)


@router.get("/{capture_id}", summary="Get capture details")
async def get_capture(
    capture_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    stmt = select(ProcessedCapture).where(
        ProcessedCapture.id == capture_id,
        ProcessedCapture.user_id == user_id,
    )
    db_result = await db.execute(stmt)
    capture = db_result.scalar_one_or_none()
    if not capture:
        raise HTTPException(status_code=404)
    return capture


@router.post("/manual", summary="Create a movement manually (no capture)")
async def create_manual(
    data: dict,
    db: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user),
):
    user_id = int(current_user.get("sub", 0))
    use_case = CaptureUseCase()
    return await use_case.create_manual_movement(db, user_id, data)
