import io

import pytest
from PIL import Image


def _create_test_image() -> bytes:
    img = Image.new("RGB", (100, 50), color="white")
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)
    return buf.getvalue()


@pytest.mark.asyncio
async def test_ocr_scan_receipt_image_validation(client, auth_headers):
    response = await client.post(
        "/api/v1/ocr/scan-receipt",
        headers=auth_headers,
        files={"file": ("test.txt", b"not an image", "text/plain")},
    )
    assert response.status_code in (400, 422, 500), f"Expected error, got {response.status_code}: {response.text}"
    data = response.json()
    assert "error" in data or "detail" in data


@pytest.mark.asyncio
async def test_ocr_scan_receipt_no_auth(client):
    img_bytes = _create_test_image()
    response = await client.post(
        "/api/v1/ocr/scan-receipt",
        files={"file": ("test.png", img_bytes, "image/png")},
    )
    assert response.status_code == 401
    data = response.json()
    assert "message" in data


@pytest.mark.asyncio
async def test_ocr_image_processor():
    from src.infrastructure.ocr.image_processor import ImageProcessor, ImageValidationError

    processor = ImageProcessor()
    img_bytes = _create_test_image()

    mime = processor.detect_mime_type(img_bytes)
    assert mime == "image/png"

    processor.validate_file(img_bytes, "test.png")

    preprocessed = processor.preprocess(img_bytes)
    assert len(preprocessed) > 0

    with pytest.raises(ImageValidationError):
        processor.validate_file(b"not an image", "test.txt")


@pytest.mark.asyncio
async def test_ocr_classifier():
    from src.infrastructure.ocr.classifier import MovementClassifier

    classifier = MovementClassifier()
    result = classifier.classify("Uber ride to airport", 2500)
    assert result is not None
    assert result["type"] == "expense"
    assert "confidence" in result


@pytest.mark.asyncio
async def test_ocr_history_no_auth(client):
    response = await client.get("/api/v1/ocr/history")
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_ocr_manual_movement(client, auth_headers):
    response = await client.post(
        "/api/v1/ocr/manual",
        headers=auth_headers,
        json={
            "description": "Manual entry",
            "amount_cents": 10000,
            "type": "expense",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "id" in data
