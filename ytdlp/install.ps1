# Define yt-dlp path early
$ytPath = "$env:USERPROFILE\yt-dlp"

# Check if yt-dlp is already installed
if (Get-Command yt-dlp -ErrorAction SilentlyContinue) {
    Write-Host "[zero-click-piracy] yt-dlp is already installed and available in PATH."
} else {
    Write-Host "[zero-click-piracy] yt-dlp not found. Installing..."

    New-Item -ItemType Directory -Force -Path $ytPath | Out-Null
    Invoke-WebRequest "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile (Join-Path $ytPath "yt-dlp.exe")

    # Add to PATH if not already present
    if (-not ($env:Path -like "*$ytPath*")) {
        [Environment]::SetEnvironmentVariable("Path", "$($env:Path);$ytPath", "User")
        $env:Path += ";$ytPath"
    }

    Write-Host "[zero-click-piracy] yt-dlp installed and added to PATH."
}

# ─────────────────────────────────────────────────────────────────────────
# import create icon
$newDesktopIconPath = "$env:USERPROFILE\zero-click-piracy\new-desktop-icon.ps1"
if (-not (Test-Path $newDesktopIconPath)) {
    throw "[zero-click-piracy] Missing required script: $newDesktopIconPath"
} else {
    . $newDesktopIconPath
}

# Run the function
try {
    $scriptSource = "$env:USERPROFILE\zero-click-piracy\ytdlp\run.ps1"
    $iconSource   = "$env:USERPROFILE\zero-click-piracy\ytdlp\icon.ico"
    $targetDir    = $ytPath
    $DesktopName  = "YT-DLP"

    New-Desktop-Icon -scriptSource $scriptSource -iconSource $iconSource -targetDir $targetDir -DesktopName $DesktopName
    Write-Host "[zero-click-piracy] Created '$DesktopName' icon on desktop."
}
catch {
    Write-Host "[zero-click-piracy] Failed to create desktop icon."
    Write-Error "$_"
}
