"""Integration tests — multi-endpoint flows against real DB."""
import io
from datetime import date

import pytest
from PIL import Image


def _create_test_image() -> bytes:
    img = Image.new("RGB", (100, 50), color="white")
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)
    return buf.getvalue()


@pytest.mark.asyncio
async def test_flow_full_user_lifecycle(client):
    """Flow 1: Registro → Login → Wallet → Categoría → Transacción → Dashboard."""
    email = "flow1@test.com"
    password = "SecurePass1!"

    resp = await client.post(
        "/api/v1/auth/register",
        json={"email": email, "password": password, "name": "Flow1"},
    )
    assert resp.status_code == 200, f"Register failed: {resp.text}"
    token = resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": password},
    )
    assert resp.status_code == 200, f"Login failed: {resp.text}"
    token = resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    resp = await client.get(
        "/api/v1/auth/me",
        headers=headers,
    )
    assert resp.status_code == 200, f"Get /me failed: {resp.text}"
    assert resp.json()["email"] == email

    resp = await client.post(
        "/api/v1/wallets/",
        headers=headers,
        json={"name": "Main Wallet", "type": "checking", "currency": "USD", "balance_cents": 100000},
    )
    assert resp.status_code == 200, f"Create wallet failed: {resp.text}"
    wallet_id = resp.json()["id"]

    resp = await client.post(
        "/api/v1/categories/",
        headers=headers,
        json={"name": "Groceries", "type": "expense", "icon": "shopping_cart"},
    )
    assert resp.status_code == 200, f"Create category failed: {resp.text}"
    category_id = resp.json()["id"]

    resp = await client.post(
        "/api/v1/transactions/",
        headers=headers,
        json={
            "wallet_id": wallet_id,
            "category_id": category_id,
            "type": "expense",
            "amount_cents": 5000,
            "description": "Weekly groceries",
            "transaction_date": str(date.today()),
        },
    )
    assert resp.status_code == 200, f"Create transaction failed: {resp.text}"

    resp = await client.get("/api/v1/dashboard/summary", headers=headers)
    assert resp.status_code == 200, f"Dashboard summary failed: {resp.text}"
    data = resp.json()
    assert data["expense_cents"] >= 5000
    assert data["transaction_count"] >= 1

    resp = await client.get("/api/v1/dashboard/top-categories", headers=headers)
    assert resp.status_code == 200, f"Top categories failed: {resp.text}"
    assert resp.json()["total_expense_cents"] >= 5000

    resp = await client.get(f"/api/v1/wallets/{wallet_id}", headers=headers)
    assert resp.status_code == 200, f"Get wallet failed: {resp.text}"
    data = resp.json()
    assert data["name"] == "Main Wallet"
    assert data["currency"] == "USD"


@pytest.mark.asyncio
async def test_flow_create_and_export_transaction(client):
    """Flow 2: Login → Categoría → Transacción → Export CSV."""
    resp = await client.post(
        "/api/v1/auth/register",
        json={"email": "flow2@test.com", "password": "SecurePass2!", "name": "Flow2"},
    )
    assert resp.status_code == 200, f"Register failed: {resp.text}"
    headers = {"Authorization": f"Bearer {resp.json()['access_token']}"}

    resp = await client.post(
        "/api/v1/wallets/",
        headers=headers,
        json={"name": "Export Wallet", "type": "checking", "currency": "USD", "balance_cents": 50000},
    )
    assert resp.status_code == 200, f"Create wallet failed: {resp.text}"
    wallet_id = resp.json()["id"]

    resp = await client.post(
        "/api/v1/categories/",
        headers=headers,
        json={"name": "Dining", "type": "expense", "icon": "restaurant"},
    )
    assert resp.status_code == 200, f"Create category failed: {resp.text}"
    category_id = resp.json()["id"]

    resp = await client.post(
        "/api/v1/transactions/",
        headers=headers,
        json={
            "wallet_id": wallet_id,
            "category_id": category_id,
            "type": "expense",
            "amount_cents": 15000,
            "description": "Dinner at restaurant",
            "transaction_date": str(date.today()),
        },
    )
    assert resp.status_code == 200, f"Create transaction failed: {resp.text}"

    resp = await client.get("/api/v1/reports/export/csv", headers=headers)
    assert resp.status_code == 200, f"Export CSV failed: {resp.text}"
    assert "text/csv" in resp.headers.get("content-type", "")
    assert "Dinner" in resp.text
    assert any(word in resp.text for word in ["15000", "150"])

    resp = await client.get(
        "/api/v1/reports/export/csv?start_date=2020-01-01&end_date=2030-12-31",
        headers=headers,
    )
    assert resp.status_code == 200, f"Export CSV with dates failed: {resp.text}"
    assert "Dinner" in resp.text


