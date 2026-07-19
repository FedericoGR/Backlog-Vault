param(
    [ValidateSet("Universal", "Split", "Arm64AndUniversal", "All")]
    [string]$Mode = "Arm64AndUniversal",
    [switch]$SkipBuild,
    [switch]$SkipClean,
    [string]$ReleaseLabel = "",
    [string]$OutputDirectory = "dist"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "release_common.ps1")

$repoRoot = Get-BacklogVaultRepositoryRoot
$distDir = Resolve-BacklogVaultRepositoryPath -RepositoryRoot $repoRoot -Path $OutputDirectory
$apkOutput = Join-Path $repoRoot "build\app\outputs\flutter-apk"
$candidateOutput = Join-Path $apkOutput "release-candidates"
$universalCandidate = Join-Path $candidateOutput "app-universal-release.apk"
$arm64Candidate = Join-Path $candidateOutput "app-arm64-release.apk"
$version = Get-BacklogVaultVersion -RepositoryRoot $repoRoot
$artifactVersion = if ([string]::IsNullOrWhiteSpace($ReleaseLabel)) {
    $version.Name
} else {
    $ReleaseLabel.Trim().TrimStart('v')
}

function Get-AndroidArtifactFileName {
    param(
        [Parameter(Mandatory = $true)][string]$Abi,
        [Parameter(Mandatory = $true)][string]$Version
    )

    $architecture = switch ($Abi) {
        "universal" { "universal" }
        "arm64" { "arm64" }
        "arm64-v8a-split" { "arm64-split" }
        default { $Abi }
    }
    return "BacklogVault-android-$architecture-v$Version.apk"
}

Assert-BacklogVaultCommand "flutter"

Push-Location $repoRoot
try {
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null

    if (-not $SkipBuild) {
        if (-not $SkipClean) {
            Invoke-BacklogVaultCommand "flutter" @("clean")
        }
        Invoke-BacklogVaultCommand "flutter" @("pub", "get")
        New-Item -ItemType Directory -Path $candidateOutput -Force | Out-Null

        if ($Mode -in @("Universal", "Arm64AndUniversal", "All")) {
            Invoke-BacklogVaultCommand "flutter" @("build", "apk", "--release")
            $universalSource = Join-Path $apkOutput "app-release.apk"
            if (-not (Test-Path -LiteralPath $universalSource -PathType Leaf)) {
                throw "Universal APK was not produced."
            }
            Copy-Item -LiteralPath $universalSource -Destination $universalCandidate -Force
        }

        if ($Mode -in @("Arm64AndUniversal", "All")) {
            Invoke-BacklogVaultCommand "flutter" @(
                "build", "apk", "--release", "--target-platform", "android-arm64"
            )
            $arm64Source = Join-Path $apkOutput "app-release.apk"
            if (-not (Test-Path -LiteralPath $arm64Source -PathType Leaf)) {
                throw "Arm64 APK was not produced."
            }
            Copy-Item -LiteralPath $arm64Source -Destination $arm64Candidate -Force
        }

        if ($Mode -in @("Split", "All")) {
            Invoke-BacklogVaultCommand "flutter" @("build", "apk", "--release", "--split-per-abi")
        }
    }

    $wanted = [ordered]@{}
    if ($Mode -in @("Universal", "Arm64AndUniversal", "All")) {
        $wanted["universal"] = $universalCandidate
    }
    if ($Mode -in @("Split", "All")) {
        $wanted["armeabi-v7a"] = Join-Path $apkOutput "app-armeabi-v7a-release.apk"
        $wanted["x86_64"] = Join-Path $apkOutput "app-x86_64-release.apk"
    }
    if ($Mode -in @("Arm64AndUniversal", "All")) {
        $wanted["arm64"] = $arm64Candidate
    }
    if ($Mode -eq "Split") {
        $wanted["arm64-v8a-split"] = Join-Path $apkOutput "app-arm64-v8a-release.apk"
    }

    $artifacts = @()
    foreach ($abi in $wanted.Keys) {
        $source = $wanted[$abi]
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "Required APK not found for ${abi}: $source"
        }
        $destination = Join-Path $distDir (Get-AndroidArtifactFileName -Abi $abi -Version $artifactVersion)
        if ($source -ne $destination) {
            Copy-Item -LiteralPath $source -Destination $destination -Force
        }
        $item = Get-Item -LiteralPath $destination
        $artifacts += [pscustomobject]@{
            abi = $abi
            file = $item.Name
            bytes = $item.Length
            sha256 = Get-BacklogVaultSha256 -Path $item.FullName
        }
    }

    $manifestPath = Join-Path $distDir "BacklogVault-android-v$artifactVersion-manifest.json"
    [ordered]@{
        application = "Backlog Vault"
        version = $version.Full
        package = "dev.backlogvault.app"
        versionName = $version.Name
        versionCode = $version.Code
        mode = $Mode
        artifacts = $artifacts
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding utf8

    $checksumPath = Join-Path $distDir "BacklogVault-android-v$artifactVersion.sha256"
    $artifacts | ForEach-Object { "$($_.sha256)  $($_.file)" } |
        Set-Content -LiteralPath $checksumPath -Encoding ascii
    $artifacts | Format-Table abi, file, bytes, sha256 -AutoSize
} finally {
    Pop-Location
}
