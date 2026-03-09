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

Write-Host "[dev-setup] Starting Minikube ($Profile) with Podman driver..." -ForegroundColor Cyan
minikube start --profile $Profile --driver=podman --cpus=$CPUs --memory=$MemoryMB --disk-size=$DiskSize

Write-Host "[dev-setup] Enabling ingress addon..." -ForegroundColor Cyan
minikube addons enable ingress --profile $Profile | Out-Null

Write-Host "[dev-setup] Setting kubectl context..." -ForegroundColor Cyan
kubectl config use-context "$Profile" | Out-Null

Write-Host "[dev-setup] Cluster status:" -ForegroundColor Cyan
minikube status --profile $Profile
kubectl get nodes -o wide

Write-Host "[dev-setup] Done." -ForegroundColor Green
