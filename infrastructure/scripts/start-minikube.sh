#!/bin/bash
# Start Minikube with lock cleanup and auto-update

set -e

echo "🔍 Checking for Minikube updates..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/kubernetes/minikube/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if command -v minikube >/dev/null 2>&1; then
    CURRENT_VERSION=$(minikube version --short | awk '{print $1}')
else
    CURRENT_VERSION="none"
fi

if [ "$LATEST_VERSION" != "" ] && [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
    echo "⬇️ Downloading and installing Minikube $LATEST_VERSION..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    echo "✅ Minikube updated to $LATEST_VERSION"
    minikube config set WantUpdateNotification false
else
    echo "✅ Minikube is up to date ($CURRENT_VERSION)"
fi

echo "🔧 Cleaning minikube locks..."
rm -f /tmp/minikube-locks/* 2>/dev/null || true

echo "🚀 Starting minikube..."
minikube start --driver=podman --cpus=8 --memory=16384 --disk-size=50g
minikube config set WantUpdateNotification false

echo "✅ Minikube started"
