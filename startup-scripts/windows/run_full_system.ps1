<#
PowerShell helper: run the full system (MVP + mempool) in separate windows
#>
param(
    [string]$venvPath = "./venv/"
)

$activate = Join-Path $venvPath "Scripts\Activate.ps1"

if (-Not (Test-Path $activate)) {
    Write-Host "WARNING: Virtual environment activation not found at $activate" -ForegroundColor Yellow
}

$base = Get-Location

Start-Process -FilePath powershell -ArgumentList "-NoExit", "-Command & '$activate'; python -m src.ai.inference" -WorkingDirectory $base
Start-Process -FilePath powershell -ArgumentList "-NoExit", "-Command & '$activate'; python -m src.blockchain.listeners" -WorkingDirectory $base
Start-Process -FilePath powershell -ArgumentList "-NoExit", "-Command & '$activate'; python -m src.blockchain.mempool_monitor" -WorkingDirectory $base

Write-Host "Started full system components (inference, listeners, mempool_monitor) in separate PowerShell windows." -ForegroundColor Green
