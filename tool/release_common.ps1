Set-StrictMode -Version Latest

function Get-BacklogVaultRepositoryRoot {
    $toolRoot = Split-Path -Parent $PSScriptRoot
    return (Resolve-Path -LiteralPath $toolRoot).Path
}

function Assert-BacklogVaultCommand {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' is not available in PATH."
    }
}

function Invoke-BacklogVaultCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $Command $($Arguments -join ' ')"
    }
}

function Get-BacklogVaultVersion {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)

    $pubspecPath = Join-Path $RepositoryRoot "pubspec.yaml"
    $versionLine = Get-Content -LiteralPath $pubspecPath |
        Where-Object { $_ -match '^version:\s*([^\s]+)' } |
        Select-Object -First 1
    if ($null -eq $versionLine -or $versionLine -notmatch '^version:\s*([^\s]+)') {
        throw "Unable to read version from pubspec.yaml."
    }

    $fullVersion = $Matches[1]
    return [pscustomobject]@{
        Full = $fullVersion
        Name = ($fullVersion -split '\+', 2)[0]
        Code = if ($fullVersion -match '\+(.+)$') { $Matches[1] } else { "" }
    }
}

function Resolve-BacklogVaultRepositoryPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        throw "Use a repository-relative path, not an absolute path: $Path"
    }

    $root = [System.IO.Path]::GetFullPath($RepositoryRoot).TrimEnd([char[]]'\/')
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $root $Path))
    $prefix = $root + [System.IO.Path]::DirectorySeparatorChar
    if (-not $candidate.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escapes the repository: $Path"
    }
    return $candidate
}

function Get-BacklogVaultSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)

    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Remove-BacklogVaultGeneratedPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $resolved = Resolve-BacklogVaultRepositoryPath -RepositoryRoot $RepositoryRoot -Path $Path
    if (-not (Test-Path -LiteralPath $resolved)) {
        return
    }

    $protected = @('.git', 'lib', 'test', 'docs', 'tool', 'android', 'windows', 'pubspec.yaml', 'pubspec.lock')
    $normalized = $Path.Replace('/', '\').TrimEnd('\')
    if ($protected -contains $normalized) {
        throw "Refusing to remove protected repository path: $Path"
    }

    Remove-Item -LiteralPath $resolved -Recurse -Force
}
