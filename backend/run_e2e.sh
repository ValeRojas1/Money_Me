#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8000}"
BACKEND_DIR="$(cd "$(dirname "$0")" && pwd)"

export DATABASE_URL="sqlite+aiosqlite:///./data/e2e.db"
export APP_ENV="test"

echo "=== MoneyMe E2E Backend ==="
echo "Database: $DATABASE_URL"
echo "Port:     $PORT"
echo ""

# Seed database
echo "[1/2] Seeding database..."
cd "$BACKEND_DIR"
python seed_e2e.py
echo "Database seeded successfully!"
echo ""

# Start server
echo "[2/2] Starting server on port $PORT..."
echo "Press Ctrl+C to stop."
echo ""
uvicorn src.main:app --host 0.0.0.0 --port "$PORT" --reload
