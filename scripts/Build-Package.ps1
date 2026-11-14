#requires -Version 5.1
[CmdletBinding()]
param([string]$OutputDirectory)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$repoRoot = Split-Path -Parent $PSScriptRoot
$pluginRoot = Join-Path $repoRoot 'openai_questions'
$versionText = [System.IO.File]::ReadAllText((Join-Path $pluginRoot 'version.php'))
$versionMatch = [regex]::Match($versionText, '\$plugin->version\s*=\s*(\d+)\s*;')
if (-not $versionMatch.Success) { throw 'Plugin version was not found.' }
$version = $versionMatch.Groups[1].Value
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $repoRoot 'dist' }
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
[System.IO.Directory]::CreateDirectory($OutputDirectory) | Out-Null
$zipPath = Join-Path $OutputDirectory "block_openai_questions_moodle45_$version.zip"
$checksumPath = Join-Path $OutputDirectory 'SHA256SUMS.txt'
if ((Test-Path -LiteralPath $zipPath) -or (Test-Path -LiteralPath $checksumPath)) {
    throw 'Output already exists. Use a new OutputDirectory to rebuild without overwriting.'
}

[string[]]$files = @(Get-ChildItem -LiteralPath $pluginRoot -File -Recurse -Force | ForEach-Object { $_.FullName })
[Array]::Sort($files, [StringComparer]::Ordinal)
$prefix = $pluginRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
$zipStream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::CreateNew)
$zip = [System.IO.Compression.ZipArchive]::new($zipStream, [System.IO.Compression.ZipArchiveMode]::Create, $false)
try {
    foreach ($file in $files) {
        $relative = $file.Substring($prefix.Length).Replace('\', '/')
        if ($relative -match '(^|/)(\.git|\.env[^/]*|config\.php|backups?)(/|$)|\.(sql|pem|key|log)(\.gz)?$') {
            throw "A non-distributable file was found: $relative"
        }
        $entry = $zip.CreateEntry("openai_questions/$relative", [System.IO.Compression.CompressionLevel]::Optimal)
        $entry.LastWriteTime = [DateTimeOffset]::Parse('1980-01-01T00:00:00+00:00', [Globalization.CultureInfo]::InvariantCulture)
        $entry.ExternalAttributes = ([int]0x81A4 -shl 16)
        $sourceStream = [System.IO.File]::OpenRead($file)
        $entryStream = $entry.Open()
        try { $sourceStream.CopyTo($entryStream) } finally { $entryStream.Dispose(); $sourceStream.Dispose() }
    }
} finally { $zip.Dispose(); $zipStream.Dispose() }

$hash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
$checksumText = $hash + '  ' + [System.IO.Path]::GetFileName($zipPath) + "`n"
[System.IO.File]::WriteAllText($checksumPath, $checksumText, [System.Text.UTF8Encoding]::new($false))
& (Join-Path $PSScriptRoot 'Verify-Package.ps1') -PackagePath $zipPath
if (-not $?) { throw 'Package verification failed.' }
Write-Output "Created $zipPath"
Write-Output "SHA-256 $hash"