@pytest.mark.asyncio
async def test_flow_ocr_scan_and_manual_movement(client, monkeypatch):
    """Flow 3: Login → OCR Scan (mocked Tesseract) → History → Manual movement."""
    from src.infrastructure.ocr.tesseract_engine import OcrResult

    class MockTesseract:
        def execute(self, image_bytes):
            return OcrResult(
                raw_text="Coffee 4.50\nSandwich 8.00",
                confidence=90.0,
                words=["Coffee", "4.50", "Sandwich", "8.00"],
            )

    monkeypatch.setattr(
        "src.application.use_cases.ocr_use_case.TesseractEngine",
        MockTesseract,
    )

    resp = await client.post(
        "/api/v1/auth/register",
        json={"email": "flow3@test.com", "password": "SecurePass3!", "name": "Flow3"},
    )
    assert resp.status_code == 200, f"Register failed: {resp.text}"
    headers = {"Authorization": f"Bearer {resp.json()['access_token']}"}

    resp = await client.post(
        "/api/v1/wallets/",
        headers=headers,
        json={"name": "Default", "type": "checking", "currency": "USD", "balance_cents": 100000},
    )
    assert resp.status_code == 200, f"Create wallet failed: {resp.text}"
    wallet_id = resp.json()["id"]

    resp = await client.post(
        "/api/v1/categories/",
        headers=headers,
        json={"name": "Food", "type": "expense", "icon": "restaurant"},
    )
    assert resp.status_code == 200, f"Create category failed: {resp.text}"
    category_id = resp.json()["id"]

    img_bytes = _create_test_image()
    resp = await client.post(
        "/api/v1/ocr/scan-receipt",
        headers=headers,
        files={"file": ("receipt.png", img_bytes, "image/png")},
    )
    assert resp.status_code in (200, 422, 500), f"OCR scan unexpected: {resp.status_code}: {resp.text}"

    resp = await client.get("/api/v1/ocr/history", headers=headers)
    assert resp.status_code == 200, f"OCR history failed: {resp.text}"
    assert isinstance(resp.json(), list)

    resp = await client.post(
        "/api/v1/ocr/manual",
        headers=headers,
        json={
            "wallet_id": wallet_id,
            "category_id": category_id,
            "description": "Manual coffee purchase",
            "amount_cents": 450,
            "type": "expense",
        },
    )
    assert resp.status_code == 200, f"Manual movement failed: {resp.text}"
    assert resp.json()["movement_id"] > 0
    assert resp.json()["status"] == "created"


