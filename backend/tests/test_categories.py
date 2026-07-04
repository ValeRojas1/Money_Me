import pytest


@pytest.mark.asyncio
async def test_create_category(client, auth_headers):
    response = await client.post(
        "/api/v1/categories/",
        headers=auth_headers,
        json={"name": "New Category", "type": "expense"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "New Category"
    assert "id" in data


@pytest.mark.asyncio
async def test_create_category_duplicate(client, auth_headers):
    await client.post(
        "/api/v1/categories/",
        headers=auth_headers,
        json={"name": "Duplicate", "type": "expense"},
    )
    response = await client.post(
        "/api/v1/categories/",
        headers=auth_headers,
        json={"name": "Duplicate", "type": "expense"},
    )
    assert response.status_code in (400, 409)


@pytest.mark.asyncio
async def test_create_category_empty_name(client, auth_headers):
    response = await client.post(
        "/api/v1/categories/",
        headers=auth_headers,
        json={"name": "", "type": "expense"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_list_categories(client, auth_headers, test_category):
    response = await client.get("/api/v1/categories/", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert len(data["items"]) > 0


@pytest.mark.asyncio
async def test_delete_system_category_returns_403(client, auth_headers):
    response = await client.get("/api/v1/categories/", headers=auth_headers)
    categories = response.json()
    cats = categories["items"]
    system_cat = next((c for c in cats if c.get("is_system")), None)
    if system_cat:
        cat_id = system_cat["id"]
        response = await client.delete(f"/api/v1/categories/{cat_id}/", headers=auth_headers)
        assert response.status_code in (400, 403, 409)


@pytest.mark.asyncio
async def test_categories_unauthorized(client):
    response = await client.get("/api/v1/categories/")
    assert response.status_code == 401
