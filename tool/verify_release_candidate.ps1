param(
    [string]$ExpectedVersion = "1.0.0-rc2+7"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "release_common.ps1")

$repoRoot = Get-BacklogVaultRepositoryRoot
$version = Get-BacklogVaultVersion -RepositoryRoot $repoRoot
if ($version.Full -ne $ExpectedVersion) {
    throw "Expected release version '$ExpectedVersion', found '$($version.Full)'."
}

$versionSource = Get-Content -LiteralPath (
    Join-Path $repoRoot "lib\core\version\app_versions.dart"
) -Raw
if ($versionSource -notmatch "appVersionName\s*=\s*'$([regex]::Escape($version.Name))'") {
    throw "appVersionName does not match pubspec version name '$($version.Name)'."
}
if ($versionSource -notmatch 'databaseSchemaVersion\s*=\s*8\s*;') {
    throw "Drift schema must remain 8 for this release candidate."
}

$exportSource = Get-Content -LiteralPath (
    Join-Path $repoRoot "lib\features\import_export\library_export\domain\library_export_document.dart"
) -Raw
if ($exportSource -notmatch 'libraryExportFormatVersion\s*=\s*2\s*;') {
    throw "Library export format must remain 2 for this release candidate."
}

Write-Host "Release candidate version check passed: $($version.Full); schema 8; export format 2."
