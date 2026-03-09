param(
    [string]$DistroName = "altrupets-ubuntu",
    [int]$Processors = 8,
    [string]$Memory = "16GB",
    [string]$Swap = "4GB",
    [string]$VhdSize = "50GB",
    [switch]$InstallIfMissing
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\windows-dev-common.ps1"

Require-Command "wsl.exe"

$configChanged = Ensure-WslConfig -Processors $Processors -Memory $Memory -Swap $Swap
if ($configChanged) {
    Write-Host "[windows-dev] Updated $HOME\.wslconfig" -ForegroundColor Green
    Invoke-ExternalCommand -Description "[windows-dev] Restarting WSL..." -FilePath "wsl.exe" -Arguments @("--shutdown")
}

$distroExists = [bool](Test-WslDistroExists -DistroName $DistroName)
if (-not $distroExists) {
    if (-not $InstallIfMissing) {
        throw "WSL distro '$DistroName' not found. Re-run with -InstallIfMissing or install it manually."
    }

    Invoke-ExternalCommand `
        -Description "[windows-dev] Installing WSL distro $DistroName..." `
        -FilePath "wsl.exe" `
        -Arguments @("--install", "Ubuntu-24.04", "--name", $DistroName, "--version", "2", "--vhd-size", $VhdSize, "--no-launch")
}

Invoke-WslBash -DistroName $DistroName -Description "[windows-dev] Verifying Ubuntu distro..." -Command "cat /etc/os-release"

$keepAlive = Ensure-WslKeepAlive -DistroName $DistroName
Write-Host "[windows-dev] WSL keepalive PID: $($keepAlive.Id)" -ForegroundColor Green
