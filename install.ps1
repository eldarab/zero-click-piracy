# install.ps1 – zero‑click‑piracy bootstrapper (spotdl + yt‑dlp)
# ---------------------------------------------------------------------------------
# * Installs **spotdl** and **yt‑dlp** helper scripts with icons.
# * Pulls directly from GitLab REST API first (bypasses Cloudflare),
#   then falls back to the public *raw* URL if the API returns 404.
# * Prompts once for installation directory and once for the media folder.
# * Creates two desktop shortcuts under the current user profile.
# * Never requires admin rights.
#
# GitLab repo layout expected:
#   zero-click-piracy/
#     ├─ spotdl/spotdl.ps1  • spotdl/spotdl.ico
#     └─ yt-dlp/yt-dlp.ps1 • yt-dlp/yt-dlp.ico

[CmdletBinding()]  # so -Verbose works
param(
    [string]$InstallDirDefault = "$env:USERPROFILE\zero-click-piracy"
)

# ────────────────────────  Repo coordinates  ────────────────────────
$RepoUser = "eldarab"
$RepoName = "zero-click-piracy"
$Branch   = "main"
$ProjectId  = [Uri]::EscapeDataString("$RepoUser/$RepoName")
$ApiBase    = "https://gitlab.com/api/v4/projects/$ProjectId/repository/files"
$RawBase    = "https://gitlab.com/$RepoUser/$RepoName/-/raw/$Branch"

# ────────────────────────  Helper functions  ────────────────────────
function Prompt-InstallDir ([string]$DefaultDir) {
    $ans = Read-Host "Install directory [$DefaultDir] (press Enter to accept)"
    return ([string]::IsNullOrWhiteSpace($ans)) ? $DefaultDir : $ans
}

function Select-FolderDialog ([string]$Desc) {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = $Desc
    $dlg.RootFolder  = [Environment+SpecialFolder]::MyComputer
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $dlg.SelectedPath }
    return $null
}

function Get-ApiRawUrl([string]$RelativePath) {
    $encoded = [Uri]::EscapeDataString($RelativePath)
    return "$ApiBase/$encoded/raw?ref=$Branch"
}

function Download-File {
    param(
        [string]$RelativePath,  # e.g. "spotdl/spotdl.ps1"
        [string]$Destination
    )

    # 1️⃣  Try GitLab REST API (rarely challenged by Cloudflare)
    $apiUrl = Get-ApiRawUrl $RelativePath
    Write-Verbose "API -> $apiUrl"
    try {
        Invoke-WebRequest $apiUrl -Headers @{ 'User-Agent'='Mozilla/5.0' } -OutFile $Destination -ErrorAction Stop -UseBasicParsing
        return $true
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -ne 404) {
            Write-Verbose "API download failed: $_.Exception.Message"
        } else {
            Write-Verbose "API returned 404, will try raw URL"
        }
    }

    # 2️⃣  Fallback to “/-/raw/…” (may face CF). If blocked, throw.
    $rawUrl = "$RawBase/$RelativePath"
    Write-Verbose "RAW -> $rawUrl"
    try {
        $resp = Invoke-WebRequest $rawUrl -Headers @{ 'User-Agent'='Mozilla/5.0' } -ErrorAction Stop -UseBasicParsing
        if ($resp.RawContentLength -lt 1000 -and $resp.Content -match 'Enable JavaScript and cookies') {
            throw "Cloudflare challenge detected at $rawUrl"
        }
        $resp.Content | Set-Content -LiteralPath $Destination -Encoding Byte
        return $true
    } catch {
        Write-Verbose "Raw download failed: $_"
        return $false
    }
}

# ──────────────────────── 1. Installation directory  ────────────────────────
$InstallDir = Prompt-InstallDir -DefaultDir $InstallDirDefault
if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null }

# ──────────────────────── 2. Media folder  ────────────────────────
$MusicDir = Select-FolderDialog "Choose the folder where downloaded media will go"
if (-not $MusicDir) { $MusicDir = Read-Host "Folder dialog cancelled. Type full path to your media folder" }
if (-not (Test-Path $MusicDir)) { Write-Error "Path '$MusicDir' does not exist."; exit 1 }

# ──────────────────────── 3. Download + shortcuts  ────────────────────────
$Tools = @('spotdl','yt-dlp')
$wsh = New-Object -ComObject WScript.Shell

foreach ($tool in $Tools) {
    $scriptRel = "$tool/$tool.ps1"
    $iconRel   = "$tool/$tool.ico"
    $localScript = Join-Path $InstallDir "$tool.ps1"
    $localIcon   = Join-Path $InstallDir "$tool.ico"

    Write-Host "→ $tool : downloading files …" -ForegroundColor Cyan
    if (-not (Download-File -RelativePath $scriptRel -Destination $localScript -Verbose:$VerbosePreference)) {
        Write-Warning "Failed to download $scriptRel. Skipping $tool."
        continue
    }
    if (-not (Download-File -RelativePath $iconRel -Destination $localIcon  -Verbose:$VerbosePreference)) {
        Write-Warning "Failed to download $iconRel. Skipping $tool icon."
    }

    # Build shortcut name (e.g. "Spotdl Launcher")
    $shortcutLabel = ($tool -split '-') | ForEach-Object { $_.Substring(0,1).ToUpper()+$_.Substring(1) } | Join-String ' '
    $shortcutLabel += ' Launcher'
    $desktopLnk = Join-Path $env:USERPROFILE "Desktop\$shortcutLabel.lnk"

    $sc = $wsh.CreateShortcut($desktopLnk)
    $sc.TargetPath  = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    $sc.Arguments   = "-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$localScript`" `"$MusicDir`""
    $sc.WorkingDirectory = $InstallDir
    if (Test-Path $localIcon) { $sc.IconLocation = "$localIcon,0" }
    $sc.Save()
    Write-Host "   ✔ Shortcut: $desktopLnk" -ForegroundColor Green
}

# ──────────────────────── 4. Summary  ────────────────────────
Write-Host "`n✅ Tools installed under: $InstallDir" -ForegroundColor Green
Write-Host "🎶 Media folder set to: $MusicDir" -ForegroundColor Green
Write-Host "Done – happy downloading! (Tip: re‑run with -Verbose for detailed logs)"
