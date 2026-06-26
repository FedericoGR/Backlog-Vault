param(
    [switch]$SkipBuild,
    [string]$Configuration = "Release",
    [string]$ReleaseLabel = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptRoot "..")).Path
$distDir = Join-Path $repoRoot "dist"
$workDir = Join-Path $distDir "package_windows_work"
$releaseDir = Join-Path $repoRoot "build\windows\x64\runner\$Configuration"
$pubspecPath = Join-Path $repoRoot "pubspec.yaml"

function Test-IsUnderPath {
    param(
        [Parameter(Mandatory = $true)][string]$Child,
        [Parameter(Mandatory = $true)][string]$Parent
    )

    $resolvedParent = (Resolve-Path $Parent).Path.TrimEnd('\')
    $resolvedChild = if (Test-Path $Child) {
        (Resolve-Path $Child).Path
    } else {
        $Child
    }

    return $resolvedChild.StartsWith($resolvedParent, [System.StringComparison]::OrdinalIgnoreCase)
}

Push-Location $repoRoot
try {
    if (-not $SkipBuild) {
        & flutter build windows
        if ($LASTEXITCODE -ne 0) {
            throw "flutter build windows failed with exit code $LASTEXITCODE."
        }
    }

    if (-not (Test-Path (Join-Path $releaseDir "backlog_vault.exe"))) {
        throw "Windows release build not found at $releaseDir. Run flutter build windows first."
    }

    $versionLine = Get-Content $pubspecPath | Where-Object { $_ -match "^version:\s*(.+)$" } | Select-Object -First 1
    $version = if ($versionLine -match "^version:\s*([^\+]+)") { $Matches[1].Trim() } else { "0.1.0" }
    $artifactVersion = if ([string]::IsNullOrWhiteSpace($ReleaseLabel)) { $version } else { $ReleaseLabel.Trim().TrimStart("v") }
    $zipName = "BacklogVault-windows-x64-v$artifactVersion.zip"
    $zipPath = Join-Path $distDir $zipName

    New-Item -ItemType Directory -Force -Path $distDir | Out-Null

    if (Test-Path $workDir) {
        if (-not (Test-IsUnderPath -Child $workDir -Parent $distDir)) {
            throw "Refusing to clean package work directory outside dist: $workDir"
        }
        Remove-Item -LiteralPath $workDir -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $workDir | Out-Null
    $packageRoot = Join-Path $workDir "Backlog Vault"
    New-Item -ItemType Directory -Force -Path $packageRoot | Out-Null

    Copy-Item -Path (Join-Path $releaseDir "*") -Destination $packageRoot -Recurse -Force

    if (Test-Path $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }

    Compress-Archive -Path (Join-Path $packageRoot "*") -DestinationPath $zipPath -Force
    Write-Host "Windows package created: $zipPath"
} finally {
    Pop-Location
}
