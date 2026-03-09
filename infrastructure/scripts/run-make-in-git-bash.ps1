param(
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [string]$ExtraArgs = ""
)

$ErrorActionPreference = "Stop"

function Get-GitBashPath {
    $candidates = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "$env:ProgramFiles(x86)\Git\bin\bash.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $bashCmd = Get-Command bash -ErrorAction SilentlyContinue
    if ($bashCmd) {
        return $bashCmd.Source
    }

    throw "Git Bash not found. Install Git for Windows or ensure bash is in PATH."
}

function Get-MakePath {
    $candidates = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\ezwinports.make_Microsoft.Winget.Source_8wekyb3d8bbwe\bin\make.exe",
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links\make.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $makeCmd = Get-Command make -ErrorAction SilentlyContinue
    if ($makeCmd) {
        return $makeCmd.Source
    }

    throw "make not found. Install make (winget/choco) and retry."
}

function Get-TofuDir {
    $candidates = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OpenTofu.Tofu_Microsoft.Winget.Source_8wekyb3d8bbwe",
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
    )

    foreach ($candidate in $candidates) {
        $exe = Join-Path $candidate "tofu.exe"
        if (Test-Path $exe) {
            return $candidate
        }
    }

    $tofuCmd = Get-Command tofu -ErrorAction SilentlyContinue
    if ($tofuCmd) {
        return (Split-Path -Parent $tofuCmd.Source)
    }

    return $null
}

function To-PosixPath {
    param([string]$WindowsPath)
    $normalized = $WindowsPath.Replace('\\', '/').Replace('\', '/')
    $drive = $normalized.Substring(0, 1).ToLowerInvariant()
    $rest = $normalized.Substring(2)
    return "/$drive$rest"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..\..")).Path
$repoPosix = To-PosixPath -WindowsPath $repoRoot
$makeExePosix = To-PosixPath -WindowsPath (Get-MakePath)

$extraPathEntries = @()
$tofuDir = Get-TofuDir
if ($tofuDir) {
    $extraPathEntries += (To-PosixPath -WindowsPath $tofuDir)
}

$pathPrefix = ""
if ($extraPathEntries.Count -gt 0) {
    $pathPrefix = 'export PATH="$PATH:{0}" && ' -f ($extraPathEntries -join ':')
}

$bash = Get-GitBashPath
$innerMakeCmd = if ([string]::IsNullOrWhiteSpace($ExtraArgs)) {
    "cd '$repoPosix' && '$makeExePosix' $Target"
} else {
    "cd '$repoPosix' && '$makeExePosix' $Target $ExtraArgs"
}
$makeCmd = "$pathPrefix$innerMakeCmd"

Write-Host "[make-windows] bash: $bash" -ForegroundColor Cyan
Write-Host "[make-windows] make: $makeExePosix" -ForegroundColor Cyan
if ($tofuDir) {
    Write-Host "[make-windows] tofu: $(To-PosixPath -WindowsPath $tofuDir)" -ForegroundColor Cyan
}
Write-Host "[make-windows] run : $makeCmd" -ForegroundColor Cyan

& $bash -lc $makeCmd
exit $LASTEXITCODE


