param(
    [switch]$SkipBuild,
    [string]$ReleaseLabel = "",
    [string]$OutputDirectory = "dist"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "release_common.ps1")

$repoRoot = Get-BacklogVaultRepositoryRoot
$distDir = Resolve-BacklogVaultRepositoryPath -RepositoryRoot $repoRoot -Path $OutputDirectory
$releaseDir = Join-Path $repoRoot "build\windows\x64\runner\Release"
$version = Get-BacklogVaultVersion -RepositoryRoot $repoRoot
$artifactVersion = if ([string]::IsNullOrWhiteSpace($ReleaseLabel)) {
    $version.Name
} else {
    $ReleaseLabel.Trim().TrimStart('v')
}
$zipName = "BacklogVault-windows-x64-v$artifactVersion.zip"
$zipPath = Join-Path $distDir $zipName
$checksumPath = "$zipPath.sha256"
$stageRelative = Join-Path $OutputDirectory ".package-windows-$PID"
$stageDir = Resolve-BacklogVaultRepositoryPath -RepositoryRoot $repoRoot -Path $stageRelative
$packageRoot = Join-Path $stageDir "Backlog Vault"

Assert-BacklogVaultCommand "flutter"

Push-Location $repoRoot
try {
    if (-not $SkipBuild) {
        Invoke-BacklogVaultCommand "flutter" @("clean")
        Invoke-BacklogVaultCommand "flutter" @("pub", "get")
        Invoke-BacklogVaultCommand "flutter" @("build", "windows", "--release")
    }

    $executable = Join-Path $releaseDir "backlog_vault.exe"
    $dataDir = Join-Path $releaseDir "data"
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
        throw "Windows release executable not found: $executable"
    }
    if (-not (Test-Path -LiteralPath $dataDir -PathType Container)) {
        throw "Windows release data directory not found: $dataDir"
    }

    $forbidden = Get-ChildItem -LiteralPath $releaseDir -Recurse -File |
        Where-Object { $_.Extension -in @('.pdb', '.lib', '.exp', '.log', '.obj') }
    if ($forbidden) {
        throw "Windows Release contains forbidden packaging files: $($forbidden.Name -join ', ')"
    }

    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
    if (Test-Path -LiteralPath $stageDir) {
        Remove-BacklogVaultGeneratedPath -RepositoryRoot $repoRoot -Path $stageRelative
    }
    New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null

    Copy-Item -LiteralPath $executable -Destination $packageRoot
    Get-ChildItem -LiteralPath $releaseDir -Filter "*.dll" -File |
        Copy-Item -Destination $packageRoot
    $nativeManifest = Join-Path $releaseDir "native_assets.json"
    if (Test-Path -LiteralPath $nativeManifest -PathType Leaf) {
        Copy-Item -LiteralPath $nativeManifest -Destination $packageRoot
    }
    Copy-Item -LiteralPath $dataDir -Destination $packageRoot -Recurse

    $sourceFiles = @(Get-ChildItem -LiteralPath $releaseDir -Recurse -File)
    $unexpectedSourceFiles = @($sourceFiles | Where-Object {
        $releaseRelative = [System.IO.Path]::GetRelativePath($releaseDir, $_.FullName).Replace('\', '/')
        -not (
            $releaseRelative -eq 'backlog_vault.exe' -or
            $releaseRelative -match '^[^/]+\.dll$' -or
            $releaseRelative -eq 'native_assets.json' -or
            $releaseRelative.StartsWith('data/')
        )
    })
    if ($unexpectedSourceFiles.Count -gt 0) {
        throw "Windows Release contains files outside the runtime allowlist: $($unexpectedSourceFiles.Name -join ', ')"
    }
    $packageFiles = @(Get-ChildItem -LiteralPath $packageRoot -Recurse -File)
    if ($packageFiles.Count -ne $sourceFiles.Count) {
        throw "Packaged runtime file count ($($packageFiles.Count)) does not match the validated release input ($($sourceFiles.Count))."
    }

    Add-Type -AssemblyName System.IO.Compression
    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }
    if (Test-Path -LiteralPath $checksumPath) {
        Remove-Item -LiteralPath $checksumPath -Force
    }

    $zipStream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::CreateNew)
    try {
        $archive = [System.IO.Compression.ZipArchive]::new(
            $zipStream,
            [System.IO.Compression.ZipArchiveMode]::Create,
            $false
        )
        try {
            $fixedTime = [System.DateTimeOffset]::new(1980, 1, 1, 0, 0, 0, [System.TimeSpan]::Zero)
            foreach ($file in ($packageFiles | Sort-Object FullName)) {
                $relative = [System.IO.Path]::GetRelativePath($stageDir, $file.FullName).Replace('\', '/')
                $entry = $archive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
                $entry.LastWriteTime = $fixedTime
                $entryStream = $entry.Open()
                $inputStream = $file.OpenRead()
                try {
                    $inputStream.CopyTo($entryStream)
                } finally {
                    $inputStream.Dispose()
                    $entryStream.Dispose()
                }
            }
        } finally {
            $archive.Dispose()
        }
    } finally {
        $zipStream.Dispose()
    }

    $readArchive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $fileEntries = @($readArchive.Entries | Where-Object { -not [string]::IsNullOrEmpty($_.Name) })
        if ($fileEntries.Count -ne $packageFiles.Count) {
            throw "ZIP validation failed: expected $($packageFiles.Count) files, found $($fileEntries.Count)."
        }
        foreach ($entry in $fileEntries) {
            if ($entry.FullName -match '(^|/)([^/]+\.(pdb|lib|exp|log|obj))$') {
                throw "ZIP validation found forbidden entry: $($entry.FullName)"
            }
        }
    } finally {
        $readArchive.Dispose()
    }

    $sha256 = Get-BacklogVaultSha256 -Path $zipPath
    "$sha256  $zipName" | Set-Content -LiteralPath $checksumPath -Encoding ascii
    Write-Host "Windows package: $zipPath"
    Write-Host "Runtime files: $($packageFiles.Count)"
    Write-Host "Bytes: $((Get-Item -LiteralPath $zipPath).Length)"
    Write-Host "SHA-256: $sha256"
} finally {
    if (Test-Path -LiteralPath $stageDir) {
        Remove-BacklogVaultGeneratedPath -RepositoryRoot $repoRoot -Path $stageRelative
    }
    Pop-Location
}
