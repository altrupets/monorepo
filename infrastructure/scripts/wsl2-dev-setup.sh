#!/bin/bash
set -e

echo "=========================================="
echo "AltruPets - WSL2 Development Environment"
echo "=========================================="

export DEBIAN_FRONTEND=noninteractive

echo "[1/10] Updating package lists..."
sudo apt update -qq

echo "[2/10] Installing base packages..."
sudo apt install -y -qq \
    curl wget git unzip zip build-essential software-properties-common \
    ca-certificates gnupg lsb-release jq tmux vim htop tree \
    fd-find ripgrep fzf bat httpie

echo "[3/10] Configuring Git..."
git config --global core.autocrlf input
git config --global init.defaultBranch main

echo "[4/10] Installing Node.js v22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y -qq nodejs
node -v

echo "[5/10] Installing pnpm..."
npm install -g pnpm
pnpm --version

echo "[6/10] Installing Python 3.12 + pip..."
sudo apt install -y -qq python3.12-venv python3-pip python3.12
python3.12 --version
pip3 install --upgrade pip setuptools wheel --break-system-packages

echo "[7/10] Installing pre-commit..."
pip3 install pre-commit --break-system-packages
pre-commit --version

echo "[8/10] Installing Terraform/OpenTofu..."
curl -fsSL https://get.opentofu.org/install.sh | sh -s -- -v 1.8.11
tofu --version

echo "[9/10] Installing kubectl + Minikube + Podman..."
# kubectl
curl -fsSL -o /tmp/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x /tmp/kubectl
sudo mv /tmp/kubectl /usr/local/bin/kubectl
kubectl version --client --short

# Minikube
curl -fsSL -o /tmp/minikube "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
chmod +x /tmp/minikube
sudo mv /tmp/minikube /usr/local/bin/minikube
minikube version

# Podman
sudo apt install -y -qq podman podman-docker

echo "[10/10] Installing Rust + Flutter..."
# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
source "$HOME/.cargo/env"
rustc --version

# Flutter (clone if not exists, don't precache to save time)
if [ ! -d "$HOME/flutter" ]; then
    git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$HOME/flutter"
fi
echo 'export PATH="$HOME/flutter/bin:$HOME/.cargo/bin:$PATH"' >> ~/.bashrc

echo ""
echo "=========================================="
echo "✓ WSL2 Dev Environment Ready!"
echo "=========================================="
echo ""
echo "Run these commands in your WSL terminal:"
echo "  source ~/.bashrc"
echo "  node -v && pnpm -v"
echo "  python3.12 --version"
echo "  tofu --version"
echo "  kubectl version --client"
echo "  minikube version"
echo "  flutter --version"
echo ""