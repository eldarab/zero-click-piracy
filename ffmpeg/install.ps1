$ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
$zipPath = "$env:TEMP\ffmpeg.zip"
$extractPath = "$env:USERPROFILE\ffmpeg"
Invoke-WebRequest $ffmpegUrl -OutFile $zipPath
Expand-Archive $zipPath -DestinationPath $extractPath
$binPath = Get-ChildItem $extractPath -Directory | Select-Object -First 1 | ForEach-Object { "$($_.FullName)\bin" }
[Environment]::SetEnvironmentVariable("Path", "$($env:Path);$binPath", "User")
$env:Path += ";$binPath"
