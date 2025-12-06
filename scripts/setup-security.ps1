<#
  Script: setup-security.ps1
  Purpose: Install and set up local pre-commit hooks and detect-secrets baseline for Windows PowerShell.
  Usage: Run from workspace root in PowerShell as administrator or a regular user.
        .\scripts\setup-security.ps1
#>

Write-Host "Setting up security dev tooling..."

python -m pip install --upgrade pip
pip install pre-commit detect-secrets truffleHog

# Generate baseline (PowerShell `>` writes UTF-16 by default; use Out-File with UTF8)
Write-Host "Generating detect-secrets baseline (file: .secrets.baseline) with UTF-8 encoding"
detect-secrets scan | Out-File -FilePath .secrets.baseline -Encoding utf8
# Remove optional BOM by re-writing the file in UTF-8 (many versions of PowerShell write a BOM)
Write-Host "Normalizing baseline to UTF-8 (no BOM) using Python (if available)..."
if (Get-Command python -ErrorAction SilentlyContinue) {
  python - <<'PY'
import sys
f = '.secrets.baseline'
data = open(f, 'rb').read().decode('utf-8-sig')
open(f, 'wb').write(data.encode('utf-8'))
print('Normalized baseline to UTF-8 (no BOM)')
PY
} else {
  Write-Host "python not available; skipping BOM normalization. If hooks fail, re-run setup with Python available."
}

# Install pre-commit locally
Write-Host "Installing pre-commit hooks..."
pre-commit install

Write-Host "Installed detect-secrets and pre-commit hooks; baseline saved to .secrets.baseline"
Write-Host "Run: pre-commit run --all-files to verify hooks"
