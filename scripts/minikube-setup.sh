#!/bin/bash

# AltruPets - Minikube Setup Script for Ubuntu
# This script initializes a Minikube cluster for local development.

set -e

echo "🚀 Starting Minikube setup..."

# 1. Start Minikube with Docker driver
# Check if minikube is already running
if minikube status | grep -q "Running"; then
	echo "✅ Minikube is already running."
else
	echo "⚡ Starting Minikube..."
	minikube start --driver=podman --cpus=8 --memory=16384 --disk-size=50g
fi

# 2. Enable necessary addons
echo "🔌 Enabling addons (Ingress)..."
minikube addons enable ingress

# 3. Setup Ingress (Optional but recommended for .local domains)
# echo "Adding altrupets.local to /etc/hosts..."
# sudo echo "$(minikube ip) altrupets.local" | sudo tee -a /etc/hosts

# 4. Display connection info
echo "------------------------------------------------"
echo "✅ Minikube is ready!"
echo "------------------------------------------------"
echo "To expose NestJS API:"
echo "  minikube service user-management-service --url"
echo ""
echo "To expose PostgreSQL (Internal port 5432):"
echo "  minikube service postgres-service --url"
echo "------------------------------------------------"

# Tip: Use minikube dashboard to vizualize the cluster
# minikube dashboard
