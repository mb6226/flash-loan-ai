<#
Create a GitHub repository for the current workspace and push the current branch.
Uses the GitHub CLI 'gh' if available. Otherwise uses GitHub REST API with the environment variable GITHUB_TOKEN.
#>

param (
    [switch]$Private,
    [string]$Name = $(Get-Item -Path .).BaseName,
    [string]$Description = "",
    [string]$Org = ""
)

function Ensure-Git {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "git is not installed or not on PATH. Please install Git and re-run this script."
        exit 1
    }
}

Ensure-Git

if (-not (Test-Path -Path '.\.git' -PathType Container)) {
    git init
    git add --all
    git commit -m "chore: initial commit"
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "Using GitHub CLI 'gh' to create the repo..."
    $visibility = if ($Private) { "--private" } else { "--public" }
    if ($Org -ne "") {
        gh repo create "$Org/$Name" $visibility --source=. --remote=origin --push --confirm
    } else {
        gh repo create $Name $visibility --source=. --remote=origin --push --confirm
    }
    Write-Host "Repository created successfully with gh."
    exit 0
}

if (-not $env:GITHUB_TOKEN) {
    Write-Error "GitHub CLI 'gh' not found and GITHUB_TOKEN not set. Install 'gh' or set the GITHUB_TOKEN env var and try again."
    exit 1
}

$privateBool = $Private.IsPresent.ToString().ToLower()
$body = @{ name = $Name; description = $Description; private = $Private.IsPresent } | ConvertTo-Json
$headers = @{ Authorization = "token $($env:GITHUB_TOKEN)"; Accept = 'application/vnd.github+json' }

$apiUrl = if ($Org -ne "") { "https://api.github.com/orgs/$Org/repos" } else { "https://api.github.com/user/repos" }
$res = Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -Body $body -ErrorAction Stop

if ($null -eq $res.clone_url) {
    Write-Error "Failed to create repository via GitHub API. Response: $($res | ConvertTo-Json -Depth 5)"
    exit 1
}

try { git remote remove origin 2>$null } catch { }
git remote add origin $res.clone_url
try { git branch -M main 2>$null } catch { }
git push -u origin main

Write-Host "Repository created and pushed: $($res.clone_url)"
