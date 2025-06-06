# Collect every cached 3.x EXE-uninstaller (64-bit or 32-bit)
$uninstallers = Get-ItemProperty @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
) |
Where-Object {
    $_.DisplayName -match '^Python 3\.\d+(\.\d+)? \((64|32)-bit\)$' -and
    $_.UninstallString -match '\.exe"?\s*/uninstall'
} |
ForEach-Object {
    $_.UninstallString -replace '^"|"\s*/uninstall$'
}

# Write them all to the screen
$uninstallers | ForEach-Object { Write-Host $_ }
