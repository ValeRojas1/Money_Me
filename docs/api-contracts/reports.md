# Reports API Contract

## GET /api/v1/reports/monthly

Generate a monthly financial report.

**Query Parameters:**
- `month` (int, 1-12, default: current)
- `year` (int, default: current)

**Response (200):**
```json
{
  "period": {"month": 5, "year": 2026},
  "summary": {
    "income": 5000.00,
    "expenses": 4520.00,
    "balance": 480.00
  },
  "top_categories": [
    {"category": "food", "amount": 1200.00},
    {"category": "housing", "amount": 1500.00}
  ],
  "transaction_count": 35
}
```

## GET /api/v1/reports/annual

Generate an annual financial report.

**Query Parameters:**
- `year` (int, default: current)

**Response (200):**
```json
{
  "year": 2026,
  "monthly_summary": [
    {"month": 1, "income": 5000, "expenses": 4800, "balance": 200},
    {"month": 2, "income": 5000, "expenses": 5100, "balance": -100}
  ],
  "annual_totals": {
    "income": 60000.00,
    "expenses": 58000.00,
    "balance": 2000.00
  },
  "top_categories": [
    {"category": "housing", "amount": 18000.00}
  ]
}
```

## GET /api/v1/reports/export

Export a report as CSV or PDF.

**Query Parameters:**
- `type` (string, "csv" | "pdf", required)
- `start_date` (string ISO date, required)
- `end_date` (string ISO date, required)

**Response (200):** Binary file (Content-Type: text/csv or application/pdf)
