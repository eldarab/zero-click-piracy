# ── Config ───────────────────────────────────────────────────────────────
$RepoUser  = "eldarab"             # GitHub user/org
$RepoName  = "zero-click-piracy"   # Repository name
$Branch    = "main"                # Branch to pull
$ExtractTo = "$env:USERPROFILE"    # Final location (e.g. C:\Users\<you>)
# ─────────────────────────────────────────────────────────────────────────

# Clone this repo
$ZipUrl  = "https://github.com/$RepoUser/$RepoName/archive/refs/heads/$Branch.zip"
$ZipPath = Join-Path $env:TEMP "$RepoName.zip"
$Target  = Join-Path $ExtractTo  $RepoName
$TempDir = "$RepoName-$Branch"    # Folder GitHub puts inside the ZIP

try {
    Write-Host "[zero-click-piracy] Downloading $ZipUrl"
    Invoke-WebRequest $ZipUrl -OutFile $ZipPath -UseBasicParsing -ErrorAction Stop

    if (Test-Path $Target) {
        Write-Host "[zero-click-piracy] Removing existing $Target"
        Remove-Item $Target -Recurse -Force
    }

    Write-Host "[zero-click-piracy] Extracting to $ExtractTo"
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractTo -Force

    Write-Host "[zero-click-piracy] Renaming $TempDir [zero-click-piracy] $RepoName"
    Rename-Item -Path (Join-Path $ExtractTo $TempDir) -NewName $RepoName -Force

    Write-Host "[zero-click-piracy] Done – repo ready at $Target"
}
finally {
    if (Test-Path $ZipPath) { Remove-Item $ZipPath }
}

# Run installers
Set-Location $Target

Get-ChildItem -Path "." -Filter "install.ps1" -Recurse | Where-Object {
    $_.DirectoryName -ne (Get-Location).Path
} | ForEach-Object {
    $component = Split-Path $_.DirectoryName -Leaf
    Write-Host "[zero-click-piracy] Installing $component"
    & $_.FullName
}
Set-Location $env:USERPROFILE
