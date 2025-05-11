# install.ps1 – zero‑click‑piracy bootstrapper (installs **spotdl** + **yt‑dlp**)
# ---------------------------------------------------------------------------------
# • Installs *both* helper scripts (spotdl.ps1, yt-dlp.ps1) with matching icons.
# • Drops everything under a user‑chosen directory (default %USERPROFILE%\zero-click-piracy).
# • Asks once for a media folder (Music/Downloads/wherever) via GUI dialog.
# • Creates two desktop shortcuts that launch the tools with `-ExecutionPolicy Bypass`.
# • Pure user‑space → **never needs admin rights**.
#
# Repo layout assumed (GitLab):
#   zero-click-piracy/
#   ├─ spotdl/spotdl.ps1
#   ├─ spotdl/spotdl.ico
#   ├─ yt-dlp/yt-dlp.ps1
#   └─ yt-dlp/yt-dlp.ico

param(
    [string]$InstallDirDefault = "$env:USERPROFILE\zero-click-piracy"
)

# GitLab repo coordinates (hard‑wired)
$RepoUser = "eldarab"
$RepoName = "zero-click-piracy"
$Branch   = "main"
$RawBase  = "https://gitlab.com/$RepoUser/$RepoName/-/raw/$Branch"

# ───────────────────────────── 1. Pick install directory ─────────────────────────────
function Prompt-InstallDir([string]$DefaultDir) {
    $ans = Read-Host "Install directory [$DefaultDir] (press Enter to accept)"
    if ([string]::IsNullOrWhiteSpace($ans)) { return $DefaultDir }
    return $ans
}

$InstallDir = Prompt-InstallDir -DefaultDir $InstallDirDefault
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# ───────────────────────────── 2. Pick media folder ─────────────────────────────
function Select-FolderDialog([string]$Desc) {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = $Desc
    $dlg.RootFolder  = [Environment+SpecialFolder]::MyComputer
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dlg.SelectedPath
    }
    return $null
}

$MusicDir = Select-FolderDialog "Choose the folder where downloaded media will go"
if (-not $MusicDir) {
    $MusicDir = Read-Host "Folder dialog cancelled. Type full path to your media folder"
}
if (-not (Test-Path $MusicDir)) {
    Write-Error "The path '$MusicDir' does not exist. Aborting install."; exit 1
}

# ───────────────────────────── 3. Download + shortcut per tool ─────────────────────────────
$Tools = @("spotdl", "yt-dlp")
$wsh   = New-Object -ComObject WScript.Shell

foreach ($tool in $Tools) {
    $RemoteScript = "$RawBase/$tool/$tool.ps1"
    $RemoteIcon   = "$RawBase/$tool/$tool.ico"
    $LocalScript  = Join-Path $InstallDir "$tool.ps1"
    $LocalIcon    = Join-Path $InstallDir "$tool.ico"

    Write-Host "Downloading $tool payloads …"
    Invoke-WebRequest $RemoteScript -OutFile $LocalScript -UseBasicParsing
    Invoke-WebRequest $RemoteIcon   -OutFile $LocalIcon  -UseBasicParsing

    # Shortcut name: "Spotdl Launcher" | "Yt Dlp Launcher"
    $ShortcutBase = ($tool -split '-') | ForEach-Object { $_.Substring(0,1).ToUpper()+$_.Substring(1) } | ForEach-Object { $_ }
    $ShortcutName = ($ShortcutBase -join ' ') + ' Launcher'
    $DesktopLnk   = Join-Path $env:USERPROFILE "Desktop\$ShortcutName.lnk"

    $sc = $wsh.CreateShortcut($DesktopLnk)
    $sc.TargetPath  = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    $sc.Arguments   = "-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$LocalScript`" `"$MusicDir`""
    $sc.WorkingDirectory = $InstallDir
    $sc.IconLocation     = "$LocalIcon,0"
    $sc.Save()

    Write-Host "🔗 Shortcut created: $DesktopLnk"
}

# ───────────────────────────── 4. Success message ─────────────────────────────
Write-Host "`n✅ Tools installed under: $InstallDir"
Write-Host "🎶 Media folder set to: $MusicDir"
Write-Host "Finished – enjoy effortless downloads!"
