# Config
$RepoUser  = "eldarab"
$RepoName  = "zero-click-piracy"
$Branch    = "main"
$ZipUrl    = "https://gitlab.com/$RepoUser/$RepoName/-/archive/$Branch/$RepoName-$Branch.zip"
$ZipPath   = "$env:TEMP\$RepoName.zip"
$ExtractTo = "$env:USERPROFILE"

# Download ZIP
Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath

# Extract and rename
Expand-Archive -Path $ZipPath -DestinationPath $ExtractTo -Force
Rename-Item -Path "$ExtractTo\$RepoName-$Branch" -NewName $RepoName -Force

# Clean up
Remove-Item $ZipPath
