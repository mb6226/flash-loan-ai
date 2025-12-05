<#
PowerShell script to set up the Python virtual environment (Windows) and install dependencies
Usage:
  .\scripts\setup_env.ps1 -Full
Parameters:
  -Full - installs the full `requirements.txt` (may take long and require tools/versions)
  -Lite - installs `requirements-lite.txt` (faster, recommended for local development/CI)
#>

param(
  [switch]$Full,
  [switch]$Lite
)

Set-StrictMode -Version Latest

function Ensure-PythonVenv {
  $python = Get-Command py -ErrorAction SilentlyContinue
  if ($python) {
    Write-Host "Found python launcher 'py'" -ForegroundColor Green
    # Use py -3.11 if available
    $ver = (& py -3.11 -V) 2>$null
    if ($LASTEXITCODE -eq 0) {
      $pyExec = 'py -3.11'
    } else {
      $pyExec = 'py -3'
    }
  } else {
    $pyExec = 'python'
  }

  # Create virtual env
  & $pyExec -m venv .venv
  Write-Host "Virtual environment created at .\.venv" -ForegroundColor Green
}

function Activate-Venv {
  $activate = Join-Path (Join-Path (Get-Location) '.venv') 'Scripts\Activate.ps1'
  if (Test-Path $activate) {
    Write-Host "Activating venv: $activate" -ForegroundColor Green
    & $activate
  } else {
    Write-Host "Could not find activate script. Run 'py -3.11 -m venv .venv' then activate manually." -ForegroundColor Yellow
  }
}

function Install-Dependencies {
  $pythonExe = Join-Path (Get-Location) '.venv\Scripts\python.exe'
  & $pythonExe -m pip install --upgrade pip setuptools wheel
  if ($Full) {
    Write-Host "Installing full requirements (may be slow)..." -ForegroundColor Green
    & $pythonExe -m pip install -r requirements.txt
  } else {
    Write-Host "Installing lite requirements (faster, recommended for local dev)..." -ForegroundColor Green
    & $pythonExe -m pip install -r requirements-lite.txt --prefer-binary
  }
}

if (-not $Full -and -not $Lite) { $Lite = $true }
Ensure-PythonVenv
Activate-Venv
Install-Dependencies

Write-Host "Setup complete. Activate venv and run npm install if you have Node installed." -ForegroundColor Green
