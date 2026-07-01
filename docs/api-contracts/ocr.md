# OCR API Contract

## POST /api/v1/ocr/scan-receipt

Upload and process a receipt image.

**Request:** multipart/form-data
- `image` (file, required): Receipt image (jpg, png)

**Response (200):**
```json
{
  "raw_text": "SUPERMARKET\nTotal: $45.30\nItems:\nMilk $3.50\nBread $2.00",
  "extracted_data": {
    "merchant": "SUPERMARKET",
    "total": 45.30,
    "currency": "USD",
    "items": [
      {"description": "Milk", "amount": 3.50},
      {"description": "Bread", "amount": 2.00}
    ],
    "date": "2026-05-31"
  },
  "confidence": 0.92
}
```

## POST /api/v1/ocr/scan-invoice

Upload and process an invoice image.

**Request:** multipart/form-data
- `image` (file, required): Invoice image (jpg, png)

**Response (200):** Similar structure to scan-receipt

## GET /api/v1/ocr/history

Get OCR scan history.

**Response (200):**
```json
{
  "scans": [
    {
      "id": 1,
      "type": "receipt",
      "merchant": "SUPERMARKET",
      "total": 45.30,
      "date": "2026-05-31",
      "created_at": "2026-05-31T10:00:00Z"
    }
  ],
  "total": 10
}
```
