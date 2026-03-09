param(
    [string]$Profile = "altrupets-dev",
    [int]$CPUs = 8,
    [int]$MemoryMB = 14000,
    [string]$DiskSize = "50g"
)

$ErrorActionPreference = "Stop"

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $Name"
    }
}

Write-Host "[dev-setup] Verifying prerequisites..." -ForegroundColor Cyan
Require-Command "minikube"
Require-Command "kubectl"
Require-Command "podman"
Require-Command "wsl"

Write-Host "[dev-setup] Ensuring Podman machine is running..." -ForegroundColor Cyan
try {
    $machineList = podman machine list --format json 2>$null | ConvertFrom-Json
    if ($machineList -and $machineList.Count -gt 0) {
        $running = $machineList | Where-Object { $_.Running -eq $true }
        if (-not $running) {
            podman machine start | Out-Null
        }
    }
} catch {
    Write-Host "[dev-setup] Podman machine info unavailable, continuing..." -ForegroundColor Yellow
}

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
