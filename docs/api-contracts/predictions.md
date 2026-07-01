# Predictions API Contract

## GET /api/v1/predictions/monthly-spending

Predict next month's spending based on historical data.

**Response (200):**
```json
{
  "predicted_amount": 4600.00,
  "confidence": 0.85,
  "categories": [
    {"category": "food", "predicted": 1250.00},
    {"category": "transport", "predicted": 420.00}
  ]
}
```

## GET /api/v1/predictions/budget-recommendations

Get AI-powered budget recommendations.

**Response (200):**
```json
{
  "recommendations": [
    {"category": "food", "suggested_budget": 1100.00, "current_avg": 1200.00},
    {"category": "entertainment", "suggested_budget": 200.00, "current_avg": 350.00}
  ]
}
```

## GET /api/v1/predictions/savings-goal

Predict time to reach a savings goal.

**Query Parameters:**
- `goal_amount` (float, required)
- `monthly_savings` (float, optional)

**Response (200):**
```json
{
  "goal_amount": 10000.00,
  "monthly_savings": 500.00,
  "estimated_months": 20,
  "estimated_date": "2028-01-31"
}
```
