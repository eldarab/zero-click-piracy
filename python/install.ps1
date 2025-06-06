# Check if Python is installed and its version
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$installNeeded = $true

if ($pythonCmd) {
    $versionOutput = python --version 2>&1
    if ($versionOutput -match "Python (\d+)\.(\d+)\.(\d+)") {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        if ($major -gt 3 -or ($major -eq 3 -and $minor -ge 12)) {
            Write-Host "[zero-click-piracy][python] Python $major.$minor is already installed."
            $installNeeded = $false
        } else {
            Write-Host "[zero-click-piracy][python] Python version is too old ($versionOutput). Updating..."
        }
    }
}

if ($installNeeded) {
    Write-Host "[zero-click-piracy][python] Installing Python 3.12.9..."
    $installer = "$env:TEMP\python-install.exe"
    Invoke-WebRequest "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe" -OutFile $installer
    Start-Process -Wait -FilePath $installer -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_pip=1"
    Write-Host "[zero-click-piracy][python] Python 3.12.9 installed and added to PATH."
}
