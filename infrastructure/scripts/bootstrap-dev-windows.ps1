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

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$setupWindowsDevEnv = Join-Path $PSScriptRoot "setup-windows-dev-env.ps1"
$setupPodmanWsl = Join-Path $PSScriptRoot "setup-podman-wsl-connection.ps1"
$runMake = Join-Path $PSScriptRoot "run-make-in-git-bash.ps1"
$devSetup = Join-Path $PSScriptRoot "dev-setup-windows.ps1"

& $setupWindowsDevEnv -DistroName $DistroName
& $setupPodmanWsl -DistroName $DistroName -ConnectionName $ConnectionName
& $runMake -Target setup
& $devSetup -DistroName $DistroName -ConnectionName $ConnectionName -Profile $Profile -CPUs $CPUs -MemoryMB $MemoryMB -DiskSize $DiskSize
& $runMake -Target dev-terraform-deploy
& $runMake -Target dev-gateway-deploy
& $runMake -Target dev-harbor-deploy
& $runMake -Target dev-images-build
& $runMake -Target dev-argocd-push-and-deploy
& $runMake -Target dev-gateway-start
