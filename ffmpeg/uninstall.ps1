# Define variables
$extractPath = "$env:USERPROFILE\ffmpeg"
$ffmpegPattern = "ffmpeg*"
$logPrefix = "[zero-click-piracy]"

# Find and remove ffmpeg from PATH
$binPath = ""
if (Test-Path $extractPath) {
    $binPath = Get-ChildItem $extractPath -Directory | Where-Object { $_.Name -like $ffmpegPattern } |
               Select-Object -First 1 | ForEach-Object { "$($_.FullName)\bin" }
}

if ($binPath -and $env:Path -like "*$binPath*") {
    $newPath = ($env:Path -split ';') -ne $binPath -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "$logPrefix Removed ffmpeg from PATH." -ForegroundColor Green
} else {
    Write-Host "$logPrefix ffmpeg not found in PATH." -ForegroundColor Yellow
}

# Delete ffmpeg directory
if (Test-Path $extractPath) {
    Remove-Item -Recurse -Force $extractPath
    Write-Host "$logPrefix ffmpeg directory removed." -ForegroundColor Green
} else {
    Write-Host "$logPrefix ffmpeg directory not found." -ForegroundColor Yellow
}
