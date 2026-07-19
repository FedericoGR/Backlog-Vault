param(
    [ValidateSet("All", "Windows", "Android", "AndroidSplits")]
    [string]$Target = "All",
    [switch]$SkipClean,
    [switch]$SkipCodeGeneration
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "release_common.ps1")

$repoRoot = Get-BacklogVaultRepositoryRoot
Assert-BacklogVaultCommand "flutter"
Assert-BacklogVaultCommand "dart"

Push-Location $repoRoot
try {
    if (-not $SkipClean) {
        Invoke-BacklogVaultCommand "flutter" @("clean")
    }
    Invoke-BacklogVaultCommand "flutter" @("pub", "get")

    if (-not $SkipCodeGeneration) {
        Invoke-BacklogVaultCommand "flutter" @("gen-l10n")
        Invoke-BacklogVaultCommand "dart" @("run", "build_runner", "build")
    }

    if ($Target -in @("All", "Windows")) {
        Invoke-BacklogVaultCommand "flutter" @("build", "windows", "--release")
    }
    if ($Target -in @("All", "Android")) {
        Invoke-BacklogVaultCommand "flutter" @("build", "apk", "--release")
    }
    if ($Target -eq "AndroidSplits") {
        Invoke-BacklogVaultCommand "flutter" @("build", "apk", "--release", "--split-per-abi")
    }
} finally {
    Pop-Location
}
