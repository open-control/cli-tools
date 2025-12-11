# Open Control CLI Tools - Install script (Windows PowerShell)
# Adds cli-tools/bin to user PATH

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinDir = Join-Path $ScriptDir "bin"

Write-Host "Open Control CLI Tools Installer" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Bin directory: $BinDir"
Write-Host ""

# Get current user PATH
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if already in PATH
if ($UserPath -like "*$BinDir*") {
    Write-Host "Already in PATH. Nothing to do." -ForegroundColor Green
    exit 0
}

# Add to PATH
$NewPath = "$UserPath;$BinDir"
[Environment]::SetEnvironmentVariable("Path", $NewPath, "User")

Write-Host "Added to user PATH" -ForegroundColor Green
Write-Host ""
Write-Host "Restart your terminal to use the commands:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  oc-build   - Build project"
Write-Host "  oc-upload  - Build and upload"
Write-Host "  oc-monitor - Build, upload, and monitor"
Write-Host "  oc-clean   - Clean build files"
Write-Host ""
Write-Host "Note: On Windows, run these commands in Git Bash or WSL." -ForegroundColor Yellow
