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

Require-Command "flutter"
Require-Command "dart"

$logLevel = "1"
$passwordSalt = $env:PASSWORD_SALT
if ([string]::IsNullOrWhiteSpace($passwordSalt)) {
    $passwordSalt = "default_salt_fallback"
}

Write-Host "[mobile] Enabling Windows desktop support..." -ForegroundColor Cyan
flutter config --enable-windows-desktop | Out-Null

if (-not $NoClean) {
    Write-Host "[mobile] flutter clean" -ForegroundColor Cyan
    flutter clean
}

Write-Host "[mobile] flutter pub get" -ForegroundColor Cyan
flutter pub get

switch ($Target) {
    "desktop" {
        Write-Host "[mobile] Running Flutter on Windows desktop..." -ForegroundColor Green
        flutter run -d windows --dart-define=LOG_LEVEL=$logLevel --dart-define=PASSWORD_SALT=$passwordSalt
    }
    "emulator" {
        Write-Host "[mobile] Running Flutter on Android emulator..." -ForegroundColor Green
        flutter run -d emulator-5554 --dart-define=LOG_LEVEL=$logLevel --dart-define=PASSWORD_SALT=$passwordSalt
    }
    "device" {
        Write-Host "[mobile] Running Flutter on Android device..." -ForegroundColor Green
        flutter run --dart-define=LOG_LEVEL=$logLevel --dart-define=PASSWORD_SALT=$passwordSalt
    }
}