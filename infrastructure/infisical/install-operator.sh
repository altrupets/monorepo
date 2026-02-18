#!/bin/bash

# AltruPets - Install Infisical Kubernetes Operator
# This script installs the Infisical Operator in Minikube for secret synchronization

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warn() { echo -e "${ORANGE}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Infisical Kubernetes Operator Installation           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if helm is installed
if ! command -v helm &>/dev/null; then
	log_error "Helm is not installed"
	log_info "Install helm: https://helm.sh/docs/intro/install/"
	exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &>/dev/null; then
	log_error "kubectl is not installed"
	exit 1
fi

# Check if Minikube is running
if ! minikube status &>/dev/null || ! minikube status 2>/dev/null | grep -q "Running"; then
	log_error "Minikube is not running. Run 'minikube start' first."
	exit 1
fi

log_success "Prerequisites OK"
echo ""

# Add Infisical Helm repository
log_info "Adding Infisical Helm repository..."
helm repo add infisical-helm-charts 'https://dl.cloudsmith.io/public/infisical/helm-charts/helm/charts/' 2>/dev/null || true
helm repo update

# Create namespace for operator
log_info "Creating namespace infisical-operator-system..."
kubectl create namespace infisical-operator-system --dry-run=client -o yaml | kubectl apply -f -

# Install the operator
log_info "Installing Infisical Secrets Operator..."
helm upgrade --install infisical-secrets-operator \
	infisical-helm-charts/secrets-operator \
	--namespace infisical-operator-system \
	--set controllerManager.manager.env[0].name=LOG_LEVEL \
	--set controllerManager.manager.env[0].value=info

# Wait for operator to be ready
log_info "Waiting for operator to be ready..."
kubectl wait --for=condition=available deployment/infisical-secrets-operator-controller-manager \
	-n infisical-operator-system \
	--timeout=120s

echo ""
log_success "Infisical Operator installed successfully!"
echo ""

# Check if credentials secret exists
if kubectl get secret infisical-operator-credentials -n infisical-operator-system &>/dev/null; then
	log_success "Credentials secret found"
else
	log_warn "Credentials secret not found!"
	echo ""
	echo -e "${ORANGE}Next steps:${NC}"
	echo "1. Go to https://app.infisical.com"
	echo "2. Create a project called 'altrupets'"
	echo "3. Go to Project Settings > Machine Identities"
	echo "4. Create a new identity with access to 'dev' environment"
	echo "5. Run the following command with your credentials:"
	echo ""
	echo -e "   ${GREEN}kubectl create secret generic infisical-operator-credentials \\${NC}"
	echo -e "   ${GREEN}  --namespace infisical-operator-system \\${NC}"
	echo -e "   ${GREEN}  --from-literal=CLIENT_ID=<your-client-id> \\${NC}"
	echo -e "   ${GREEN}  --from-literal=CLIENT_SECRET=<your-client-secret>${NC}"
	echo ""
	echo "6. Apply the InfisicalSecret CRDs:"
	echo ""
	echo -e "   ${GREEN}kubectl apply -f infrastructure/infisical/infisical-secrets.yaml${NC}"
	echo ""
fi

log_info "Operator status:"
kubectl get pods -n infisical-operator-system
