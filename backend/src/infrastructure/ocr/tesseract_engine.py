import os
import shutil
import subprocess
import tempfile
from pathlib import Path

from src.config.settings import settings


class OCREngineError(Exception):
    pass


# Common install locations for Tesseract on different OSes.
# Used as a fallback when settings.tesseract_cmd does not point to a real file.
_COMMON_TESSERACT_PATHS: list[str] = [
    r"C:\Program Files\Tesseract-OCR\tesseract.exe",
    r"C:\Program Files (x86)\Tesseract-OCR\tesseract.exe",
    os.path.expandvars(r"%LOCALAPPDATA%\Programs\Tesseract-OCR\tesseract.exe"),
    os.path.expandvars(r"%LOCALAPPDATA%\Tesseract-OCR\tesseract.exe"),
    os.path.expandvars(r"%ProgramFiles%\Tesseract-OCR\tesseract.exe"),
    "/usr/bin/tesseract",
    "/usr/local/bin/tesseract",
    "/opt/homebrew/bin/tesseract",
]


def resolve_tesseract_cmd(configured: str = "") -> str:
    """
    Resolve a usable path to the Tesseract executable.

    Order of preference:
      1. The configured path (from .env / settings) if it exists on disk.
      2. `tesseract` found on the system PATH.
      3. A known common install location that exists on disk.
      4. The configured value (or bare "tesseract") as a last resort so the
         caller still gets a clear, actionable error if nothing is found.
    """
    configured = (configured or settings.tesseract_cmd or "").strip().strip('"')

    if configured and Path(configured).is_file():
        return configured

    on_path = shutil.which("tesseract") or shutil.which("tesseract.exe")
    if on_path:
        return on_path

    for candidate in _COMMON_TESSERACT_PATHS:
        if candidate and Path(candidate).is_file():
            return candidate

    return configured or "tesseract"


class OcrResult:
    def __init__(
        self,
        raw_text: str,
        confidence: float,
        words: list[dict],
        processing_time_ms: int,
    ) -> None:
        self.raw_text = raw_text
        self.confidence = confidence
        self.words = words
        self.processing_time_ms = processing_time_ms


