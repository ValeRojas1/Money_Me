import io
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter, ImageOps

SUPPORTED_MIME_TYPES: dict[str, str] = {
    b"\xff\xd8\xff": "image/jpeg",
    b"\x89PNG\r\n\x1a\n": "image/png",
    b"GIF87a": "image/gif",
    b"GIF89a": "image/gif",
    b"II*\x00": "image/tiff",
    b"MM\x00*": "image/tiff",
    b"BM": "image/bmp",
    b"\x00\x00\x01\x00": "image/x-icon",
}

SUPPORTED_EXTENSIONS: set[str] = {".jpg", ".jpeg", ".png", ".tiff", ".tif", ".bmp"}
MAX_FILE_SIZE: int = 10 * 1024 * 1024
MAX_IMAGE_DIMENSION: int = 4000


class ImageValidationError(Exception):
    pass


def _is_screenshot_like(img: Image.Image) -> bool:
    """
    Heuristic to detect if an image is a mobile screenshot / digital UI capture.
    Screenshots tend to have:
     - Very uniform areas of white/solid color (low std-dev in large regions)
     - Sharp text on plain backgrounds
     - High ratio of unique colors in small areas (icons/UI elements)
    These should NOT be heavily preprocessed — Tesseract reads them better raw.
    """
    # Convert to RGB if needed
    sample = img.convert("L")  # grayscale
    # Downscale for speed
    thumb = sample.resize((200, int(200 * img.height / img.width)), Image.LANCZOS)
    pixels = list(thumb.getdata())
    if not pixels:
        return False
    avg = sum(pixels) / len(pixels)
    variance = sum((p - avg) ** 2 for p in pixels) / len(pixels)
    std_dev = variance ** 0.5

    # Low std deviation => the image has large uniform regions (typical of UI screenshots)
    # Screenshots from Yape/Plin/Izipay typically have white backgrounds with small colored text
    return std_dev < 70.0


class ImageProcessor:

    @staticmethod
    def detect_mime_type(data: bytes) -> str:
        for magic, mime in SUPPORTED_MIME_TYPES.items():
            if data[: len(magic)] == magic:
                return mime
        raise ImageValidationError("Unrecognized image format (magic bytes)")

    @staticmethod
    def validate_file(data: bytes, filename: str) -> None:
        ext = Path(filename).suffix.lower()
        if ext not in SUPPORTED_EXTENSIONS:
            raise ImageValidationError(f"Unsupported extension: {ext}")

        if len(data) > MAX_FILE_SIZE:
            raise ImageValidationError(
                f"File too large: {len(data)} bytes (max {MAX_FILE_SIZE})"
            )

        try:
            ImageProcessor.detect_mime_type(data)
        except ImageValidationError:
            raise ImageValidationError("File content does not match a valid image")

    @staticmethod
    def preprocess(data: bytes) -> bytes:
        """
        Smart preprocessing:
        - For screenshots/mobile captures (Yape, Plin, bank apps): minimal processing,
          just upscale if needed and convert to grayscale.
        - For physical receipts (low contrast, noisy): apply full enhancement pipeline.
        """
        img = Image.open(io.BytesIO(data))

        # Resize large images down to avoid memory issues
        if img.width > MAX_IMAGE_DIMENSION or img.height > MAX_IMAGE_DIMENSION:
            img.thumbnail((MAX_IMAGE_DIMENSION, MAX_IMAGE_DIMENSION), Image.LANCZOS)

        # Upscale very small images — Tesseract needs at least ~150dpi
        min_dim = 300
        if img.width < min_dim or img.height < min_dim:
            scale = max(min_dim / img.width, min_dim / img.height)
            new_w = int(img.width * scale)
            new_h = int(img.height * scale)
            img = img.resize((new_w, new_h), Image.LANCZOS)

        if _is_screenshot_like(img):
            # ── Screenshot / digital app capture ──────────────────────────────
            # These images already have clean, sharp text on solid backgrounds.
            # Heavy preprocessing (binarization, median filter) DESTROYS them.
            # Just convert to grayscale and apply mild sharpening.
            if img.mode != "L":
                img = img.convert("L")

            # Mild contrast boost only if the image is washed out
            enhancer = ImageEnhance.Contrast(img)
            img = enhancer.enhance(1.3)

            # Sharpen slightly to help Tesseract with small font sizes
            img = img.filter(ImageFilter.SHARPEN)
        else:
            # ── Physical receipt / low-quality scan ───────────────────────────
            # These need full pipeline: noise removal, contrast, binarization.
            if img.mode != "RGB":
                img = img.convert("RGB")

            img = ImageOps.grayscale(img)
            img = img.filter(ImageFilter.MedianFilter(size=3))

            enhancer = ImageEnhance.Contrast(img)
            img = enhancer.enhance(2.0)

            img = img.filter(ImageFilter.SMOOTH_MORE)
            img = ImageOps.autocontrast(img, cutoff=5)

            # Binarization — only for physical receipts
            threshold = 128
            img = img.point(lambda p: 255 if p > threshold else 0)

        buf = io.BytesIO()
        img.save(buf, format="PNG")
        buf.seek(0)
        return buf.getvalue()
