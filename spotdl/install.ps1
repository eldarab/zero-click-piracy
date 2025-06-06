# Check if Python is installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "[zero-click-piracy] Python is not installed or not in PATH."
}
Write-Host "[zero-click-piracy] python is executing from: $(where.exe python)" -ForegroundColor Cyan

# Install spotdl directly
python -m pip install spotdl

# Add Scripts path to PATH for current session
$pyVer = (python -c "import sys; print(f'Python{sys.version_info.major}{sys.version_info.minor}')")
$scriptPath = "$env:USERPROFILE\AppData\Roaming\Python\$pyVer\Scripts"
$env:Path += ";$scriptPath"

# Confirm spotdl is available
if (-not (Get-Command spotdl -ErrorAction SilentlyContinue)) {
    Write-Host "[zero-click-piracy] spotdl was installed but is not in PATH permanently. Add $scriptPath to your system PATH."
} else {
    Write-Host "[zero-click-piracy] spotdl installed successfully."
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
    $scriptSource = "$env:USERPROFILE\zero-click-piracy\spotdl\run.ps1"
    $iconSource   = "$env:USERPROFILE\zero-click-piracy\spotdl\icon.ico"
    $targetDir    = "$env:USERPROFILE\spotdl"
    $DesktopName  = "SpotDL"

    New-Desktop-Icon -scriptSource $scriptSource -iconSource $iconSource -targetDir $targetDir -DesktopName $DesktopName
    Write-Host "[zero-click-piracy] Created '$DesktopName' icon on desktop."
}
catch {
    Write-Host "[zero-click-piracy] Failed to create desktop icon." -ForegroundColor Red
    Write-Error "$_"
}