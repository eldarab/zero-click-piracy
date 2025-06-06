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
#$newDesktopIconPath = "$env:USERPROFILE\zero-click-piracy\new-desktop-icon.ps1"
#if (-not (Test-Path $newDesktopIconPath)) {
#    throw "[zero-click-piracy] Missing required script: $newDesktopIconPath"
#} else {
#    . $newDesktopIconPath
#}

function New-Desktop-Icon {
    param (
        [string]$scriptSource,
        [string]$iconSource,
        [string]$targetDir,
        [string]$DesktopName = $(Split-Path $scriptSource -LeafBase)
    )

    # Define paths
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $targetScript = Join-Path $targetDir (Split-Path $scriptSource -Leaf)
    $iconPath = Join-Path $targetDir (Split-Path $iconSource -Leaf)
    $linkPath = Join-Path $desktopPath ("$DesktopName.lnk")

    if (Test-Path $iconPath) {
        $shortcut.IconLocation = "$iconPath,0"
    } else {
        Write-Warning "Icon not found at $iconPath"
    }

    # Create target directory
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    # Copy script and icon
    Copy-Item $scriptSource -Destination $targetScript -Force
    Copy-Item $iconSource -Destination $iconPath -Force

    # Create shortcut on desktop
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($linkPath)
    $shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$targetScript`""
    $shortcut.IconLocation = $iconPath
    $shortcut.Save()
}


# actually create it
try {
    $scriptSource = "$env:USERPROFILE\PycharmProjects\zero-click-piracy\ytdlp\run.ps1"
    $iconSource   = "$env:USERPROFILE\PycharmProjects\zero-click-piracy\ytdlp\icon.ico"
    $targetDir    = "$env:USERPROFILE\zero-click"
    $DesktopName  = "Download YouTube"

    New-Desktop-Icon -scriptSource $scriptSource -iconSource $iconSource -targetDir $targetDir -DesktopName $DesktopName
    Write-Host "[zero-click-piracy] Created '$DesktopName' icon on desktop."
}
catch {
    Write-Host "[zero-click-piracy] Failed to create desktop icon." -ForegroundColor Red
    Write-Error "$_"
}