# Ask for the Spotify link
$link = Read-Host "Paste the Spotify track / album / playlist link"

# Where to save the download
$outputFolder = Join-Path $env:USERPROFILE "Music"
if (-not (Test-Path $outputFolder)) { New-Item -Type Directory -Path $outputFolder | Out-Null }

# Show the tool locations
Write-Host "spotdl is executing from: $(where.exe spotdl)"  -ForegroundColor Cyan
Write-Host "python is executing from: $(where.exe python)" -ForegroundColor Cyan

# Remember current files so we can spot the new one(s)
$existing = Get-ChildItem -Path $outputFolder -File

# Download
python -m spotdl "$link" --output "$outputFolder"

# Highlight whatever was just added
$newFiles = (Get-ChildItem -Path $outputFolder -File) | Where-Object { $existing -notcontains $_ }
if ($newFiles) {
    $first = $newFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Start-Process "explorer.exe" "/select,`"$($first.FullName)`""
} else {
    Start-Process "explorer.exe" "$outputFolder"
}
