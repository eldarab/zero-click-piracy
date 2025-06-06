$link = Read-Host "Paste the video link"
$outputFolder = Join-Path $env:USERPROFILE "Videos"
Write-Host "yt-dlp is executing from: $(where.exe yt-dlp)" -ForegroundColor Cyan
$title = yt-dlp --get-filename -o "%(title)s" "$link"
$filename = "$title.mp4"
$fullPath = Join-Path $outputFolder $filename
yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "$fullPath" "$link"
Start-Process "explorer.exe" "/select,`"$fullPath`""