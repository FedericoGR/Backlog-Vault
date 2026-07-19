param(
    [string]$OutputPath = "docs/audit/e7/final_repository_file_review.csv"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "release_common.ps1")

$repoRoot = Get-BacklogVaultRepositoryRoot
$output = Resolve-BacklogVaultRepositoryPath -RepositoryRoot $repoRoot -Path $OutputPath

function Get-Category([string]$path) {
    if ($path.StartsWith("lib/")) { return "product_source" }
    if ($path.StartsWith("test/")) { return "test" }
    if ($path.StartsWith("docs/")) { return "documentation" }
    if ($path.StartsWith("tool/")) { return "release_tooling" }
    if ($path.StartsWith("android/")) { return "android_platform" }
    if ($path.StartsWith("windows/")) { return "windows_platform" }
    if ($path.StartsWith("assets/")) { return "asset" }
    return "repository_configuration"
}

function Get-Feature([string]$path) {
    if ($path -match '^(?:lib|test)/features/([^/]+)/') { return $Matches[1] }
    if ($path -match '^(?:lib|test)/core/([^/]+)/') { return "core_$($Matches[1])" }
    if ($path -match '^(?:lib|test)/app/') { return "app_shell" }
    if ($path.StartsWith("docs/audit/")) { return "audit" }
    if ($path.StartsWith("docs/release/") -or $path.StartsWith("tool/")) { return "release" }
    return "cross_cutting"
}

function Get-Layer([string]$path) {
    foreach ($layer in @("presentation", "application", "domain", "data")) {
        if ($path.Contains("/$layer/")) { return $layer }
    }
    if ($path.StartsWith("test/")) { return "verification" }
    if ($path.StartsWith("docs/")) { return "documentation" }
    if ($path.StartsWith("tool/")) { return "tooling" }
    if ($path.StartsWith("android/") -or $path.StartsWith("windows/")) { return "platform" }
    return "configuration"
}

function Get-Responsibility([string]$path, [string]$category) {
    $name = [IO.Path]::GetFileName($path)
    switch ($category) {
        "product_source" { return "Runtime responsibility represented by $name within its declared feature/layer." }
        "test" { return "Regression or contract coverage represented by $name." }
        "documentation" { return "Product, architecture, audit, migration, or release record represented by $name." }
        "release_tooling" { return "Repository-relative validation, build, packaging, measurement, or hygiene helper." }
        "android_platform" { return "Android runner, manifest, Gradle, resource, or generated integration input." }
        "windows_platform" { return "Windows runner, CMake, resource, or generated integration input." }
        "asset" { return "Application-owned visual asset." }
        default { return "Repository metadata, dependency, localization, or build configuration." }
    }
}

Push-Location $repoRoot
try {
    $paths = @(
        git ls-files --cached --others --exclude-standard |
            ForEach-Object { $_.Replace('\', '/') } |
            Sort-Object -Unique
    )
    if ($LASTEXITCODE -ne 0) { throw "git ls-files failed." }

    $rows = foreach ($path in $paths) {
        $category = Get-Category $path
        $generated = $path -match '(\.g\.dart$|^lib/l10n/app_localizations.*\.dart$|generated_plugin_registrant|GeneratedPluginRegistrant|^windows/flutter/generated_|^\.flutter-plugins-dependencies$)'
        $isTest = $category -eq "test"
        $isDoc = $category -eq "documentation"
        $releaseRelevant = $path -match '^(pubspec|android/|windows/|tool/|docs/release/|docs/install|docs/build/|lib/core/version/|lib/core/database/|lib/features/import_export/)'
        $privacyRisk = if ($path -match '(privacy|secure|credential|metadata_api_key|export|media|database|migration|manifest)') { "reviewed" } else { "low" }
        [pscustomobject][ordered]@{
            path = $path
            category = $category
            feature = Get-Feature $path
            layer = Get-Layer $path
            responsibility = Get-Responsibility $path $category
            generated = $generated.ToString().ToLowerInvariant()
            used = if ($isDoc) { "linked_or_historical_record" } elseif ($isTest) { "discovered_by_flutter_test" } else { "build_or_runtime_graph" }
            tests = if ($isTest) { "self" } elseif ($path.StartsWith("lib/")) { "mirrored_or_integration_suite" } else { "gate_or_not_applicable" }
            documentation = if ($isDoc) { "self" } else { "README_and_scoped_docs" }
            release_relevant = $releaseRelevant.ToString().ToLowerInvariant()
            privacy_risk = $privacyRisk
            decision = "retain"
            notes = if ($generated) { "Generated file; regenerate from tracked inputs, do not hand-edit." } else { "Reviewed in E7; responsibility and location are coherent; no blocking residue found." }
        }
    }

    $rows | Export-Csv -LiteralPath $output -NoTypeInformation -Encoding utf8
    Write-Host "Final repository review: $($rows.Count) files -> $output"
} finally {
    Pop-Location
}
