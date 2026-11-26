# Commit + push, wait for the GitHub Actions build, download the APK to apk\kcal-log.apk
# Usage: .\build-apk.ps1 "what changed"
param([string]$Message = "Update app")
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

git add -A
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m $Message
    if ($LASTEXITCODE) { throw "git commit failed" }
}
$sha = git rev-parse HEAD
git push origin main
if ($LASTEXITCODE) { throw "git push failed" }

# The run for this commit takes a few seconds to show up.
$id = $null
for ($i = 0; $i -lt 30 -and -not $id; $i++) {
    $id = gh run list --commit $sha --workflow build-apk.yml -L 1 --json databaseId --jq '.[0].databaseId'
    if (-not $id) { Start-Sleep -Seconds 5 }
}
if (-not $id) { throw "No workflow run found for commit $sha" }

gh run watch $id --exit-status
if ($LASTEXITCODE) {
    gh run view $id --log-failed | Select-Object -Last 80
    throw "Build failed (run $id)"
}

$apkDir = Join-Path $PSScriptRoot 'apk'
$tmp = Join-Path $apkDir '_download'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
gh run download $id -n kcal-log-apk -D $tmp
if ($LASTEXITCODE) { throw "Artifact download failed" }
Move-Item (Join-Path $tmp 'app-debug.apk') (Join-Path $apkDir 'kcal-log.apk') -Force
Remove-Item $tmp -Recurse -Force
Write-Host "APK ready: $(Join-Path $apkDir 'kcal-log.apk')"
