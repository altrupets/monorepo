#!/bin/bash
set -e

echo "=========================================="
echo "AltruPets - WSL2 Development Environment"
echo "=========================================="

export DEBIAN_FRONTEND=noninteractive

echo "[1/12] Updating package lists..."
sudo apt update -qq

echo "[2/12] Installing base packages..."
sudo apt install -y -qq \
    curl \
    wget \
    git \
    unzip \
    zip \
    build-essential \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    tmux \
    vim \
    htop \
    fd-find \
    ripgrep \
    fzf \
    bat \
    tree \
    httpie \
    | tail -5

echo "[3/12] Configuring Git..."
git config --global core.autocrlf input
git config --global init.defaultBranch main

echo "[4/12] Installing Node.js (v22)..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y -qq nodejs
node -v

echo "[5/12] Installing pnpm..."
npm install -g pnpm
pnpm --version

echo "[6/12] Installing Python 3.12 + pip..."
sudo apt install -y -qq python3.12-venv python3-pip python3.12
python3.12 --version
pip3 install --upgrade pip setuptools wheel

echo "[7/12] Installing pre-commit..."
pip3 install pre-commit --break-system-packages
pre-commit --version

echo "[8/12] Installing Terraform/OpenTofu..."
curl -fsSL https://get.opentofu.org/install.sh | sh -s -- -v 1.8.11
tofu --version

echo "[9/12] Installing kubectl..."
curl -fsSL -o /tmp/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x /tmp/kubectl
sudo mv /tmp/kubectl /usr/local/bin/kubectl
kubectl version --client --output=yaml | head -3

echo "[10/12] Installing Minikube..."
curl -fsSL -o /tmp/minikube "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
chmod +x /tmp/minikube
sudo mv /tmp/minikube /usr/local/bin/minikube
minikube version

echo "[11/12] Installing Docker/Podman..."
# Install Podman as it's more WSL2-friendly
sudo apt install -y -qq podman podman-docker
podman --version

echo "[12/12] Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
source "$HOME/.cargo/env"
rustc --version
cargo --version

echo "[13/12] Installing Flutter SDK..."
if [ ! -d "$HOME/flutter" ]; then
    git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"
flutter precache
flutter --version

echo "[14/12] Finalizing..."
echo 'export PATH="$HOME/flutter/bin:$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/flutter/bin:$HOME/.cargo/bin:$PATH"' >> ~/.zshrc

echo ""
echo "=========================================="
echo "✓ WSL2 Development Environment Ready!"
echo "=========================================="
echo ""
echo "To use in current shell, run:"
echo "  source ~/.bashrc"
echo ""
echo "Required tools installed:"
echo "  - Node.js v22 + pnpm"
echo "  - Python 3.12 + pip + pre-commit"
echo "  - Terraform/OpenTofu"
echo "  - kubectl + minikube + podman"
echo "  - Rust (stable)"
echo "  - Flutter SDK"
echo ""