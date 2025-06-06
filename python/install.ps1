# Check if Python is installed and its version
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$installNeeded = $true

if ($pythonCmd) {
    $versionOutput = python --version 2>&1
    if ($versionOutput -match "Python (\d+)\.(\d+)\.(\d+)") {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        if ($major -gt 3 -or ($major -eq 3 -and $minor -ge 12)) {
            Write-Host "[zero-click-piracy] Python $major.$minor is already installed."
            $installNeeded = $false
        } else {
            Write-Host "[zero-click-piracy] Python version is too old ($versionOutput). Updating..."
        }
    }
}

if ($installNeeded) {
    Write-Host "[zero-click-piracy] Installing Python 3.12.9..."
    $installer = "$env:TEMP\python-install.exe"
    Invoke-WebRequest "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe" -OutFile $installer
    Start-Process -Wait -FilePath $installer -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_pip=1"
    Write-Host "[zero-click-piracy] Python 3.12.9 installed and added to PATH."
}

# --- ensure  %APPDATA%\Python\<ver>\Scripts  is on the user-level PATH ---
$pyVer      = python -c "import sys,print(f'Python{sys.version_info.major}{sys.version_info.minor}')"
$scriptPath = "$env:USERPROFILE\AppData\Roaming\Python\$pyVer\Scripts"
$current    = [Environment]::GetEnvironmentVariable('Path','User')
if ($current -notlike "*$scriptPath*") {
    [Environment]::SetEnvironmentVariable('Path', "$current;$scriptPath", 'User')
    Write-Host "[zero-click-piracy] Added $scriptPath to user PATH (reopen shell to use)."
}
