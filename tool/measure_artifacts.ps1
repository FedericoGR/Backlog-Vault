param(
    [string]$OutputJson = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "release_common.ps1")

$repoRoot = Get-BacklogVaultRepositoryRoot
$rows = @()

function Add-ArtifactMeasurement {
    param(
        [Parameter(Mandatory = $true)][string]$Kind,
        [Parameter(Mandatory = $true)][string]$Path
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return
    }
    $item = Get-Item -LiteralPath $Path
    $script:rows += [pscustomobject]@{
        kind = $Kind
        path = [System.IO.Path]::GetRelativePath($repoRoot, $item.FullName).Replace('\', '/')
        bytes = $item.Length
        sha256 = Get-BacklogVaultSha256 -Path $item.FullName
    }
}

Add-ArtifactMeasurement "windows-executable" (Join-Path $repoRoot "build\windows\x64\runner\Release\backlog_vault.exe")
Add-ArtifactMeasurement "android-universal" (Join-Path $repoRoot "build\app\outputs\flutter-apk\app-release.apk")
Add-ArtifactMeasurement "android-armeabi-v7a" (Join-Path $repoRoot "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk")
Add-ArtifactMeasurement "android-arm64-v8a" (Join-Path $repoRoot "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk")
Add-ArtifactMeasurement "android-x86_64" (Join-Path $repoRoot "build\app\outputs\flutter-apk\app-x86_64-release.apk")

$releaseDir = Join-Path $repoRoot "build\windows\x64\runner\Release"
if (Test-Path -LiteralPath $releaseDir -PathType Container) {
    $releaseFiles = @(Get-ChildItem -LiteralPath $releaseDir -Recurse -File)
    $rows += [pscustomobject]@{
        kind = "windows-release-folder"
        path = "build/windows/x64/runner/Release"
        bytes = [int64](($releaseFiles | Measure-Object Length -Sum).Sum)
        sha256 = "directory:$($releaseFiles.Count)-files"
    }
}

Get-ChildItem -LiteralPath (Join-Path $repoRoot "dist") -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in @('.zip', '.apk') } |
    ForEach-Object { Add-ArtifactMeasurement "packaged" $_.FullName }

$rows | Sort-Object kind, path | Format-Table -AutoSize
if (-not [string]::IsNullOrWhiteSpace($OutputJson)) {
    $outputPath = Resolve-BacklogVaultRepositoryPath -RepositoryRoot $repoRoot -Path $OutputJson
    $outputParent = Split-Path -Parent $outputPath
    New-Item -ItemType Directory -Path $outputParent -Force | Out-Null
    $rows | Sort-Object kind, path | ConvertTo-Json -Depth 4 |
        Set-Content -LiteralPath $outputPath -Encoding utf8
}
