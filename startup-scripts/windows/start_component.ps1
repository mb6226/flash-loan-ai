<#
Start a single component in a new PowerShell window. Usage:
.\start_component.ps1 -component inference -venvPath .\venv\
#>
param(
    [ValidateSet('inference','listeners','mempool_monitor','all')]
    [string]$component = 'inference',
    [string]$venvPath = "./venv/"
)

$activate = Join-Path $venvPath "Scripts\Activate.ps1"
$base = Get-Location

switch ($component) {
    'inference' { $cmd = "& '$activate'; python -m src.ai.inference" }
    'listeners' { $cmd = "& '$activate'; python -m src.blockchain.listeners" }
    'mempool_monitor' { $cmd = "& '$activate'; python -m src.blockchain.mempool_monitor" }
    'all' { $cmd = "& '$activate'; python -m src.ai.inference; python -m src.blockchain.listeners; python -m src.blockchain.mempool_monitor" }
}

Start-Process -FilePath powershell -ArgumentList "-NoExit","-Command",$cmd -WorkingDirectory $base
Write-Host "Started component: $component" -ForegroundColor Green
