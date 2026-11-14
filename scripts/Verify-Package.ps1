#requires -Version 5.1
[CmdletBinding()]
param([string]$PackagePath)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$repoRoot = Split-Path -Parent $PSScriptRoot
$pluginRoot = Join-Path $repoRoot 'openai_questions'
$versionText = [System.IO.File]::ReadAllText((Join-Path $pluginRoot 'version.php'))
$version = [regex]::Match($versionText, '\$plugin->version\s*=\s*(\d+)\s*;').Groups[1].Value
if (-not $PackagePath) { $PackagePath = Join-Path $repoRoot "dist/block_openai_questions_moodle45_$version.zip" }
$PackagePath = [System.IO.Path]::GetFullPath($PackagePath)
$checksumPath = Join-Path ([System.IO.Path]::GetDirectoryName($PackagePath)) 'SHA256SUMS.txt'
if (-not (Test-Path -LiteralPath $checksumPath -PathType Leaf)) { throw 'SHA256SUMS.txt is missing.' }
$checksumPattern = '^([A-Fa-f0-9]{64})  ' + [regex]::Escape([System.IO.Path]::GetFileName($PackagePath)) + '$'
$checksumLines = @([System.IO.File]::ReadAllLines($checksumPath) | Where-Object { $_ -match $checksumPattern })
if ($checksumLines.Count -ne 1) { throw 'The ZIP needs exactly one matching checksum entry.' }
$expectedZipHash = [regex]::Match($checksumLines[0], $checksumPattern).Groups[1].Value.ToLowerInvariant()
$actualZipHash = (Get-FileHash -LiteralPath $PackagePath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualZipHash -ne $expectedZipHash) { throw 'ZIP checksum does not match SHA256SUMS.txt.' }
$expectedRuntime = Get-Content -LiteralPath (Join-Path $repoRoot 'tests/verified-runtime-sha256.json') -Raw | ConvertFrom-Json
$archive = [System.IO.Compression.ZipFile]::OpenRead($PackagePath)
$entryNames = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
try {
    foreach ($entry in $archive.Entries) {
        $name = $entry.FullName
        if (-not $name.StartsWith('openai_questions/', [StringComparison]::Ordinal) -or
            $name.Contains('\') -or $name.Contains(':') -or $name -match '(^|/)\.\.(/|$)') {
            throw "Invalid ZIP path: $name"
        }
        if (-not $entryNames.Add($name)) { throw "Duplicate ZIP path: $name" }
        if ($name -match '(^|/)(\.git|\.env[^/]*|config\.php|backups?)(/|$)|\.(sql|pem|key|log)(\.gz)?$') {
            throw "Non-distributable ZIP entry: $name"
        }
        if ($name.EndsWith('/')) { continue }
        $relative = $name.Substring('openai_questions/'.Length)
        $sourcePath = Join-Path $pluginRoot $relative
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Unexpected ZIP file: $name" }
        $entryStream = $entry.Open()
        try { $entryHash = (Get-FileHash -InputStream $entryStream -Algorithm SHA256).Hash.ToLowerInvariant() } finally { $entryStream.Dispose() }
        $sourceHash = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($entryHash -ne $sourceHash) { throw "Source and ZIP differ: $name" }
        if ($relative -match '\.(php|js|md|txt|css)$') {
            $textStream = [System.IO.StreamReader]::new($entry.Open())
            try { $entryText = $textStream.ReadToEnd() } finally { $textStream.Dispose() }
            if ($entryText -match 'sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----') {
                throw "Potential credential found in: $name"
            }
        }
    }
    $sourceFiles = @(Get-ChildItem -LiteralPath $pluginRoot -File -Recurse -Force)
    $zipFiles = @($archive.Entries | Where-Object { -not $_.FullName.EndsWith('/') })
    if ($sourceFiles.Count -ne $zipFiles.Count) { throw 'ZIP file count differs from source.' }
    foreach ($required in @('version.php', 'block_openai_questions.php', 'api/question.php', 'lib.js', 'lang/en/block_openai_questions.php', 'COPYING.txt')) {
        if (-not $entryNames.Contains("openai_questions/$required")) { throw "Required file is missing: $required" }
    }
    foreach ($property in $expectedRuntime.files.PSObject.Properties) {
        $actual = (Get-FileHash -LiteralPath (Join-Path $pluginRoot $property.Name) -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actual -ne $property.Value) { throw "Verified runtime file changed: $($property.Name)" }
    }
    if ($versionText -notmatch '\$plugin->component\s*=\s*''block_openai_questions''\s*;' -or
        $versionText -notmatch '\$plugin->requires\s*=\s*2024100700\s*;' -or
        [long]$version -le 2023121500) { throw 'Plugin metadata is invalid.' }
    $license = Join-Path $pluginRoot 'COPYING.txt'
    if ((Get-FileHash -LiteralPath $license).Hash -ne (Get-FileHash -LiteralPath (Join-Path $repoRoot 'LICENSE')).Hash) { throw 'GPL license copies differ.' }
    Write-Output "PASS ZIP checksum, structure, source contents, runtime hashes, metadata and credential-pattern check ($($zipFiles.Count) files)."
} finally { $archive.Dispose() }
