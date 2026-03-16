$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AltruPets - WSL2 Complete Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$DistroName = "altrupets-ubuntu"
$Processors = 8
$Memory = "16GB"
$Swap = "4GB"
$VhdSize = "50GB"

function Write-Step {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Yellow
}

function Write-Success {
    param($Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Test-Command {
    param($Name)
    Get-Command $Name -ErrorAction SilentlyContinue
}

function Ensure-WslConfig {
    param($Processors, $Memory, $Swap)
    
    $homeDir = if ($env:HOME) { $env:HOME } else { $env:USERPROFILE }
    $path = Join-Path $homeDir ".wslconfig"
    $desired = @"
[wsl2]
processors=$Processors
memory=$Memory
swap=$Swap
localhostForwarding=true
nestedVirtualization=true
"@
    $desired = @"
[wsl2]
processors=$Processors
memory=$Memory
swap=$Swap
localhostForwarding=true
nestedVirtualization=true
"@
    
    if (Test-Path $path) {
        $current = Get-Content -Raw $path
        if ($current -eq $desired) {
            return $false
        }
    }
    
    Set-Content -Path $path -Value $desired -NoNewline
    return $true
}

function Test-DistroExists {
    param($Name)
    
    try {
        $result = & wsl.exe --list --quiet 2>$null
        if ($LASTEXITCODE -eq 0 -and $result) {
            $distros = $result | ForEach-Object { $_.Trim([char]0, ' ', "`r", "`n", "`t") }
            return ($distros -contains $Name)
        }
    } catch {
        return $false
    }
    return $false
}

Write-Step "Step 1: Configuring WSL2 settings..."
$configChanged = Ensure-WslConfig -Processors $Processors -Memory $Memory -Swap $Swap
if ($configChanged) {
    Write-Host "  Updated $env:HOME\.wslconfig"
    & wsl.exe --shutdown 2>$null
    Start-Sleep -Seconds 2
}
Write-Success "WSL2 configuration complete"

Write-Step "Step 2: Checking for existing Ubuntu distro..."
$distroExists = Test-DistroExists -Name $DistroName
if ($distroExists) {
    Write-Success "Distro '$DistroName' already exists"
} else {
    Write-Step "Installing Ubuntu-24.04..."
    & wsl.exe --install --name $DistroName --version 2 --no-launch
    Write-Success "Ubuntu installed"
}

Write-Step "Step 3: Updating Ubuntu packages..."
& wsl.exe -d $DistroName -- bash -c "export DEBIAN_FRONTEND=noninteractive && sudo apt update -qq" 2>$null
Write-Success "Packages updated"

Write-Step "Step 4: Installing base development packages..."
& wsl.exe -d $DistroName -- bash -c "export DEBIAN_FRONTEND=noninteractive && sudo apt install -y -qq curl wget git unzip zip build-essential software-properties-common ca-certificates gnupg lsb-release jq tmux vim htop tree fd-find ripgrep fzf bat httpie" 2>$null
Write-Success "Base packages installed"

Write-Step "Step 5: Installing Node.js 22..."
& wsl.exe -d $DistroName -- bash -c "curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y -qq nodejs" 2>$null
Write-Success "Node.js installed"

Write-Step "Step 6: Installing pnpm..."
& wsl.exe -d $DistroName -- bash -c "npm install -g pnpm" 2>$null
Write-Success "pnpm installed"

Write-Step "Step 7: Installing Python 3.12..."
& wsl.exe -d $DistroName -- bash -c "export DEBIAN_FRONTEND=noninteractive && sudo apt install -y -qq python3.12-venv python3-pip python3.12" 2>$null
Write-Success "Python installed"

Write-Step "Step 8: Installing pre-commit..."
& wsl.exe -d $DistroName -- bash -c "pip3 install pre-commit --break-system-packages" 2>$null
Write-Success "pre-commit installed"

Write-Step "Step 9: Installing Terraform/OpenTofu..."
& wsl.exe -d $DistroName -- bash -c "curl -fsSL https://get.opentofu.org/install.sh | sh -s -- -v 1.8.11" 2>$null
Write-Success "OpenTofu installed"

Write-Step "Step 10: Installing kubectl..."
& wsl.exe -d $DistroName -- bash -c "curl -fsSL -o /tmp/kubectl 'https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl' && chmod +x /tmp/kubectl && sudo mv /tmp/kubectl /usr/local/bin/kubectl" 2>$null
Write-Success "kubectl installed"

Write-Step "Step 11: Installing Minikube..."
& wsl.exe -d $DistroName -- bash -c "curl -fsSL -o /tmp/minikube 'https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64' && chmod +x /tmp/minikube && sudo mv /tmp/minikube /usr/local/bin/minikube" 2>$null
Write-Success "Minikube installed"

Write-Step "Step 12: Installing Podman..."
& wsl.exe -d $DistroName -- bash -c "export DEBIAN_FRONTEND=noninteractive && sudo apt install -y -qq podman podman-docker" 2>$null
Write-Success "Podman installed"

Write-Step "Step 13: Installing Rust..."
& wsl.exe -d $DistroName -- bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable" 2>$null
Write-Success "Rust installed"

Write-Step "Step 14: Installing Flutter SDK..."
& wsl.exe -d $DistroName -- bash -c "if [ ! -d '$HOME/flutter' ]; then git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $HOME/flutter; fi && echo 'export PATH=\"\$HOME/flutter/bin:\$HOME/.cargo/bin:\$PATH\"' >> ~/.bashrc" 2>$null
Write-Success "Flutter installed"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " WSL2 Development Environment Ready! " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To connect to your WSL2 distro, run:" -ForegroundColor Yellow
Write-Host "  wsl -d $DistroName" -ForegroundColor Cyan
Write-Host ""
Write-Host "Inside WSL, source your profile:" -ForegroundColor Yellow
Write-Host "  source ~/.bashrc" -ForegroundColor Cyan
Write-Host ""
Write-Host "Then verify installations:" -ForegroundColor Yellow
Write-Host "  node -v && pnpm -v" -ForegroundColor Cyan
Write-Host "  python3.12 --version" -ForegroundColor Cyan
Write-Host "  tofu --version" -ForegroundColor Cyan
Write-Host "  kubectl version --client" -ForegroundColor Cyan
Write-Host "  minikube version" -ForegroundColor Cyan
Write-Host "  flutter --version" -ForegroundColor Cyan
Write-Host ""