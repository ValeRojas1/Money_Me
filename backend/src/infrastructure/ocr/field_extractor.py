import re
from datetime import date, datetime
from typing import Any


# Spanish month names mapping (full and abbreviated, with/without accent)
SPANISH_MONTHS: dict[str, int] = {
    "enero": 1, "ene": 1,
    "febrero": 2, "feb": 2,
    "marzo": 3, "mar": 3,
    "abril": 4, "abr": 4,
    "mayo": 5, "may": 5,
    "junio": 6, "jun": 6,
    "julio": 7, "jul": 7,
    "agosto": 8, "ago": 8,
    "septiembre": 9, "sep": 9, "set": 9,
    "octubre": 10, "oct": 10,
    "noviembre": 11, "nov": 11,
    "diciembre": 12, "dic": 12,
}


class ExtractedFields:
    def __init__(
        self,
        amount_cents: int | None = None,
        currency: str | None = None,
        date: date | None = None,
        time: str | None = None,
        transaction_type: str | None = None,
        origin: str | None = None,
        destination: str | None = None,
        concept: str | None = None,
        operation_code: str | None = None,
        merchant: str | None = None,
        raw_fields: dict[str, Any] | None = None,
    ) -> None:
        self.amount_cents = amount_cents
        self.currency = currency
        self.date = date
        self.time = time
        self.transaction_type = transaction_type
        self.origin = origin
        self.destination = destination
        self.concept = concept
        self.operation_code = operation_code
        self.merchant = merchant
        self.raw_fields = raw_fields or {}


