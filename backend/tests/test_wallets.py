import pytest


@pytest.mark.asyncio
async def test_list_wallets(client, auth_headers, test_wallet):
    response = await client.get("/api/v1/wallets/", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1


@pytest.mark.asyncio
async def test_create_wallet(client, auth_headers):
    response = await client.post(
        "/api/v1/wallets/",
        headers=auth_headers,
        json={"name": "Savings", "type": "savings", "currency": "USD", "balance_cents": 50000},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Savings"
    assert "id" in data


@pytest.mark.asyncio
async def test_create_wallet_negative_balance(client, auth_headers):
    response = await client.post(
        "/api/v1/wallets/",
        headers=auth_headers,
        json={"name": "Credit", "type": "credit_card", "currency": "USD", "balance_cents": -100},
    )
    assert response.status_code in (200, 422)


@pytest.mark.asyncio
async def test_get_wallet(client, auth_headers, test_wallet):
    response = await client.get(f"/api/v1/wallets/{test_wallet.id}", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == test_wallet.id


@pytest.mark.asyncio
async def test_get_wallet_not_found(client, auth_headers):
    response = await client.get("/api/v1/wallets/99999", headers=auth_headers)
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_delete_wallet(client, auth_headers, test_wallet):
    response = await client.delete(f"/api/v1/wallets/{test_wallet.id}", headers=auth_headers)
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_wallets_unauthorized(client):
    response = await client.get("/api/v1/wallets/")
    assert response.status_code == 401
