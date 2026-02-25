#!/bin/bash

# AltruPets - Validate DEV Environment for Development
# Validates that Minikube, PostgreSQL, and Backend are running correctly
# Syncs credentials from .env.local to K8s secrets

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKEND_ENV_FILE="$PROJECT_ROOT/apps/backend/.env.local"
TF_DIR="$PROJECT_ROOT/infrastructure/terraform/environments/dev"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warn() { echo -e "${ORANGE}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

load_env_credentials() {
	if [ -f "$BACKEND_ENV_FILE" ]; then
		DB_USERNAME=$(grep "^DB_USERNAME=" "$BACKEND_ENV_FILE" | cut -d'=' -f2-)
		DB_PASSWORD=$(grep "^DB_PASSWORD=" "$BACKEND_ENV_FILE" | cut -d'=' -f2-)
		DB_NAME=$(grep "^DB_NAME=" "$BACKEND_ENV_FILE" | cut -d'=' -f2-)
	fi

	DB_USERNAME="${DB_USERNAME:-dev_demo_admin}"
	DB_PASSWORD="${DB_PASSWORD:-postgres}"
	DB_NAME="${DB_NAME:-altrupets_dev_database}"
}

check_minikube() {
	log_info "Checking Minikube..."

	if ! minikube status &>/dev/null || ! minikube status 2>/dev/null | grep -q "Running"; then
		log_info "Starting Minikube..."
		minikube start
		sleep 3
	fi
	log_success "Minikube is running"
}

check_postgres() {
	log_info "Checking PostgreSQL..."

	if kubectl wait --for=condition=ready pod -l app=postgres -n altrupets-dev --timeout=30s 2>/dev/null; then
		log_success "PostgreSQL is ready"
		return 0
	fi

	log_warn "PostgreSQL pod not ready"
	return 1
}

check_backend() {
	log_info "Checking Backend..."

	if kubectl wait --for=condition=available deployment/backend -n altrupets-dev --timeout=30s 2>/dev/null; then
		log_success "Backend is ready"
		return 0
	fi

	log_warn "Backend deployment not ready"
	return 1
}

get_k8s_secret() {
	local namespace="${1:-default}"
	local secret="$2"
	local key="$3"
	kubectl get secret "$secret" -n "$namespace" -o jsonpath="{.data.$key}" 2>/dev/null | base64 -d 2>/dev/null
}

sync_secrets() {
	# Check if Infisical is managing secrets
	if kubectl get infisicalsecret -n altrupets-dev >/dev/null 2>&1; then
		log_info "Infisical is managing secrets, skipping sync..."
		log_success "Secrets managed by Infisical"
		return 0
	fi

	log_info "Syncing K8s secrets from .env.local..."

	load_env_credentials

	local backend_username backend_password backend_database
	backend_username=$(get_k8s_secret "altrupets-dev" "backend-secret" "DB_USERNAME")
	backend_password=$(get_k8s_secret "altrupets-dev" "backend-secret" "DB_PASSWORD")
	backend_database=$(get_k8s_secret "altrupets-dev" "backend-secret" "DB_NAME")

	local needs_sync=false

	if [ "$backend_username" != "$DB_USERNAME" ] || [ "$backend_password" != "$DB_PASSWORD" ] || [ "$backend_database" != "$DB_NAME" ]; then
		log_warn "backend-secret mismatch"
		needs_sync=true
	fi

	if [ "$needs_sync" = true ]; then
		log_info "Updating secrets..."

		kubectl delete secret backend-secret -n altrupets-dev --ignore-not-found=true 2>/dev/null
		kubectl create secret generic backend-secret -n altrupets-dev \
			--from-literal=DB_USERNAME="$DB_USERNAME" \
			--from-literal=DB_PASSWORD="$DB_PASSWORD" \
			--from-literal=DB_NAME="$DB_NAME" \
			--from-literal=JWT_SECRET="${JWT_SECRET:-your-secret-key-here}" \
			--from-literal=ENV_NAME=dev

		log_success "Secrets synced"
		echo "CHANGED=1"
		return 0
	fi

	log_success "Secrets are in sync"
	return 0
}

test_db_connection() {
	log_info "Testing database connection..."

	# Read credentials from Infisical-managed secret
	local db_user db_name
	db_user=$(get_k8s_secret "altrupets-dev" "backend-secret" "DB_USERNAME")
	db_name=$(get_k8s_secret "altrupets-dev" "backend-secret" "DB_NAME")

	if kubectl exec -n altrupets-dev postgres-dev-0 -- psql -U "$db_user" -d "$db_name" -c "SELECT 1" 2>/dev/null | grep -q "1 row"; then
		log_success "Database connection OK"
		return 0
	else
		log_warn "Database connection failed"
		return 1
	fi
}

recreate_postgres() {
	log_warn "Recreating PostgreSQL..."

	kubectl delete statefulset postgres-dev -n altrupets-dev --ignore-not-found=true
	kubectl delete pvc postgres-data-postgres-dev-0 -n altrupets-dev --ignore-not-found=true

	log_info "Applying Terraform..."
	cd "$TF_DIR"
	tofu apply -auto-approve -target=module.postgres

	log_info "Waiting for PostgreSQL..."
	kubectl wait --for=condition=ready pod -l app=postgres -n altrupets-dev --timeout=120s

	log_success "PostgreSQL recreated"
}

check_gateway() {
	log_info "Checking Gateway API..."

	if kubectl get gateway dev-gateway -n altrupets-dev &>/dev/null; then
		log_success "Gateway is configured"
		return 0
	else
		log_warn "Gateway not found"
		return 1
	fi
}

setup_port_forward() {
	log_info "Setting up Gateway port-forward..."

	pkill -f "kubectl port-forward.*gateway-nodeport" 2>/dev/null || true
	kubectl port-forward -n nginx-gateway svc/gateway-nodeport 3001:80 >/dev/null 2>&1 &

	sleep 2

	if lsof -i :3001 >/dev/null 2>&1; then
		log_success "Gateway accessible at http://localhost:3001"
		return 0
	else
		log_error "Port-forward failed"
		return 1
	fi
}

main() {
	echo -e "${BLUE}=== AltruPets - DEV Environment Validation ===${NC}"
	echo ""

	load_env_credentials

	check_minikube

	if ! check_postgres; then
		log_warn "PostgreSQL not deployed. Run 'make dev' first."
		exit 1
	fi

	local secrets_changed
	secrets_changed=$(sync_secrets)

	if [ "$secrets_changed" = "CHANGED=1" ]; then
		log_warn "Secrets were updated. Checking if PostgreSQL needs recreation..."

		if ! test_db_connection; then
			recreate_postgres
		else
			log_info "Restarting backend to pick up new secrets..."
			kubectl rollout restart deployment/backend -n altrupets-dev
			kubectl rollout status deployment/backend -n altrupets-dev --timeout=120s
		fi
	fi

	if ! test_db_connection; then
		recreate_postgres
	fi

	if ! check_backend; then
		log_warn "Backend not deployed. Run 'make dev' first."
		exit 1
	fi

	check_gateway
	setup_port_forward

	echo ""
	log_success "DEV environment is ready!"
	echo ""
	echo -e "${BLUE}Endpoints:${NC}"
	echo "  http://localhost:3001           - Backend API"
	echo "  http://localhost:3001/graphql   - GraphQL Playground"
	echo "  http://localhost:3001/admin/users - Admin Panel"
	echo ""
}

main "$@"
