$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Require-Command {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $Name"
    }
}

function Invoke-ExternalCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Description,
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @()
    )

    Write-Host $Description -ForegroundColor Cyan
    & $FilePath @Arguments
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "$Description failed with exit code $exitCode"
    }
}

function Test-WslDistroExists {
    param([Parameter(Mandatory = $true)][string]$DistroName)

    $distros = & wsl.exe --list --quiet 2>$null
    if ($LASTEXITCODE -ne 0) {
        return $false
    }

    return $distros | ForEach-Object { $_.Trim([char]0, ' ', "`r", "`n", "`t") } | Where-Object { $_ -eq $DistroName } | Measure-Object | Select-Object -ExpandProperty Count
}

function Invoke-WslBash {
    param(
        [Parameter(Mandatory = $true)][string]$DistroName,
        [Parameter(Mandatory = $true)][string]$Command,
        [string]$Description = "[wsl] Running command..."
    )

    Invoke-ExternalCommand -Description $Description -FilePath "wsl.exe" -Arguments @("-d", $DistroName, "--exec", "bash", "-lc", $Command)
}

function Get-KeepAlivePidFile {
    param([Parameter(Mandatory = $true)][string]$DistroName)

    $dir = Join-Path $env:LOCALAPPDATA "AltruPets"
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }

    return Join-Path $dir ("wsl-keepalive-{0}.pid" -f $DistroName)
}

function Ensure-WslKeepAlive {
    param([Parameter(Mandatory = $true)][string]$DistroName)

    $pidFile = Get-KeepAlivePidFile -DistroName $DistroName
    if (Test-Path $pidFile) {
        $existingPid = (Get-Content $pidFile -Raw).Trim()
        if ($existingPid) {
            $existingProcess = Get-Process -Id $existingPid -ErrorAction SilentlyContinue
            if ($existingProcess) {
                return $existingProcess
            }
        }
    }

    $process = Start-Process -FilePath "wsl.exe" `
        -ArgumentList @("-d", $DistroName, "--exec", "bash", "-lc", "while true; do sleep 3600; done") `
        -WindowStyle Hidden `
        -PassThru

    Start-Sleep -Seconds 1
    Set-Content -Path $pidFile -Value $process.Id -NoNewline
    return $process
}

function Ensure-WslConfig {
    param(
        [Parameter(Mandatory = $true)][int]$Processors,
        [Parameter(Mandatory = $true)][string]$Memory,
        [Parameter(Mandatory = $true)][string]$Swap
    )

    $path = Join-Path $HOME ".wslconfig"
    $desired = @"
[wsl2]
processors=$Processors
memory=$Memory
swap=$Swap
"@

    $current = if (Test-Path $path) { Get-Content -Raw $path } else { "" }
    if ($current -eq $desired) {
        return $false
    }

    Set-Content -Path $path -Value $desired -NoNewline
    return $true
}
