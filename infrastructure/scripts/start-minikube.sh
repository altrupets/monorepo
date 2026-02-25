#!/bin/bash
# Start Minikube with lock cleanup

set -e

echo "🔧 Cleaning minikube locks..."
rm -f /tmp/minikube-locks/* 2>/dev/null || true

echo "🚀 Starting minikube..."
minikube start --driver=podman --cpus=8 --memory=16384 --disk-size=50g

echo "✅ Minikube started"
