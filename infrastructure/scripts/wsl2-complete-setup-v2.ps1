$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AltruPets - WSL2 Complete Setup (v2)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$DistroName = "altrupets-ubuntu"

function Write-Step { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Yellow }
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }

Write-Step "Step 1-8: WSL2 config + Ubuntu + packages already installed"

Write-Step "Step 9: Installing kubectl..."
$wslCmd = @"
curl -fsSL -o /tmp/kubectl 'https://dl.k8s.io/release/v1.32.0/bin/linux/amd64/kubectl' && chmod +x /tmp/kubectl && sudo mv /tmp/kubectl /usr/local/bin/kubectl && kubectl version --client --short
"@
& wsl.exe -d $DistroName -- bash -lc $wslCmd 2>$null
Write-Success "kubectl installed"

Write-Step "Step 10: Installing Minikube..."
$wslCmd = @"
curl -fsSL -o /tmp/minikube 'https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64' && chmod +x /tmp/minikube && sudo mv /tmp/minikube /usr/local/bin/minikube && minikube version
"@
& wsl.exe -d $DistroName -- bash -lc $wslCmd 2>$null
Write-Success "Minikube installed"

Write-Step "Step 11: Installing Podman..."
$wslCmd = @"
export DEBIAN_FRONTEND=noninteractive && sudo apt update -qq && sudo apt install -y -qq podman podman-docker
"@
& wsl.exe -d $DistroName -- bash -lc $wslCmd 2>$null
Write-Success "Podman installed"

Write-Step "Step 12: Installing Rust..."
$wslCmd = @"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && source "$HOME/.cargo/env" && rustc --version
"@
& wsl.exe -d $DistroName -- bash -lc $wslCmd 2>$null
Write-Success "Rust installed"

Write-Step "Step 13: Installing Flutter SDK..."
$wslCmd = @"
if [ ! -d '$HOME/flutter' ]; then
    git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $HOME/flutter
fi
echo 'export PATH="\$HOME/flutter/bin:\$HOME/.cargo/bin:\$PATH"' >> ~/.bashrc
echo 'Flutter SDK ready (run: flutter precache after login)'
"@
& wsl.exe -d $DistroName -- bash -lc $wslCmd 2>$null
Write-Success "Flutter installed"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " WSL2 Development Environment Ready! " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To connect to your WSL2 distro, run:" -ForegroundColor Yellow
Write-Host "  wsl -d $DistroName" -ForegroundColor Cyan
Write-Host ""
Write-Host "Inside WSL, verify installations:" -ForegroundColor Yellow
Write-Host "  source ~/.bashrc" -ForegroundColor Cyan
Write-Host "  node -v && pnpm -v" -ForegroundColor Cyan
Write-Host "  python3.12 --version" -ForegroundColor Cyan
Write-Host "  tofu --version" -ForegroundColor Cyan
Write-Host "  kubectl version --client" -ForegroundColor Cyan
Write-Host "  minikube version" -ForegroundColor Cyan
Write-Host "  flutter --version" -ForegroundColor Cyan
Write-Host ""