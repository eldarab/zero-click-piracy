<#  Remove every standalone CPython install (winget, MSI, Microsoft-Store)
    while leaving Anaconda / Miniconda untouched.  #>

# Abort if not elevated
if (-not ([Security.Principal.WindowsPrincipal] `
          [Security.Principal.WindowsIdentity]::GetCurrent()
         ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ">>>> Run this should run in an **elevated** PowerShell window." -ForegroundColor Red; pause; exit 1 }

# --- winget / Store installs -------------------------------------------------
$pkgs = (winget list --name python --output json 2>$null | ConvertFrom-Json).Packages
$pkgs | Where-Object { $_.Id -match '^Python\.Python\.' -and $_.Name -notmatch 'Anaconda|Miniconda' } |
        ForEach-Object { Write-Host "Uninstalling $($_.Name) via winget..."
                          winget uninstall --id $_.Id -h }

# --- classic MSI installers --------------------------------------------------
Get-WmiObject Win32_Product |
  Where-Object { $_.Name -match '^Python \d' -and $_.Name -notmatch 'Anaconda|Miniconda' } |
  ForEach-Object { Write-Host "Uninstalling $($_.Name) via MSI..."
                   Start-Process msiexec.exe -ArgumentList "/x $($_.IdentifyingNumber) /qn" -Wait }

# --- Microsoft-Store appx packages ------------------------------------------
Get-AppxPackage PythonSoftwareFoundation.Python.3* |
  ForEach-Object { Write-Host "Removing Store app $($_.Name)..."
                   Remove-AppxPackage $_ }

# --- verification -----------------------------------------------------------
Write-Host "`nRemaining python on PATH:" -ForegroundColor Cyan
where.exe python 2>$null
