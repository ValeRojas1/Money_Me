# Money Me - Setup Local (XAMPP MySQL)
# Run this from the backend/ directory.

Write-Host "=== Money Me - Setup Local ===" -ForegroundColor Cyan

# 1. Install Python dependencies
Write-Host "`n[1/4] Installing Python dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) { Write-Host "pip install failed" -ForegroundColor Red; exit 1 }

# 2. Verify .env exists
if (-not (Test-Path ".env")) {
    Write-Host "`n[WARNING] .env not found. Copying from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "Edit .env to set your DATABASE_URL and SECRET_KEY" -ForegroundColor Yellow
}

# 3. Remind about MySQL database
Write-Host "`n[2/4] Database check:" -ForegroundColor Yellow
Write-Host "  Make sure XAMPP MySQL is running and you created the database:" -ForegroundColor White
Write-Host "  1. Open XAMPP Control Panel -> Start MySQL" -ForegroundColor Gray
Write-Host "  2. Open http://localhost/phpmyadmin" -ForegroundColor Gray
Write-Host "  3. Create database 'money_me' (utf8mb4_unicode_ci)" -ForegroundColor Gray

# 4. Run the backend
Write-Host "`n[3/4] Starting backend..." -ForegroundColor Green
Write-Host "  uvicorn src.main:app --reload --host 0.0.0.0 --port 8000" -ForegroundColor Gray

uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
