param(
    [string]$DistroName = "altrupets-ubuntu",
    [string]$ConnectionName = "altrupets-ubuntu",
    [string]$Profile = "altrupets-dev",
    [int]$CPUs = 8,
    [int]$MemoryMB = 16384,
    [string]$DiskSize = "50g"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\windows-dev-common.ps1"

$setupPodmanWsl = Join-Path $PSScriptRoot "setup-podman-wsl-connection.ps1"

Write-Host "[dev-setup] Verifying prerequisites..." -ForegroundColor Cyan
Require-Command "minikube"
Require-Command "kubectl"
Require-Command "podman"
Require-Command "wsl.exe"

& $setupPodmanWsl -DistroName $DistroName -ConnectionName $ConnectionName -SkipPackageInstall

$null = Ensure-WslKeepAlive -DistroName $DistroName
Invoke-WslBash -DistroName $DistroName -Description "[dev-setup] Ensuring ssh and podman.socket are active..." -Command "systemctl start ssh >/dev/null; systemctl start podman.socket >/dev/null"

Invoke-ExternalCommand -Description "[dev-setup] Verifying Podman remote connection..." -FilePath "podman.exe" -Arguments @("version")

Invoke-ExternalCommand `
    -Description "[dev-setup] Starting Minikube ($Profile) with Podman driver..." `
    -FilePath "minikube.exe" `
    -Arguments @("start", "--profile", $Profile, "--driver=podman", "--cpus=$CPUs", "--memory=$MemoryMB", "--disk-size=$DiskSize")

Invoke-ExternalCommand `
    -Description "[dev-setup] Enabling ingress addon..." `
    -FilePath "minikube.exe" `
    -Arguments @("addons", "enable", "ingress", "--profile", $Profile)

Invoke-ExternalCommand `
    -Description "[dev-setup] Setting kubectl context..." `
    -FilePath "kubectl.exe" `
    -Arguments @("config", "use-context", $Profile)

Invoke-ExternalCommand `
    -Description "[dev-setup] Cluster status..." `
    -FilePath "minikube.exe" `
    -Arguments @("status", "--profile", $Profile)

Invoke-ExternalCommand `
    -Description "[dev-setup] Listing nodes..." `
    -FilePath "kubectl.exe" `
    -Arguments @("get", "nodes", "-o", "wide")

Write-Host "[dev-setup] Done." -ForegroundColor Green