class FieldExtractor:

    # Currency symbols — S/ is Peruvian Soles
    CURRENCY_SYMBOLS: dict[str, str] = {
        "S/": "PEN", "S/.": "PEN",
        "$": "USD", "US$": "USD",
        "€": "EUR", "£": "GBP", "¥": "JPY",
        "R$": "BRL", "MX$": "MXN", "COP": "COP", "ARS": "ARS",
    }

    # Amount patterns — ordered by priority
    AMOUNT_PATTERNS: list[re.Pattern] = [
        # Yape/Plin format: "S/ 30.00", "S/. 1,500.00"
        re.compile(r"S/\.?\s*([\d,\.]+)", re.I),
        # Generic currency symbol followed by amount
        re.compile(r"(?:US\$|\$|€|£)\s*([\d,\.]+)", re.I),
        # Keyword-based: "Total: 150.00", "Monto: S/ 50"
        re.compile(r"(?:total|importe|monto|amount|suma|cobro|pago)\s*:?\s*S?/?\.?\s*([\d,\.]+)", re.I),
        # Trailing amount on a line (e.g., receipts)
        re.compile(r"(?:^|\s)([\d]{1,3}(?:[,\.]\d{3})*[,\.]\d{2})\s*$", re.M),
    ]

    # Date patterns — including Spanish month names
    DATE_PATTERNS: list[re.Pattern] = [
        # ISO: 2026-06-04
        re.compile(r"\b(\d{4}[-/]\d{2}[-/]\d{2})\b"),
        # Yape/Plin format: "04 may. 2026", "4 de mayo de 2026"
        re.compile(
            r"\b(\d{1,2})\s+(?:de\s+)?([a-záéíóúñ]+)\.?\s+(?:de\s+)?(\d{4})\b",
            re.I | re.UNICODE,
        ),
        # DD/MM/YYYY or DD-MM-YYYY
        re.compile(r"\b(\d{2}[/\-]\d{2}[/\-]\d{4})\b"),
        # DD/MM/YY
        re.compile(r"\b(\d{2}[/\-]\d{2}[/\-]\d{2})\b"),
    ]

    # Time patterns — including "8:32 am", "08:32:00", "8:32am", "832am" (OCR artifacts)
    TIME_PATTERNS: list[re.Pattern] = [
        # Standard: "8:32 am", "08:32", "14:30:00"
        re.compile(r"\b(\d{1,2}:\d{2}(?::\d{2})?)\s*([AaPp][Mm])?\b"),
        # Yape format often puts time after dash: "8:32am", "08:32am"
        re.compile(r"[-–\s](\d{1,2}:\d{2})\s*([AaPp][Mm])\b", re.I),
    ]

    # Operation code patterns — Yape uses long numeric codes
    OPERATION_CODE_PATTERNS: list[re.Pattern] = [
        # Yape: "YAP20260504123456789"
        re.compile(r"\b(YAP\d{15,20})\b", re.I),
        # Plin: "PLN..." or "PLIN..."
        re.compile(r"\b(PLI?N\d{10,20})\b", re.I),
        # Generic operation/ref codes
        re.compile(r"(?:operaci[oó]n|n[uú]mero de operaci[oó]n|operation|ref|folio|n[°oa]?)\s*:?\s*([A-Z0-9]{8,25})", re.I),
        re.compile(r"\b([A-Z]{2,4}\d{10,20})\b"),
    ]

    # Merchant / person name patterns for Yape/Plin
    # Names are often on the first prominent line, may be masked with *
    MERCHANT_PATTERNS: list[re.Pattern] = [
        # Explicit label
        re.compile(r"(?:destinatario|beneficiario|para|merchant|tienda|comercio|establecimiento)\s*:?\s*(.+)$", re.I | re.M),
        # Yape-style masked name: "Walter Roj*" or "W. Rojas*" (word + optional word + asterisk or masked chars)
        re.compile(r"^([A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(?:\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ\*]+){0,3})\*?\s*$", re.M | re.UNICODE),
        # Any line that looks like a full name (2+ capitalized words, no numbers)
        re.compile(r"^([A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(?:\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+)+)\s*$", re.M | re.UNICODE),
    ]

    # Concept / description patterns
    CONCEPT_PATTERNS: list[re.Pattern] = [
        re.compile(r"(?:concepto|descripci[oó]n|detalle|motivo|description|por)\s*:?\s*(.+)$", re.I | re.M),
    ]

    # Transaction type keywords.
    # NOTE: order matters — income/expense are checked before the generic
    # "transferencia" so a Yape/Plin transfer is still classified by direction.
    INCOME_KEYWORDS = [
        # Yape / Plin (Peru): money received
        "te yapearon", "yapearon", "te plinearon", "plinearon",
        "recibiste", "recibido", "te enviaron", "te depositaron",
        "depósito", "deposito", "deposit", "abono",
        "transferencia recibida", "cobro", "ingreso", "entrada", "recibo de",
    ]
    EXPENSE_KEYWORDS = [
        # Yape / Plin (Peru): money sent
        "yapeaste", "yapeando", "yapeó", "yapeo", "plineaste",
        "enviaste", "enviado", "enviando", "pagaste", "pagado", "pago",
        "compra", "compraste", "retiro", "retiraste", "withdrawal",
        "cargo", "salida", "consumo",
    ]
    TRANSFER_KEYWORDS = [
        "transferencia", "transfer", "envío", "envio", "transferiste",
    ]

    def extract_all(self, text: str) -> ExtractedFields:
        fields = ExtractedFields(
            amount_cents=self._extract_amount(text),
            currency=self._extract_currency(text),
            date=self._extract_date(text),
            time=self._extract_time(text),
            transaction_type=self._extract_transaction_type(text),
            origin=self._extract_origin(text),
            destination=self._extract_destination(text),
            concept=self._extract_concept(text),
            operation_code=self._extract_operation_code(text),
            merchant=self._extract_merchant(text),
            raw_fields=self._extract_all_raw(text),
        )
        return fields

    def extract_multiple(self, text: str) -> list[ExtractedFields]:
        lines = [ln.strip() for ln in text.split("\n") if ln.strip()]
        results = []

        global_date = self._extract_date(text)
        global_currency = self._extract_currency(text)
        global_type = self._extract_transaction_type(text)

        for i, line in enumerate(lines):
            amount = self._extract_amount(line)
            if amount is not None:
                # Find date: current line -> previous 3 lines -> global
                date_val = self._extract_date(line)
                if not date_val:
                    for j in range(max(0, i - 3), i):
                        date_val = self._extract_date(lines[j])
                        if date_val:
                            break
                if not date_val:
                    date_val = global_date

                time_val = self._extract_time(line)
                currency = self._extract_currency(line)
                if currency == "PEN" and "S/" not in line and "PEN" not in line:
                    currency = global_currency

                txn_type = self._extract_transaction_type(line) or global_type
                origin = self._extract_origin(line)
                dest = self._extract_destination(line)
                op_code = self._extract_operation_code(line)

                merchant = self._extract_merchant(line)
                concept = self._extract_concept(line)

                # Fallback to clean line text for merchant if missing
                if not merchant:
                    cleaned = line
                    for pat in self.AMOUNT_PATTERNS:
                        cleaned = pat.sub("", cleaned)
                    for pat in self.DATE_PATTERNS:
                        cleaned = pat.sub("", cleaned)
                    for pat in self.TIME_PATTERNS:
                        cleaned = pat.sub("", cleaned)
                    cleaned = cleaned.strip(" -.,")
                    if cleaned and len(cleaned) > 2 and not re.search(r"^\d+$", cleaned):
                        merchant = cleaned

                fields = ExtractedFields(
                    amount_cents=amount,
                    currency=currency,
                    date=date_val,
                    time=time_val,
                    transaction_type=txn_type,
                    origin=origin,
                    destination=dest,
                    concept=concept,
                    operation_code=op_code,
                    merchant=merchant,
                    raw_fields={"line": line}
                )
                results.append(fields)

        if not results:
            single = self.extract_all(text)
            if single.amount_cents is not None:
                results.append(single)

        return results

    def _extract_amount(self, text: str) -> int | None:
        for pattern in self.AMOUNT_PATTERNS:
            match = pattern.search(text)
            if match:
                try:
                    raw = match.group(1).strip()
                    # Remove thousands separators and normalize decimal
                    # Handle "1,500.00" -> 1500.00 and "1.500,00" -> 1500.00
                    if "," in raw and "." in raw:
                        # Determine which is decimal separator
                        last_comma = raw.rfind(",")
                        last_dot = raw.rfind(".")
                        if last_dot > last_comma:
                            # "1,500.00" — comma is thousands, dot is decimal
                            raw = raw.replace(",", "")
                        else:
                            # "1.500,00" — dot is thousands, comma is decimal
                            raw = raw.replace(".", "").replace(",", ".")
                    elif "," in raw:
                        # Could be "1,500" (thousands) or "1,50" (decimal)
                        comma_idx = raw.rfind(",")
                        after_comma = raw[comma_idx + 1:]
                        if len(after_comma) == 2:
                            # Decimal comma: "30,00" -> 30.00
                            raw = raw.replace(",", ".")
                        else:
                            # Thousands comma: "1,500" -> 1500
                            raw = raw.replace(",", "")

                    amount_float = float(raw)
                    # Convert to cents
                    cents = round(amount_float * 100)
                    # Sanity check: between 1 cent and 10 million soles
                    if 1 <= cents <= 1_000_000_000:
                        return cents
                except (ValueError, IndexError):
                    continue
        return None

    def _extract_currency(self, text: str) -> str:
        # PEN (Peruvian Soles) must be checked first — S/ can be confused with $
        if re.search(r"S/\.?\s*[\d,\.]", text, re.I):
            return "PEN"
        if re.search(r"\bPEN\b", text, re.I):
            return "PEN"
        # Check remaining symbols in order of specificity
        for symbol, code in [
            ("US$", "USD"), ("MX$", "MXN"), ("R$", "BRL"),
            ("€", "EUR"), ("£", "GBP"), ("¥", "JPY"),
            ("$", "USD"),
        ]:
            if symbol in text:
                return code
        match = re.search(r"\b(USD|EUR|GBP|MXN|COP|ARS|BRL|JPY|PEN)\b", text)
        return match.group(1) if match else "PEN"  # Default to PEN for Peru

    def _extract_date(self, text: str) -> date | None:
        for pattern in self.DATE_PATTERNS:
            for match in pattern.finditer(text):
                # ISO format
                if pattern.groups == 1 or len(match.groups()) == 1:
                    date_str = match.group(1)
                    for fmt in ["%Y-%m-%d", "%Y/%m/%d", "%d/%m/%Y", "%d-%m-%Y",
                                 "%d/%m/%y", "%d-%m-%y"]:
                        try:
                            return datetime.strptime(date_str, fmt).date()
                        except ValueError:
                            continue
                elif len(match.groups()) == 3:
                    # Spanish: "04 may. 2026"
                    day_str, month_str, year_str = match.group(1), match.group(2), match.group(3)
                    # Normalize month: remove accent, lowercase, strip dot
                    month_clean = month_str.lower().strip().rstrip(".")
                    # Handle accented chars
                    month_clean = (
                        month_clean
                        .replace("á", "a").replace("é", "e").replace("í", "i")
                        .replace("ó", "o").replace("ú", "u")
                    )
                    month_num = SPANISH_MONTHS.get(month_clean)
                    if month_num:
                        try:
                            return date(int(year_str), month_num, int(day_str))
                        except ValueError:
                            continue
        return None

    def _extract_time(self, text: str) -> str | None:
        for pattern in self.TIME_PATTERNS:
            match = pattern.search(text)
            if match:
                time_str = match.group(1).strip()
                ampm = match.group(2) if match.lastindex >= 2 else None

                # Validate time components
                parts = time_str.split(":")
                try:
                    hour = int(parts[0])
                    minute = int(parts[1])
                except (ValueError, IndexError):
                    continue

                # Convert 12h to 24h if AM/PM present
                if ampm:
                    ampm_upper = ampm.upper()
                    if ampm_upper == "PM" and hour != 12:
                        hour += 12
                    elif ampm_upper == "AM" and hour == 12:
                        hour = 0
                    time_str = f"{hour:02d}:{minute:02d}"
                    if len(parts) > 2:
                        time_str += f":{parts[2]}"

                if 0 <= int(parts[0].lstrip("0") or "0") <= 23 and 0 <= minute <= 59:
                    return time_str
        return None

    def _extract_transaction_type(self, text: str) -> str | None:
        lower = text.lower()
        if any(w in lower for w in self.INCOME_KEYWORDS):
            return "income"
        if any(w in lower for w in self.EXPENSE_KEYWORDS):
            return "expense"
        if any(w in lower for w in self.TRANSFER_KEYWORDS):
            return "transfer"
        return None

    def _extract_origin(self, text: str) -> str | None:
        patterns = [
            re.compile(r"(?:cuenta origen|from|de cuenta|origin|source)\s*:?\s*(.+)$", re.I | re.M),
        ]
        for pattern in patterns:
            match = pattern.search(text)
            if match:
                return match.group(1).strip()
        return None

    def _extract_destination(self, text: str) -> str | None:
        patterns = [
            re.compile(r"(?:cuenta destino|to|para cuenta|destination|beneficiario)\s*:?\s*(.+)$", re.I | re.M),
        ]
        for pattern in patterns:
            match = pattern.search(text)
            if match:
                return match.group(1).strip()
        return None

    def _extract_concept(self, text: str) -> str | None:
        for pattern in self.CONCEPT_PATTERNS:
            match = pattern.search(text)
            if match:
                val = match.group(1).strip()
                if len(val) > 1:
                    return val
        # Fallback: find a descriptive line that isn't a date/amount/code
        lines = [ln.strip() for ln in text.split("\n") if ln.strip()]
        for ln in lines:
            if (
                len(ln) > 5
                and not re.search(r"[\d,\.]{4,}", ln)
                and not re.search(r"^(total|importe|subtotal|iva|fecha|hora|s/|yape|plin|izipay)", ln, re.I)
                and not re.search(r"[A-Z0-9]{10,}", ln)  # Skip operation codes
            ):
                return ln
        return None

    def _extract_operation_code(self, text: str) -> str | None:
        for pattern in self.OPERATION_CODE_PATTERNS:
            match = pattern.search(text)
            if match:
                return match.group(1).strip() if match.lastindex >= 1 else match.group(0).strip()
        return None

    def _extract_merchant(self, text: str) -> str | None:
        for pattern in self.MERCHANT_PATTERNS:
            match = pattern.search(text)
            if match:
                val = match.group(1).strip()
                # Clean up multi-line captures (join with space, strip extra whitespace)
                val = " ".join(val.split())
                # Filter out common non-name lines
                if (
                    len(val) >= 3
                    and not re.search(r"\d{4,}", val)
                    and val.lower() not in {
                        "yape", "plin", "izipay", "bcp", "bbva", "scotiabank",
                        "interbank", "banbif", "total", "monto", "fecha", "hora",
                    }
                ):
                    return val
        return None

    def _extract_all_raw(self, text: str) -> dict[str, Any]:
        return {
            "lines": text.split("\n"),
            "word_count": len(text.split()),
            "char_count": len(text),
        }

    @staticmethod
    def _is_valid_time(t: str) -> bool:
        parts = t.replace(":", "").replace(".", "")
        return parts.isdigit() and len(parts) >= 3
