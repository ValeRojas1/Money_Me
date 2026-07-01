import pytest


@pytest.mark.asyncio
async def test_export_csv(client, auth_headers, test_movement):
    response = await client.get("/api/v1/reports/export/csv", headers=auth_headers)
    assert response.status_code == 200
    assert "text/csv" in response.headers.get("content-type", "")
    assert response.text.startswith("Date,Type,Description,Amount,Currency")


@pytest.mark.asyncio
async def test_export_csv_with_dates(client, auth_headers, test_movement):
    response = await client.get(
        "/api/v1/reports/export/csv?start_date=2020-01-01&end_date=2030-12-31",
        headers=auth_headers,
    )
    assert response.status_code == 200
    assert "test" in response.text.lower() or "Date" in response.text


@pytest.mark.asyncio
async def test_export_pdf(client, auth_headers, test_movement):
    response = await client.get("/api/v1/reports/export/pdf", headers=auth_headers)
    assert response.status_code == 200
    assert "application/pdf" in response.headers.get("content-type", "")
    assert len(response.content) > 100


@pytest.mark.asyncio
async def test_export_pdf_unauthorized(client):
    response = await client.get("/api/v1/reports/export/pdf")
    assert response.status_code == 401
    data = response.json()
    assert "message" in data


@pytest.mark.asyncio
async def test_export_empty(client, auth_headers):
    response = await client.get("/api/v1/reports/export/csv", headers=auth_headers)
    assert response.status_code == 200
