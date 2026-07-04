import pytest


@pytest.mark.asyncio
async def test_analysis_spending(client, auth_headers, test_movement):
    response = await client.get("/api/v1/analysis/spending", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "income_vs_expenses" in data
    assert "category_breakdown" in data


@pytest.mark.asyncio
async def test_analysis_trends(client, auth_headers, test_movement):
    response = await client.get("/api/v1/analysis/trends?months=6", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "monthly_trend" in data
    assert "category_trends" in data


@pytest.mark.asyncio
async def test_analysis_categories(client, auth_headers, test_movement):
    response = await client.get("/api/v1/analysis/categories", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


@pytest.mark.asyncio
async def test_analysis_unauthorized(client):
    response = await client.get("/api/v1/analysis/spending")
    assert response.status_code == 401
