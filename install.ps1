# install.ps1 – zero‑click‑piracy bootstrapper (installs **spotdl** + **yt‑dlp**)
# ---------------------------------------------------------------------------------
# • Installs both helper scripts (spotdl.ps1, yt-dlp.ps1) with matching icons.
# • Works from a public GitLab repo (bypasses Cloudflare by falling back to GitLab API).
# • User picks one install directory (default %USERPROFILE%\zero-click-piracy).
# • User picks one media folder (GUI dialog).
# • Creates two desktop shortcuts with -ExecutionPolicy Bypass.
# • Pure user‑space – no admin rights required.
#
# Repo layout:
#   zero-click-piracy/
#   ├─ spotdl/spotdl.ps1  &  spotdl/spotdl.ico
#   └─ yt-dlp/yt-dlp.ps1 &  yt-dlp/yt-dlp.ico

param(
    [string]$InstallDirDefault = "$env:USERPROFILE\zero-click-piracy"
)

# ─────────────────────────── Repo coordinates ───────────────────────────
$RepoUser = "eldarab"
$RepoName = "zero-click-piracy"
$Branch   = "main"

$BaseWebRaw = "https://gitlab.com/$RepoUser/$RepoName/-/raw/$Branch"            # 1st try (may hit CF)
$ProjectId  = [Uri]::EscapeDataString("$RepoUser/$RepoName")                    # for API fallback
$BaseApiRaw = "https://gitlab.com/api/v4/projects/$ProjectId/repository/files"  # 2nd try (API)

# ─────────────────────────── Helpers ───────────────────────────
function Prompt-InstallDir ([string]$DefaultDir) {
    $ans = Read-Host "Install directory [$DefaultDir] (press Enter to accept)"
    if ([string]::IsNullOrWhiteSpace($ans)) { return $DefaultDir }
    return $ans
}

function Select-FolderDialog ([string]$Desc) {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = $Desc
    $dlg.RootFolder  = [Environment+SpecialFolder]::MyComputer
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dlg.SelectedPath
    }
    return $null
}

function Test-CloudflareBlock ($Content) {
    return ($Content -is [string] -and $Content -match 'Enable JavaScript and cookies to continue')
}

function Download-File {
    param(
        [string]$RelativePath,   # e.g. "spotdl/spotdl.ps1"
        [string]$Destination
    )

    # Try raw “-/raw/…” URL first (fastest)
    $url = "$BaseWebRaw/$RelativePath"
    Write-Verbose "Trying $url"
    try {
        $resp = Invoke-WebRequest $url -Headers @{ 'User-Agent' = 'Mozilla/5.0' } -UseBasicParsing -ErrorAction Stop
        if (-not (Test-CloudflareBlock $resp.Content)) {
            $resp.Content | Set-Content -LiteralPath $Destination -Encoding Byte
            return
        }
        Write-Verbose "Cloudflare block detected, falling back to API"
    } catch { Write-Verbose "Raw URL failed ($_). Falling back to API" }

    # Fallback: GitLab REST API (public projects don't need a token)
    $encodedPath = [Uri]::EscapeDataString($RelativePath)
    $apiUrl = "$BaseApiRaw/$encodedPath/raw?ref=$Branch"
    Write-Verbose "Trying API $apiUrl"
    Invoke-WebRequest $apiUrl -Headers @{ 'User-Agent' = 'Mozilla/5.0' } -UseBasicParsing -OutFile $Destination -ErrorAction Stop
}

# ─────────────────────────── 1. install dir ───────────────────────────
$InstallDir = Prompt-InstallDir -DefaultDir $InstallDirDefault
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# ─────────────────────────── 2. media folder ───────────────────────────
$MusicDir = Select-FolderDialog "Choose the folder where downloaded media will go"
if (-not $MusicDir) {
    $MusicDir = Read-Host "Folder dialog cancelled. Type full path to your media folder"
}
if (-not (Test-Path $MusicDir)) {
    Write-Error "The path '$MusicDir' does not exist. Aborting install."; exit 1
}

# ─────────────────────────── 3. download + shortcuts ───────────────────────────
$Tools = @('spotdl','yt-dlp')
$wsh   = New-Object -ComObject WScript.Shell

foreach ($tool in $Tools) {
    $scriptRel = "$tool/$tool.ps1"
    $iconRel   = "$tool/$tool.ico"

    $localScript = Join-Path $InstallDir "$tool.ps1"
    $localIcon   = Join-Path $InstallDir "$tool.ico"

    Write-Host "Downloading $tool payloads …"
    try {
        Download-File -RelativePath $scriptRel -Destination $localScript
        Download-File -RelativePath $iconRel   -Destination $localIcon
    } catch {
        Write-Warning "Failed to download $tool files: $_"; continue
    }

    # Build shortcut label e.g. "Spotdl Launcher"
    $shortcutBase = ($tool -split '-') | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1) }
    $shortcutName = ($shortcutBase -join ' ') + ' Launcher'
    $desktopLnk   = Join-Path $env:USERPROFILE "Desktop\$shortcutName.lnk"

    $sc = $wsh.CreateShortcut($desktopLnk)
    $sc.TargetPath  = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    $sc.Arguments   = "-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$localScript`" `"$MusicDir`""
    $sc.WorkingDirectory = $InstallDir
    $sc.IconLocation     = "$localIcon,0"
    $sc.Save()

    Write-Host "🔗 Shortcut created: $desktopLnk"
}

# ─────────────────────────── 4. done ───────────────────────────
Write-Host "`n✅ Tools installed under: $InstallDir"
Write-Host "🎶 Media folder set to: $MusicDir"
Write-Host "Finished – enjoy effortless downloads!"
