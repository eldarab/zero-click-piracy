# install.ps1 – Zero‑Click Piracy (no‑admin, user‑space installer)
# --------------------------------------------------------------
# 1. Prompts user for install directory (default %USERPROFILE%\zero-click-piracy)
# 2. Prompts user to choose a Music folder (GUI dialog)
# 3. Downloads script.ps1 + script.ico from GitHub
# 4. Creates a desktop shortcut that runs the script with ExecutionPolicy Bypass
# 5. Entirely user‑level‑—no admin rights required

param(
    [string]$RepoUser = "eldarab",
    [string]$RepoName = "zero-click-piracy",
    [string]$Branch   = "main"
)

function Prompt-InstallDir {
    param([string]$DefaultDir)
    $answer = Read-Host "Install directory [`$DefaultDir`] (press Enter to accept)"
    if ([string]::IsNullOrWhiteSpace($answer)) { return $DefaultDir }
    return $answer
}

function Select-FolderDialog {
    [CmdletBinding()]
    param([string]$Description = "Select a folder")

    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = $Description
    $dlg.RootFolder  = [Environment+SpecialFolder]::MyComputer

    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dlg.SelectedPath
    }
    return $null
}

# 1️⃣  Install directory
$defaultDir = Join-Path $env:USERPROFILE 'zero-click-piracy'
$InstallDir = Prompt-InstallDir -DefaultDir $defaultDir

if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# 2️⃣  Music folder selection
$MusicDir = Select-FolderDialog -Description "Choose the folder where downloaded music will go"
if (-not $MusicDir) {
    $MusicDir = Read-Host "Folder dialog cancelled. Type full path to your music folder"
}
if (-not (Test-Path $MusicDir)) {
    Write-Error "The path '$MusicDir' does not exist. Aborting install."; exit 1
}

# 3️⃣  Download payloads
$rawBase = "https://raw.githubusercontent.com/$RepoUser/$RepoName/$Branch"
Write-Host "Downloading script.ps1 & script.ico to $InstallDir …"
Invoke-WebRequest "$rawBase/script.ps1" -OutFile "$InstallDir\script.ps1" -UseBasicParsing
Invoke-WebRequest "$rawBase/script.ico"   -OutFile "$InstallDir\script.ico"  -UseBasicParsing

# 4️⃣  Desktop shortcut
$desktopLnk = Join-Path $env:USERPROFILE 'Desktop/Zero‑Click Piracy.lnk'
$wsh = New-Object -ComObject WScript.Shell
$sc  = $wsh.CreateShortcut($desktopLnk)
$sc.TargetPath  = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$sc.Arguments   = "-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$InstallDir\script.ps1`" `"$MusicDir`""
$sc.WorkingDirectory = $InstallDir
$sc.IconLocation     = "$InstallDir\script.ico,0"
$sc.Save()

Write-Host "`n✅ Installed under: $InstallDir"
Write-Host "🎵 Music folder set to: $MusicDir"
Write-Host "🔗 Shortcut created: $desktopLnk"
Write-Host "Finished. Enjoy zero‑click piracy!"
