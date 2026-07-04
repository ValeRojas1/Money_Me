import pytest


@pytest.mark.asyncio
async def test_predict_monthly_spending(client, auth_headers, test_movement):
    response = await client.get("/api/v1/predictions/monthly-spending", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "predicted_amount_cents" in data


@pytest.mark.asyncio
async def test_predict_income(client, auth_headers, test_movement):
    response = await client.get("/api/v1/predictions/income", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "predicted_income_cents" in data


@pytest.mark.asyncio
async def test_predict_budget_recommendations(client, auth_headers, test_movement):
    response = await client.get("/api/v1/predictions/budget-recommendations", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "tips" in data


@pytest.mark.asyncio
async def test_predictions_unauthorized(client):
    response = await client.get("/api/v1/predictions/monthly-spending")
    assert response.status_code == 401
