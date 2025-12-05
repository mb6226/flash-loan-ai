Param()
Write-Host "Deploying to Goerli (testnet)" -ForegroundColor Cyan
if (-Not (Get-Command npm -ErrorAction SilentlyContinue)) {
  Write-Host "npm not found. Please install Node.js LTS (v18+)." -ForegroundColor Red
  exit 1
}

npm run deploy:testnet
