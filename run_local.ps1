# Money Me - Run Local with XAMPP
# Prerequisites: XAMPP installed, Python 3.11+, Flutter SDK

param(
    [switch]$FrontendOnly,
    [switch]$BackendOnly
)

function Start-Backend {
    Write-Host "`n=== Starting Backend (FastAPI) ===" -ForegroundColor Cyan
    Set-Location -Path "$PSScriptRoot\backend"
    
    if (-not (Test-Path ".env")) {
        Write-Host "ERROR: backend\.env not found. Copy .env.example to .env first." -ForegroundColor Red
        return
    }

    # Activate venv if exists, otherwise use system Python
    if (Test-Path ".venv\Scripts\Activate.ps1") {
        & ".venv\Scripts\Activate.ps1"
    }
    
    Write-Host "Starting uvicorn on http://localhost:8000 ..." -ForegroundColor Green
    uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
}

function Start-Frontend {
    Write-Host "`n=== Starting Frontend (Flutter) ===" -ForegroundColor Cyan
    Set-Location -Path "$PSScriptRoot"
    
    Write-Host "Starting Flutter web on http://localhost:3000 ..." -ForegroundColor Green
    flutter run -d chrome --web-port 3000
}

# Verify XAMPP MySQL is accessible
function Test-MySQL {
    try {
        $conn = New-Object System.Data.SqlClient.SqlConnection
        # Quick TCP test on port 3306
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect("127.0.0.1", 3306)
        $tcp.Close()
        return $true
    } catch {
        return $false
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Money Me - Local Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (-not $BackendOnly) {
    # Check MySQL
    if (-not (Test-MySQL)) {
        Write-Host "`n[!] MySQL (XAMPP) not detected on port 3306." -ForegroundColor Yellow
        Write-Host "    Start MySQL from XAMPP Control Panel first." -ForegroundColor Yellow
    } else {
        Write-Host "`n[OK] MySQL is running" -ForegroundColor Green
    }
}

if ($BackendOnly) {
    Start-Backend
} elseif ($FrontendOnly) {
    Start-Frontend
} else {
    # Start backend in background, then frontend
    $backendJob = Start-Job -ScriptBlock {
        Set-Location -Path "$using:PSScriptRoot\backend"
        if (Test-Path ".venv\Scripts\Activate.ps1") {
            & ".venv\Scripts\Activate.ps1"
        }
        uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
    }
    Start-Sleep 3
    Start-Frontend
    Stop-Job $backendJob
    Remove-Job $backendJob
}
