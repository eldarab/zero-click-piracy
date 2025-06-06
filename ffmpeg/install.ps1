# Check if ffmpeg is already installed and in PATH
if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
    Write-Host "[zero-click-piracy] ffmpeg is already installed and available in PATH."
} else {
    Write-Host "[zero-click-piracy] ffmpeg not found. Installing..."

    $ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    $zipPath = "$env:TEMP\ffmpeg.zip"
    $extractPath = "$env:USERPROFILE\ffmpeg"

    # Download and extract
    Invoke-WebRequest $ffmpegUrl -OutFile $zipPath
    Expand-Archive $zipPath -DestinationPath $extractPath -Force

    # Locate bin path
    $binPath = Get-ChildItem $extractPath -Directory | Select-Object -First 1 | ForEach-Object { "$($_.FullName)\bin" }

    # Add to PATH
    [Environment]::SetEnvironmentVariable("Path", "$($env:Path);$binPath", "User")
    $env:Path += ";$binPath"

    Write-Host "[zero-click-piracy] ffmpeg installed and added to PATH."
}
