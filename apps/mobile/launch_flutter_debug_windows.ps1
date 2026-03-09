param(
    [ValidateSet("desktop", "emulator", "device")]
    [string]$Target = "desktop",
    [switch]$NoClean
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $Name"
    }
}

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Description,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    Write-Host "[mobile] $Description" -ForegroundColor Cyan
    & $Action
    if ($LASTEXITCODE -ne 0) {
        throw "Step failed: $Description (exit code $LASTEXITCODE)"
    }
}

Require-Command "flutter"
Require-Command "dart"

$logLevel = "1"
$passwordSalt = $env:PASSWORD_SALT
if ([string]::IsNullOrWhiteSpace($passwordSalt)) {
    $passwordSalt = "default_salt_fallback"
}

Invoke-Step -Description "Enabling Windows desktop support..." -Action {
    flutter config --enable-windows-desktop | Out-Null
}

if (-not $NoClean) {
    Invoke-Step -Description "flutter clean" -Action {
        flutter clean
    }
}

Invoke-Step -Description "flutter pub get" -Action {
    flutter pub get
}

switch ($Target) {
    "desktop" {
        Invoke-Step -Description "Running Flutter on Windows desktop..." -Action {
            flutter run -d windows --dart-define=LOG_LEVEL=$logLevel --dart-define=PASSWORD_SALT=$passwordSalt
        }
    }
    "emulator" {
        Invoke-Step -Description "Running Flutter on Android emulator..." -Action {
            flutter run -d emulator-5554 --dart-define=LOG_LEVEL=$logLevel --dart-define=PASSWORD_SALT=$passwordSalt
        }
    }
    "device" {
        Invoke-Step -Description "Running Flutter on Android device..." -Action {
            flutter run --dart-define=LOG_LEVEL=$logLevel --dart-define=PASSWORD_SALT=$passwordSalt
        }
    }
}
