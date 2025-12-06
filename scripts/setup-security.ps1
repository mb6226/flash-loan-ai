<#
  Script: setup-security.ps1
  Purpose: Install and set up local pre-commit hooks and detect-secrets baseline for Windows PowerShell.
  Usage: Run from workspace root in PowerShell as administrator or a regular user.
        .\scripts\setup-security.ps1
#>

Write-Host "Setting up security dev tooling..."

python -m pip install --upgrade pip
pip install pre-commit detect-secrets truffleHog

# Generate baseline
Write-Host "Generating detect-secrets baseline (file: .secrets.baseline)"
detect-secrets scan > .secrets.baseline

# Install pre-commit locally
Write-Host "Installing pre-commit hooks..."
pre-commit install

Write-Host "Installed detect-secrets and pre-commit hooks; baseline saved to .secrets.baseline"
Write-Host "Run: pre-commit run --all-files to verify hooks"
