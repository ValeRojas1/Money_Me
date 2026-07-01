import pytest
from datetime import date


@pytest.mark.asyncio
async def test_list_transactions(client, auth_headers, test_movement):
    response = await client.get("/api/v1/transactions/", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert len(data["items"]) >= 1
    assert data["total"] >= 1


@pytest.mark.asyncio
async def test_create_transaction(client, auth_headers, test_wallet, test_category):
    response = await client.post(
        "/api/v1/transactions/",
        headers=auth_headers,
        json={
            "wallet_id": test_wallet.id,
            "category_id": test_category.id,
            "type": "expense",
            "amount_cents": 5000,
            "description": "New expense",
            "transaction_date": str(date.today()),
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["description"] == "New expense"
    assert data["amount_cents"] == 5000


@pytest.mark.asyncio
async def test_get_transaction(client, auth_headers, test_movement):
    response = await client.get(f"/api/v1/transactions/{test_movement.id}", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == test_movement.id


@pytest.mark.asyncio
async def test_get_transaction_not_found(client, auth_headers):
    response = await client.get("/api/v1/transactions/99999", headers=auth_headers)
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_update_transaction(client, auth_headers, test_movement):
    response = await client.put(
        f"/api/v1/transactions/{test_movement.id}",
        headers=auth_headers,
        json={"description": "Updated description"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["description"] == "Updated description"


@pytest.mark.asyncio
async def test_delete_transaction(client, auth_headers, test_movement):
    response = await client.delete(f"/api/v1/transactions/{test_movement.id}", headers=auth_headers)
    assert response.status_code == 200

    response = await client.get(f"/api/v1/transactions/{test_movement.id}", headers=auth_headers)
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_search_transactions(client, auth_headers, test_movement):
    response = await client.get("/api/v1/transactions/?search=Test", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["total"] >= 1


@pytest.mark.asyncio
async def test_filter_by_type(client, auth_headers, test_movement):
    response = await client.get("/api/v1/transactions/?type=expense", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert len(data["items"]) >= 1
