<#
Check prerequisites for running the MVP (Windows PowerShell)
This script checks for Node/NPM, Python venv, and required env variables in .env
#>
param()
Set-StrictMode -Version Latest

function Check-Command($name) {
  if (Get-Command $name -ErrorAction SilentlyContinue) { return $true }
  return $false
}

$missing = @()
if (-not (Check-Command node)) { $missing += 'Node.js (node)'; }
if (-not (Check-Command npm)) { $missing += 'npm'; }
if (-not (Check-Command py -ErrorAction SilentlyContinue)) { $missing += 'Python (py)'; }

if ($missing.Count -gt 0) {
  Write-Host "Missing tools:" -ForegroundColor Yellow
  $missing | ForEach-Object { Write-Host " - $_" }
  Write-Host "Please install the missing tools before running the MVP." -ForegroundColor Red
} else {
  Write-Host "All global tools found: node, npm, Python." -ForegroundColor Green
}

# Load env
if (Test-Path .env) {
  Write-Host "Found .env file; checking required keys..." -ForegroundColor Green
  Get-Content .env | ForEach-Object {
    $line = $_.Trim()
    if ($line -match '^(INFURA_KEY|PRIVATE_KEY|WALLET_ADDRESS|ETHERSCAN_KEY|MIN_PROFIT)=') { Write-Host "  OK: $($matches[1])" }
  }
} else {
  Write-Host ".env not found. Copy .env.example -> .env and add your keys (INFURA_KEY, PRIVATE_KEY, etc.)." -ForegroundColor Yellow
}

Write-Host "Done." -ForegroundColor Cyan
Exit 0