class TesseractEngine:

    def __init__(self, tesseract_cmd: str = "", lang: str = "spa+eng") -> None:
        self._tesseract_cmd = resolve_tesseract_cmd(tesseract_cmd)
        self._lang = self._resolve_lang(lang)

    def _resolve_lang(self, requested_lang: str) -> str:
        """Check which languages are actually available and fall back gracefully."""
        try:
            result = subprocess.run(
                [self._tesseract_cmd, "--list-langs"],
                capture_output=True, text=True, timeout=10,
            )
            available_lines = result.stdout.strip().splitlines()
            # Skip header lines like "List of available languages..."
            available = {
                line.strip()
                for line in available_lines
                if line.strip() and not line.strip().startswith("List")
            }

            requested_parts = [p.strip() for p in requested_lang.split("+") if p.strip()]
            valid_parts = [p for p in requested_parts if p in available]

            if not valid_parts:
                valid_parts = ["eng"] if "eng" in available else [
                    p for p in available if p != "osd"
                ][:1]

            resolved = "+".join(valid_parts)
            if resolved != requested_lang:
                import warnings
                warnings.warn(
                    f"Tesseract: language(s) '{requested_lang}' not fully available. "
                    f"Available: {sorted(available - {'osd'})}. Using '{resolved}'."
                )
            return resolved
        except Exception:
            return "eng"  # Safe fallback

    def execute(self, image_data: bytes) -> OcrResult:
        """
        Run Tesseract OCR on image_data.
        Uses TSV output for real confidence scores.
        Tries multiple PSM modes and picks the best result.
        """
        import time
        start = time.perf_counter()

        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
            tmp.write(image_data)
            tmp_path = tmp.name

        try:
            # Try PSM 6 (assume uniform block of text) and PSM 3 (auto) and pick best
            best_result = None
            best_conf = -1.0

            for psm in ["6", "3", "4", "11"]:
                words, raw_text = self._run_tsv(tmp_path, psm)
                if not words:
                    continue
                conf = self._compute_confidence_from_words(words)
                if conf > best_conf:
                    best_conf = conf
                    best_result = (words, raw_text, conf)

            if best_result is None:
                # Last resort: plain text mode
                words, raw_text = self._run_tsv(tmp_path, "6")
                best_result = (words, raw_text, 0.0)

            words_out, raw_text_out, conf_out = best_result
            elapsed = int((time.perf_counter() - start) * 1000)

            return OcrResult(
                raw_text=raw_text_out,
                confidence=round(conf_out, 2),
                words=words_out[:100],
                processing_time_ms=elapsed,
            )
        finally:
            Path(tmp_path).unlink(missing_ok=True)

    def _run_tsv(self, image_path: str, psm: str) -> tuple[list[dict], str]:
        """
        Run Tesseract in TSV output mode and return (words, raw_text).
        TSV gives us per-word confidence scores from Tesseract directly.
        """
        cmd = [
            self._tesseract_cmd,
            image_path,
            "stdout",
            "--psm", psm,
            "--oem", "3",
            "-l", self._lang,
            "tsv",
        ]
        try:
            result = subprocess.run(
                cmd, capture_output=True, text=True, timeout=30,
            )
        except FileNotFoundError:
            raise OCREngineError(
                f"No se encontró el ejecutable de Tesseract ('{self._tesseract_cmd}'). "
                "Instala Tesseract OCR (https://github.com/UB-Mannheim/tesseract/wiki) "
                "y verifica que esté en el PATH o que TESSERACT_CMD en .env apunte a "
                "tesseract.exe (por ejemplo C:\\Program Files\\Tesseract-OCR\\tesseract.exe)."
            )

        if result.returncode != 0:
            return [], ""

        words: list[dict] = []
        lines_tsv = result.stdout.strip().split("\n")
        if len(lines_tsv) < 2:
            return [], ""

        for line in lines_tsv[1:]:
            cols = line.split("\t")
            if len(cols) < 12:
                continue
            try:
                conf = float(cols[10])
                word_text = cols[11].strip()
                if not word_text:
                    continue

                if conf >= 0:  # include even low confidence but not -1 (separator)
                    words.append({
                        "text": word_text,
                        "conf": conf,
                        "x": int(cols[6]),
                        "y": int(cols[7]),
                        "w": int(cols[8]),
                        "h": int(cols[9]),
                    })
            except (ValueError, IndexError):
                continue

        # Reconstruct raw text by grouping words horizontally (by Y coordinate)
        words.sort(key=lambda w: (w["y"], w["x"]))
        
        lines_grouped = []
        if words:
            current_line = [words[0]]
            for w in words[1:]:
                prev_y = sum(cw["y"] for cw in current_line) / len(current_line)
                # Tolerance: 50% of the average height of current line words
                avg_h = sum(cw["h"] for cw in current_line) / len(current_line)
                h_tol = max(avg_h * 0.6, 10.0)
                
                if abs(w["y"] - prev_y) < h_tol:
                    current_line.append(w)
                else:
                    current_line.sort(key=lambda cw: cw["x"])
                    lines_grouped.append(current_line)
                    current_line = [w]
            current_line.sort(key=lambda cw: cw["x"])
            lines_grouped.append(current_line)

        raw_text = "\n".join(
            " ".join(w["text"] for w in line)
            for line in lines_grouped
        )

        return words, raw_text

    def _compute_confidence_from_words(self, words: list[dict]) -> float:
        """
        Compute real confidence from Tesseract word confidence scores.
        Only counts words with conf >= 0 (conf == -1 means separator/whitespace).
        """
        valid = [w["conf"] for w in words if w["conf"] >= 0]
        if not valid:
            return 0.0
        avg = sum(valid) / len(valid)
        return round(avg, 2)
