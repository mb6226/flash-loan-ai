<#
PowerShell helper: run MVP components in separate PowerShell windows
#>
param(
    [string]$venvPath = "./venv/"
)

# Resolve venv activation script
$activate = Join-Path $venvPath "Scripts\Activate.ps1"

if (-Not (Test-Path $activate)) {
    Write-Host "WARNING: Virtual environment activation not found at $activate" -ForegroundColor Yellow
    Write-Host "Make sure to create and activate a virtual env with 'python -m venv venv'" -ForegroundColor Yellow
}

$base = Get-Location

# Start inference in a new window
Start-Process -FilePath powershell -ArgumentList "-NoExit", "-Command & '$activate'; python -m src.ai.inference" -WorkingDirectory $base
Start-Process -FilePath powershell -ArgumentList "-NoExit", "-Command & '$activate'; python -m src.blockchain.listeners" -WorkingDirectory $base

Write-Host "Started MVP components (inference, listeners) in separate PowerShell windows." -ForegroundColor Green
