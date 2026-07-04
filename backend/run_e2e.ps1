param (
    [string]$Port = "8000"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$BackendDir = $PSScriptRoot

# Set environment for E2E tests
$env:DATABASE_URL = "sqlite+aiosqlite:///./data/e2e.db"
$env:APP_ENV = "test"

Write-Host "=== MoneyMe E2E Backend ===" -ForegroundColor Cyan
Write-Host "Database: $env:DATABASE_URL" -ForegroundColor Gray
Write-Host "Port:     $Port" -ForegroundColor Gray
Write-Host ""

# Seed database
Write-Host "[1/2] Seeding database..." -ForegroundColor Yellow
Set-Location -LiteralPath $BackendDir
python seed_e2e.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "Seed failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Database seeded successfully!" -ForegroundColor Green
Write-Host ""

# Start server
Write-Host "[2/2] Starting server on port $Port..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop." -ForegroundColor Gray
Write-Host ""
uvicorn src.main:app --host 0.0.0.0 --port $Port --reload
