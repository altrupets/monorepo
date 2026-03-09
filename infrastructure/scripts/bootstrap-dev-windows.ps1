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

$setupWindowsDevEnv = Join-Path $PSScriptRoot "setup-windows-dev-env.ps1"
$setupPodmanWsl = Join-Path $PSScriptRoot "setup-podman-wsl-connection.ps1"
$runMake = Join-Path $PSScriptRoot "run-make-in-git-bash.ps1"
$devSetup = Join-Path $PSScriptRoot "dev-setup-windows.ps1"

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)][string]$Description,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    Write-Host $Description -ForegroundColor Cyan
    $global:LASTEXITCODE = 0
    & $Action
    if (-not $?) {
        throw "$Description failed."
    }
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed with exit code $LASTEXITCODE."
    }
}

Invoke-Step -Description "[bootstrap-dev] Preparing WSL distro..." -Action {
    & $setupWindowsDevEnv -DistroName $DistroName
}
Invoke-Step -Description "[bootstrap-dev] Preparing Podman connection..." -Action {
    & $setupPodmanWsl -DistroName $DistroName -ConnectionName $ConnectionName
}
Invoke-Step -Description "[bootstrap-dev] Running setup..." -Action {
    & $runMake -Target setup
}
Invoke-Step -Description "[bootstrap-dev] Starting Minikube..." -Action {
    & $devSetup -DistroName $DistroName -ConnectionName $ConnectionName -Profile $Profile -CPUs $CPUs -MemoryMB $MemoryMB -DiskSize $DiskSize
}
Invoke-Step -Description "[bootstrap-dev] Deploying Terraform..." -Action {
    & $runMake -Target dev-terraform-deploy
}
Invoke-Step -Description "[bootstrap-dev] Deploying Gateway..." -Action {
    & $runMake -Target dev-gateway-deploy
}
Invoke-Step -Description "[bootstrap-dev] Deploying Harbor..." -Action {
    & $runMake -Target dev-harbor-deploy
}
Invoke-Step -Description "[bootstrap-dev] Building images..." -Action {
    & $runMake -Target dev-images-build
}
Invoke-Step -Description "[bootstrap-dev] Deploying ArgoCD apps..." -Action {
    & $runMake -Target dev-argocd-push-and-deploy
}
Invoke-Step -Description "[bootstrap-dev] Starting Gateway port-forward..." -Action {
    & $runMake -Target dev-gateway-start
}
