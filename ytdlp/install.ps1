# Check if yt-dlp is already installed
if (Get-Command yt-dlp -ErrorAction SilentlyContinue) {
    Write-Host "[zero-click-piracy] yt-dlp is already installed and available in PATH."
} else {
    Write-Host "[zero-click-piracy] yt-dlp not found. Installing..."

    $ytPath = "$env:USERPROFILE\yt-dlp"
    New-Item -ItemType Directory -Force -Path $ytPath | Out-Null
    Invoke-WebRequest "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile "$ytPath\yt-dlp.exe"

    # Add to PATH
    [Environment]::SetEnvironmentVariable("Path", "$($env:Path);$ytPath", "User")
    $env:Path += ";$ytPath"

    Write-Host "[zero-click-piracy] yt-dlp installed and added to PATH."
}

# ─────────────────────────────────────────────────────────────────────────
# import create icon
$newDesktopIconPath = Join-Path $PSScriptRoot '..\new-desktop-icon.ps1'
if (-not (Test-Path $newDesktopIconPath)) {
    throw "[zero-click-piracy] Missing required script: $newDesktopIconPath"
} else {
    . $newDesktopIconPath
}

# actually create it
$scriptSource = (Resolve-Path ".\run.ps1").Path
$iconSource   = (Resolve-Path ".\ytdlp.ico").Path
$targetDir    = "$env:USERPROFILE\zero-click"
New-Desktop-Icon -scriptSource $scriptSource -iconSource $iconSource -targetDir $targetDir
Write-Host "[zero-click-piracy] Created yt-dlp icon on desktop."