$scriptSource = "script.ps1"
$iconSource = "logo.ico"
$targetDir = "$env:USERPROFILE\zero-click-piracy"
$targetScript = Join-Path $targetDir "script.ps1"
$desktop = [Environment]::GetFolderPath("Desktop")
$linkPath = Join-Path $desktop "Run Script.lnk"
$iconPath = Join-Path $targetDir "logo.ico"

# Create target directory
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

# Copy script and icon
Copy-Item $scriptSource -Destination $targetScript -Force
Copy-Item $iconSource -Destination $iconPath -Force

# Create shortcut
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($linkPath)
$shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$targetScript`""
$shortcut.IconLocation = $iconPath
$shortcut.Save()
