import pytest


@pytest.mark.asyncio
async def test_dashboard_summary(client, auth_headers, test_movement):
    response = await client.get("/api/v1/dashboard/summary", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "income_cents" in data
    assert "expense_cents" in data
    assert "balance_cents" in data
    assert "income_variation" in data


@pytest.mark.asyncio
async def test_dashboard_top_categories(client, auth_headers, test_movement):
    response = await client.get("/api/v1/dashboard/top-categories", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert "total_expense" in data


@pytest.mark.asyncio
async def test_dashboard_monthly_trend(client, auth_headers, test_movement):
    response = await client.get("/api/v1/dashboard/monthly-trend", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "months" in data


@pytest.mark.asyncio
async def test_dashboard_category_breakdown(client, auth_headers, test_movement):
    response = await client.get("/api/v1/dashboard/category-breakdown", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data


@pytest.mark.asyncio
async def test_dashboard_wallet_breakdown(client, auth_headers, test_wallet, test_movement):
    response = await client.get("/api/v1/dashboard/wallet-breakdown", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data


@pytest.mark.asyncio
async def test_dashboard_unauthorized(client):
    response = await client.get("/api/v1/dashboard/summary")
    assert response.status_code == 401
    data = response.json()
    assert "message" in data
