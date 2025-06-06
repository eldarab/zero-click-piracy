function New-Desktop-Icon {
    param (
        [string]$scriptSource,
        [string]$iconSource,
        [string]$targetDir
    )

    # Define paths
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $targetScript = Join-Path $targetDir (Split-Path $scriptSource -Leaf)
    $iconPath = Join-Path $targetDir (Split-Path $iconSource -Leaf)
    $linkPath = Join-Path $desktopPath ((Split-Path $scriptSource -LeafBase) + ".lnk")

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
