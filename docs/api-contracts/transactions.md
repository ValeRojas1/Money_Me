# Transactions API Contract

## GET /api/v1/transactions

List all transactions (paginated).

**Query Parameters:**
- `page` (int, default: 1)
- `limit` (int, default: 20)
- `category` (string, optional)
- `start_date` (string ISO date, optional)
- `end_date` (string ISO date, optional)

**Response (200):**
```json
{
  "items": [
    {
      "id": 1,
      "amount": -150.50,
      "description": "Groceries",
      "category": "food",
      "type": "expense",
      "date": "2026-05-31",
      "created_at": "2026-05-31T10:00:00Z"
    }
  ],
  "total": 42,
  "page": 1,
  "limit": 20
}
```

## POST /api/v1/transactions

Create a new transaction.

**Request:**
```json
{
  "amount": -150.50,
  "description": "Groceries",
  "category": "food",
  "type": "expense",
  "date": "2026-05-31"
}
```

**Response (201):** Created transaction object

## GET /api/v1/transactions/{id}

Get a single transaction by ID.

**Response (200):** Transaction object

## PUT /api/v1/transactions/{id}

Update an existing transaction.

**Response (200):** Updated transaction object

## DELETE /api/v1/transactions/{id}

Delete a transaction.

**Response (204):** No content
