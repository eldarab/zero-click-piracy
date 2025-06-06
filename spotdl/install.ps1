# Check that Python is available
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "[zero-click-piracy] Python is not installed or not in PATH."
}
Write-Host "[zero-click-piracy] python is executing from: $(where.exe python)" -ForegroundColor Cyan

# ── SpotDL: install only if missing ─────────────────────────────────────
if (-not (Get-Command spotdl -ErrorAction SilentlyContinue)) {
    Write-Host "[zero-click-piracy] spotdl not found – installing..." -ForegroundColor Cyan
    python -m pip install --upgrade spotdl
} else {
    Write-Host "[zero-click-piracy] spotdl already installed – skipping install." -ForegroundColor Green
}

# Verify spotdl is callable
if (-not (Get-Command spotdl -ErrorAction SilentlyContinue)) {
    Write-Host "[zero-click-piracy] spotdl installed but not in PATH permanently. Add `"$scriptPath`" to your system PATH."
} else {
    Write-Host "[zero-click-piracy] spotdl is ready." -ForegroundColor Green
}

# ── Create desktop shortcut ────────────────────────────────────────────
$newDesktopIconPath = "$env:USERPROFILE\zero-click-piracy\new-desktop-icon.ps1"
if (-not (Test-Path $newDesktopIconPath)) {
    throw "[zero-click-piracy] Missing required script: $newDesktopIconPath"
}
. $newDesktopIconPath

try {
    $scriptSource = "$env:USERPROFILE\zero-click-piracy\spotdl\run.ps1"
    $iconSource   = "$env:USERPROFILE\zero-click-piracy\spotdl\icon.ico"
    $targetDir    = "$env:USERPROFILE\spotdl"
    $DesktopName  = "SpotDL"

    New-Desktop-Icon -scriptSource $scriptSource -iconSource $iconSource -targetDir $targetDir -DesktopName $DesktopName
    Write-Host "[zero-click-piracy] Created '$DesktopName' icon on desktop."
} catch {
    Write-Host "[zero-click-piracy] Failed to create desktop icon." -ForegroundColor Red
    Write-Error $_
}
