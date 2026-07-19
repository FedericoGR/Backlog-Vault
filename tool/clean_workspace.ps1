param(
    [switch]$Apply
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "release_common.ps1")

$repoRoot = Get-BacklogVaultRepositoryRoot
$candidates = @(
    "build",
    "dist",
    ".dart_tool",
    "android/build",
    "android/.gradle",
    "windows/flutter/ephemeral",
    ".flutter-plugins",
    ".flutter-plugins-dependencies"
)

Write-Host $(if ($Apply) { "Workspace cleanup APPLY mode" } else { "Workspace cleanup DRY-RUN mode" })
foreach ($relative in $candidates) {
    $resolved = Resolve-BacklogVaultRepositoryPath -RepositoryRoot $repoRoot -Path $relative
    if (-not (Test-Path -LiteralPath $resolved)) {
        continue
    }
    $item = Get-Item -LiteralPath $resolved -Force
    $bytes = if ($item.PSIsContainer) {
        [int64]((Get-ChildItem -LiteralPath $resolved -Recurse -File -Force -ErrorAction SilentlyContinue |
            Measure-Object Length -Sum).Sum)
    } else {
        [int64]$item.Length
    }
    Write-Host "$relative`t$bytes bytes"
    if ($Apply) {
        Remove-BacklogVaultGeneratedPath -RepositoryRoot $repoRoot -Path $relative
    }
}

if (-not $Apply) {
    Write-Host "No files were removed. Re-run with -Apply after reviewing the list."
}
