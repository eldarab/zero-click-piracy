$ytPath = "$env:USERPROFILE\yt-dlp"
New-Item -ItemType Directory -Force -Path $ytPath | Out-Null
Invoke-WebRequest "https://github.com/ytdlp/ytdlp/releases/latest/download/ytdlp.exe" -OutFile "$ytPath\yt-dlp.exe"
[Environment]::SetEnvironmentVariable("Path", "$($env:Path);$ytPath", "User")
$env:Path += ";$ytPath"
