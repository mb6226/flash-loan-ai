Param()
Write-Host "Running MVP tests (Hardhat test for MVP)" -ForegroundColor Cyan
if (-Not (Get-Command npm -ErrorAction SilentlyContinue)) {
  Write-Host "npm not found. Please install Node.js LTS (v18+)." -ForegroundColor Red
  exit 1
}

npm run test:mvp
