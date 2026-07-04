import json
import time
from datetime import datetime, timezone

from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models.capture import (
    CaptureSource,
    CaptureStatus,
    ProcessedCapture,
)
from src.infrastructure.ocr.classifier import MovementClassifier
from src.infrastructure.ocr.duplicate_detector import DuplicateDetector
from src.infrastructure.ocr.field_extractor import FieldExtractor
from src.infrastructure.ocr.image_processor import ImageProcessor
from src.infrastructure.ocr.tesseract_engine import TesseractEngine


class OcrResultData:
    def __init__(
        self,
        capture_id: int,
        raw_text: str,
        ocr_confidence: float,
        extracted_fields: dict,
        classification: dict,
        is_duplicate: bool,
        duplicate_confidence: float,
        fingerprint: str,
        processing_time_ms: int,
        status: str,
    ) -> None:
        self.capture_id = capture_id
        self.raw_text = raw_text
        self.ocr_confidence = ocr_confidence
        self.extracted_fields = extracted_fields
        self.classification = classification
        self.is_duplicate = is_duplicate
        self.duplicate_confidence = duplicate_confidence
        self.fingerprint = fingerprint
        self.processing_time_ms = processing_time_ms
        self.status = status

    def to_dict(self) -> dict:
        return {
            "capture_id": self.capture_id,
            "raw_text": self.raw_text,
            "ocr_confidence": self.ocr_confidence,
            "extracted_data": self.extracted_fields,
            "classification": self.classification,
            "is_duplicate": self.is_duplicate,
            "duplicate_confidence": self.duplicate_confidence,
            "fingerprint": self.fingerprint,
            "processing_time_ms": self.processing_time_ms,
            "status": self.status,
        }


class OcrUseCase:

    def __init__(
        self,
        image_processor: ImageProcessor | None = None,
        tesseract: TesseractEngine | None = None,
        field_extractor: FieldExtractor | None = None,
        classifier: MovementClassifier | None = None,
        duplicate_detector: DuplicateDetector | None = None,
    ) -> None:
        self._image_processor = image_processor or ImageProcessor()
        self._tesseract = tesseract or TesseractEngine()
        self._field_extractor = field_extractor or FieldExtractor()
        self._classifier = classifier or MovementClassifier()
        self._duplicate_detector = duplicate_detector or DuplicateDetector()

    async def process_receipt(
        self,
        db: AsyncSession,
        user_id: int,
        file_data: bytes,
        filename: str,
    ) -> list[OcrResultData]:
        start = time.perf_counter()

        self._image_processor.validate_file(file_data, filename)

        preprocessed = self._image_processor.preprocess(file_data)
        ocr_result = self._tesseract.execute(preprocessed)

        # Exact-duplicate check compares normalized OCR text against previous
        # captures (schema-safe, no image-hash column required).
        is_dup = await self._duplicate_detector.check_exact_duplicate(
            db, user_id, ocr_result.raw_text
        )

        # Extract multiple rows of transactions
        fields_list = self._field_extractor.extract_multiple(ocr_result.raw_text)
        
        results = []
        
        for fields in fields_list:
            # When several rows were extracted from one image, classify each row
            # by its own line so categories don't all collapse to the same value.
            classify_text = fields.raw_fields.get("line") or ocr_result.raw_text
            classification = self._classifier.classify(
                classify_text, fields.amount_cents
            )

            semantic_dup = False
            dup_confidence = 0.0
            if fields.amount_cents and fields.date:
                semantic_dup, dup_confidence = (
                    await self._duplicate_detector.check_semantic_duplicate(
                        db,
                        user_id,
                        fields.amount_cents,
                        fields.date,
                        fields.merchant,
                        fields.concept,
                    )
                )

            fingerprint = self._duplicate_detector.compute_fingerprint({
                "amount_cents": fields.amount_cents,
                "date": str(fields.date) if fields.date else "",
                "merchant": fields.merchant or "",
            })

            extracted_dict = {
                "amount_cents": fields.amount_cents,
                "currency": fields.currency,
                "date": str(fields.date) if fields.date else None,
                "time": fields.time,
                "transaction_type": fields.transaction_type,
                "origin": fields.origin,
                "destination": fields.destination,
                "concept": fields.concept,
                "operation_code": fields.operation_code,
                "merchant": fields.merchant,
            }

            capture = ProcessedCapture(
                user_id=user_id,
                source=CaptureSource.RECEIPT,
                status=(
                    CaptureStatus.COMPLETED
                    if ocr_result.confidence > 30 and fields.amount_cents
                    else CaptureStatus.FAILED
                ),
                raw_image_url=None,
                processed_image_url=None,
                raw_text=ocr_result.raw_text,
                merchant_name=fields.merchant,
                total_cents=fields.amount_cents,
                currency=fields.currency,
                capture_date=(
                    datetime.combine(fields.date, datetime.min.time(), tzinfo=timezone.utc)
                    if fields.date
                    else None
                ),
                confidence_score=ocr_result.confidence / 100.0,
                error_message=None,
                detected_items=json.dumps(ocr_result.words[:50]),
            )

            db.add(capture)
            await db.commit()
            await db.refresh(capture)

            elapsed = int((time.perf_counter() - start) * 1000)

            results.append(OcrResultData(
                capture_id=capture.id,
                raw_text=ocr_result.raw_text,
                ocr_confidence=ocr_result.confidence,
                extracted_fields=extracted_dict,
                classification=classification,
                is_duplicate=is_dup or semantic_dup,
                duplicate_confidence=max(dup_confidence, 0.1 if is_dup else 0),
                fingerprint=fingerprint,
                processing_time_ms=elapsed,
                status=(
                    "completed" if ocr_result.confidence > 30 and fields.amount_cents else "low_confidence"
                ),
            ))

        return results
