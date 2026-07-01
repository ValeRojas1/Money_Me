# Analysis API Contract

## GET /api/v1/analysis/spending

Get spending analysis grouped by category.

**Query Parameters:**
- `start_date` (string ISO date, optional)
- `end_date` (string ISO date, optional)

**Response (200):**
```json
{
  "period": {
    "start": "2026-01-01",
    "end": "2026-05-31"
  },
  "total_spent": 4520.00,
  "categories": [
    {"category": "food", "amount": 1200.00, "percentage": 26.5},
    {"category": "transport", "amount": 400.00, "percentage": 8.8}
  ]
}
```

## GET /api/v1/analysis/trends

Get spending trends over time.

**Response (200):**
```json
{
  "trends": [
    {"month": "2026-01", "income": 3000, "expenses": 2800},
    {"month": "2026-02", "income": 3000, "expenses": 3100}
  ]
}
```

## GET /api/v1/analysis/categories

Get all available transaction categories.

**Response (200):**
```json
{
  "categories": [
    {"id": "food", "name": "Food & Dining", "icon": "restaurant"},
    {"id": "transport", "name": "Transportation", "icon": "directions_car"}
  ]
}
```

## GET /api/v1/analysis/income-vs-expenses

Compare income vs expenses for a given period.

**Response (200):**
```json
{
  "total_income": 5000.00,
  "total_expenses": 4520.00,
  "balance": 480.00
}
```
