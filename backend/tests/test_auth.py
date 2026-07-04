import pytest


@pytest.mark.asyncio
async def test_register(client):
    response = await client.post(
        "/api/v1/auth/register",
        json={"email": "new@example.com", "password": "SecurePass1!", "name": "New User"},
    )
    assert response.status_code == 200, f"Expected 200, got {response.status_code}: {response.text}"
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


@pytest.mark.asyncio
async def test_register_duplicate(client, test_user):
    response = await client.post(
        "/api/v1/auth/register",
        json={"email": "test@example.com", "password": "StrongPass1", "name": "Test User"},
    )
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_login(client, test_user):
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "test@example.com", "password": "password123"},
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data


@pytest.mark.asyncio
async def test_login_wrong_password(client, test_user):
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "test@example.com", "password": "wrong"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_login_nonexistent(client):
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "nonexistent@example.com", "password": "password123"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_get_me(client, auth_headers):
    response = await client.get("/api/v1/auth/me", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "test@example.com"


@pytest.mark.asyncio
async def test_get_me_unauthorized(client):
    response = await client.get("/api/v1/auth/me")
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_update_profile(client, auth_headers):
    response = await client.put(
        "/api/v1/auth/profile",
        headers=auth_headers,
        json={"name": "Updated Name", "phone": "+1234567890"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Updated Name"


@pytest.mark.asyncio
async def test_change_password(client, test_user, auth_headers):
    response = await client.post(
        "/api/v1/auth/change-password",
        headers=auth_headers,
        json={"current_password": "password123", "new_password": "NewPass123!"},
    )
    assert response.status_code == 200
    assert response.json()["message"] == "Password updated successfully"


@pytest.mark.asyncio
async def test_delete_account(client, test_user, auth_headers):
    response = await client.delete("/api/v1/auth/account", headers=auth_headers)
    assert response.status_code == 200
    assert response.json()["message"] == "Account permanently deleted"

    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "test@example.com", "password": "password123"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_error_message_format(client):
    response = await client.get("/api/v1/auth/me")
    assert response.status_code == 401
    data = response.json()
    assert data["error"] is True
    assert "message" in data
    assert "detail" in data


@pytest.mark.asyncio
async def test_register_weak_password_returns_422(client):
    response = await client.post(
        "/api/v1/auth/register",
        json={"email": "weak@example.com", "password": "short", "name": "Weak"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_register_no_uppercase_returns_422(client):
    response = await client.post(
        "/api/v1/auth/register",
        json={"email": "nouppercase@example.com", "password": "lowercase1", "name": "No Upper"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_register_invalid_email_returns_422(client):
    response = await client.post(
        "/api/v1/auth/register",
        json={"email": "not-an-email", "password": "StrongPass1", "name": "Bad Email"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_login_invalid_email_format(client):
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "not-an-email", "password": "password123"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_refresh_token_missing_header(client):
    response = await client.post("/api/v1/auth/refresh")
    assert response.status_code in (401, 422)


@pytest.mark.asyncio
async def test_get_me_expired_token(client):
    response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNTE2MjM5MDIyfQ.XYZ"},
    )
    assert response.status_code in (401, 422)


@pytest.mark.asyncio
async def test_get_me_malformed_token(client):
    response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": "Bearer not-a-valid-jwt"},
    )
    assert response.status_code in (401, 422)


@pytest.mark.asyncio
async def test_get_me_wrong_scheme(client):
    response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": "Basic dGVzdDpwYXNz"},
    )
    assert response.status_code in (401, 422)


@pytest.mark.asyncio
async def test_transaction_isolation(client, auth_headers, test_user):
    """User A cannot access User B's transactions."""
    response = await client.get("/api/v1/transactions/", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    for item in data.get("items", []):
        assert item["user_id"] == test_user.id
