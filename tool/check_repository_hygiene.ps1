$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "release_common.ps1")

$repoRoot = Get-BacklogVaultRepositoryRoot
Assert-BacklogVaultCommand "git"

Push-Location $repoRoot
try {
    $tracked = @(git ls-files)
    $riskyExtensions = @(
        '.apk', '.aab', '.zip', '.7z', '.rar', '.exe', '.dll', '.pdb', '.lib',
        '.exp', '.db', '.sqlite', '.sqlite3', '.log', '.jks', '.keystore',
        '.pfx', '.p12', '.pem', '.key', '.crt', '.cer', '.symbols'
    )
    $risky = @($tracked | Where-Object {
        $extension = [System.IO.Path]::GetExtension($_).ToLowerInvariant()
        $riskyExtensions -contains $extension -or [System.IO.Path]::GetFileName($_) -match '^\.env($|\.)'
    })
    if ($risky.Count -gt 0) {
        Write-Error "Tracked risky artifacts found in $($risky.Count) path(s): $($risky -join ', ')"
    }

    $toolScripts = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot "tool") -Filter "*.ps1" -File)
    $personalPathFiles = @($toolScripts | Where-Object {
        (Get-Content -LiteralPath $_.FullName -Raw) -match '[A-Za-z]:\\Users\\'
    })
    if ($personalPathFiles.Count -gt 0) {
        Write-Error "Personal absolute paths found in release scripts: $($personalPathFiles.Name -join ', ')"
    }

    $strongSecretPatterns = @(
        '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----',
        'github_pat_[A-Za-z0-9_]{40,}',
        'ghp_[A-Za-z0-9]{30,}',
        'AKIA[0-9A-Z]{16}'
    )
    $secretFiles = @()
    foreach ($path in $tracked) {
        if ($path -eq 'test/core/privacy/privacy_redactor_test.dart') {
            continue
        }
        $fullPath = Join-Path $repoRoot $path
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            continue
        }
        $text = Get-Content -LiteralPath $fullPath -Raw -ErrorAction SilentlyContinue
        foreach ($pattern in $strongSecretPatterns) {
            if ($text -match $pattern) {
                $secretFiles += $path
                break
            }
        }
    }
    if ($secretFiles.Count -gt 0) {
        Write-Error "Strong secret pattern found in $($secretFiles.Count) tracked path(s); values suppressed."
    }

    if ($risky.Count -eq 0 -and $personalPathFiles.Count -eq 0 -and $secretFiles.Count -eq 0) {
        Write-Host "Repository hygiene check passed: no tracked release artifact, local data, signing material, personal script path, or strong secret pattern."
    }
} finally {
    Pop-Location
}
