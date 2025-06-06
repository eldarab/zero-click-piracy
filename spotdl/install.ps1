# Check if Python is installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python is not installed or not in PATH. Please install Python 3 before running this script."
}

# Install pipx and spotdl
python -m pip install --user pipx
python -m pipx ensurepath
$pyVer = (python -c "import sys; print(f'Python{sys.version_info.major}{sys.version_info.minor}')")
$scriptPath = "$env:USERPROFILE\AppData\Roaming\Python\$pyVer\Scripts;$env:USERPROFILE\.local\bin"
$env:Path += ";$scriptPath"
pipx install spotdl
