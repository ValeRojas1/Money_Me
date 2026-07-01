import pytest
from datetime import date


@pytest.mark.asyncio
async def test_create_budget(client, auth_headers, test_category):
    response = await client.post(
        "/api/v1/budgets/",
        headers=auth_headers,
        json={
            "category_id": test_category.id,
            "name": "Food budget",
            "period": "monthly",
            "limit_cents": 50000,
            "notify_at_percentage": 80,
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Food budget"
    assert data["limit_cents"] == 50000


@pytest.mark.asyncio
async def test_list_budgets(client, auth_headers, test_category):
    await client.post(
        "/api/v1/budgets/",
        headers=auth_headers,
        json={
            "category_id": test_category.id,
            "name": "Transport",
            "period": "monthly",
            "limit_cents": 30000,
        },
    )
    response = await client.get("/api/v1/budgets/", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1


@pytest.mark.asyncio
async def test_budget_alerts(client, auth_headers, test_category):
    await client.post(
        "/api/v1/budgets/",
        headers=auth_headers,
        json={
            "category_id": test_category.id,
            "name": "Tight budget",
            "period": "monthly",
            "limit_cents": 100,
            "notify_at_percentage": 10,
        },
    )
    response = await client.get("/api/v1/budgets/alerts", headers=auth_headers)
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_delete_budget(client, auth_headers, test_category):
    create_resp = await client.post(
        "/api/v1/budgets/",
        headers=auth_headers,
        json={
            "category_id": test_category.id,
            "name": "To delete",
            "period": "monthly",
            "limit_cents": 10000,
        },
    )
    budget_id = create_resp.json()["id"]

    response = await client.delete(f"/api/v1/budgets/{budget_id}", headers=auth_headers)
    assert response.status_code == 200

    response = await client.delete(f"/api/v1/budgets/{budget_id}", headers=auth_headers)
    assert response.status_code == 404