@pytest.mark.asyncio
async def test_flow_budget_alert_cycle(client):
    """Flow 4: Login → Presupuesto → Transacciones → Alertas."""
    resp = await client.post(
        "/api/v1/auth/register",
        json={"email": "flow4@test.com", "password": "SecurePass4!", "name": "Flow4"},
    )
    assert resp.status_code == 200, f"Register failed: {resp.text}"
    headers = {"Authorization": f"Bearer {resp.json()['access_token']}"}

    resp = await client.post(
        "/api/v1/wallets/",
        headers=headers,
        json={"name": "Budget Wallet", "type": "checking", "currency": "USD", "balance_cents": 100000},
    )
    assert resp.status_code == 200, f"Create wallet failed: {resp.text}"
    wallet_id = resp.json()["id"]

    resp = await client.post(
        "/api/v1/categories/",
        headers=headers,
        json={"name": "Entertainment", "type": "expense", "icon": "movie"},
    )
    assert resp.status_code == 200, f"Create category failed: {resp.text}"
    category_id = resp.json()["id"]

    resp = await client.post(
        "/api/v1/budgets/",
        headers=headers,
        json={
            "category_id": category_id,
            "name": "Entertainment Budget",
            "period": "monthly",
            "limit_cents": 1000,
            "notify_at_percentage": 50,
        },
    )
    assert resp.status_code == 200, f"Create budget failed: {resp.text}"
    budget_id = resp.json()["id"]

    resp = await client.post(
        "/api/v1/transactions/",
        headers=headers,
        json={
            "wallet_id": wallet_id,
            "category_id": category_id,
            "type": "expense",
            "amount_cents": 5000,
            "description": "Movie tickets",
            "transaction_date": str(date.today()),
        },
    )
    assert resp.status_code == 200, f"Create transaction failed: {resp.text}"

    resp = await client.get("/api/v1/budgets/alerts", headers=headers)
    assert resp.status_code == 200, f"Budget alerts failed: {resp.text}"
    alerts = resp.json()
    assert isinstance(alerts, list)
    assert len(alerts) >= 1
    assert any(a.get("budget_id") == budget_id for a in alerts)
    alert = next(a for a in alerts if a.get("budget_id") == budget_id)
    assert alert["severity"] == "danger"
    assert "exceeded" in alert["message"].lower()

    resp = await client.get("/api/v1/budgets/", headers=headers)
    assert resp.status_code == 200, f"List budgets failed: {resp.text}"
    budgets = resp.json()
    matching = [b for b in budgets if b["id"] == budget_id]
    assert len(matching) == 1
    assert matching[0]["spent_cents"] >= 5000


@pytest.mark.asyncio
async def test_flow_wallet_delete_cycle(client):
    """Flow 5: Login → Crear wallet → Eliminar → Lista sin la wallet eliminada."""
    resp = await client.post(
        "/api/v1/auth/register",
        json={"email": "flow5@test.com", "password": "SecurePass5!", "name": "Flow5"},
    )
    assert resp.status_code == 200, f"Register failed: {resp.text}"
    headers = {"Authorization": f"Bearer {resp.json()['access_token']}"}

    resp = await client.post(
        "/api/v1/wallets/",
        headers=headers,
        json={"name": "Primary", "type": "checking", "currency": "USD", "balance_cents": 100000, "is_default": True},
    )
    assert resp.status_code == 200, f"Create primary wallet failed: {resp.text}"
    primary_id = resp.json()["id"]

    resp = await client.post(
        "/api/v1/wallets/",
        headers=headers,
        json={"name": "Temp Wallet", "type": "savings", "currency": "USD", "balance_cents": 50000},
    )
    assert resp.status_code == 200, f"Create temp wallet failed: {resp.text}"
    temp_id = resp.json()["id"]

    resp = await client.get("/api/v1/wallets/", headers=headers)
    assert resp.status_code == 200, f"List wallets failed: {resp.text}"
    ids_before = [w["id"] for w in resp.json()]
    assert temp_id in ids_before
    assert primary_id in ids_before

    resp = await client.delete(f"/api/v1/wallets/{temp_id}", headers=headers)
    assert resp.status_code == 200, f"Delete wallet failed: {resp.text}"

    resp = await client.get("/api/v1/wallets/", headers=headers)
    assert resp.status_code == 200, f"List wallets after delete failed: {resp.text}"
    ids_after = [w["id"] for w in resp.json()]
    assert temp_id not in ids_after
    assert primary_id in ids_after

    resp = await client.get(f"/api/v1/wallets/{temp_id}", headers=headers)
    assert resp.status_code == 404, f"Deleted wallet should be 404, got {resp.status_code}"
