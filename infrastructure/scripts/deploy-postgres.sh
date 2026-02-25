#!/bin/bash
#
# Deploy PostgreSQL for QA and Staging environments
# Self-managed PostgreSQL running in Kubernetes cluster
# Usage: ./deploy-postgres.sh <environment>
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/env-config.sh"

# ============================================
# Configuration
# ============================================

ENVIRONMENT="${1:-}"
AUTO_APPROVE="${AUTO_APPROVE:-false}"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Database credentials (use defaults or env vars)
POSTGRES_USER="${POSTGRES_USER:-altrupets}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"
POSTGRES_DB="${POSTGRES_DB:-altrupets}"
STORAGE_SIZE="${STORAGE_SIZE:-20Gi}"

# ============================================
# Functions
# ============================================

show_help() {
	cat <<EOF
Usage: $(basename "$0") <environment> [options]

Deploy PostgreSQL database (self-managed in cluster)

Arguments:
  environment              Target environment: qa, staging

Options:
  --auto-approve           Auto-approve Terraform changes
  --user USER              PostgreSQL username (default: altrupets)
  --password PASS          PostgreSQL password (will prompt if not set)
  --db NAME                Database name (default: altrupets)
  --storage SIZE           Storage size (default: 20Gi)
  -h, --help              Show this help message

Environment Variables:
  POSTGRES_USER           Database username
  POSTGRES_PASSWORD       Database password (required)
  POSTGRES_DB             Database name
  STORAGE_SIZE            PVC storage size
  AUTO_APPROVE            Auto-approve changes

Examples:
  POSTGRES_PASSWORD=secret123 $(basename "$0") qa
  $(basename "$0") staging --auto-approve --storage 50Gi

EOF
}

parse_args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--auto-approve)
			AUTO_APPROVE=true
			shift
			;;
		--user)
			POSTGRES_USER="$2"
			shift 2
			;;
		--password)
			POSTGRES_PASSWORD="$2"
			shift 2
			;;
		--db)
			POSTGRES_DB="$2"
			shift 2
			;;
		--storage)
			STORAGE_SIZE="$2"
			shift 2
			;;
		-h | --help)
			show_help
			exit 0
			;;
		*)
			if [[ -z "$ENVIRONMENT" ]]; then
				ENVIRONMENT="$1"
			else
				log_error "Unknown argument: $1"
				show_help
				exit 1
			fi
			shift
			;;
		esac
	done
}

validate_prerequisites() {
	log_header "Validating Prerequisites"

	if [[ -z "$ENVIRONMENT" ]]; then
		log_error "Environment not specified"
		show_help
		exit 1
	fi

	validate_environment "$ENVIRONMENT"

	# DEV is handled separately
	if [[ "$ENVIRONMENT" == "dev" ]]; then
		log_error "Use 'make dev' or deploy manually for DEV environment"
		exit 1
	fi

	# PROD uses managed PostgreSQL
	if [[ "$ENVIRONMENT" == "prod" ]]; then
		log_error "Production uses OVH Managed PostgreSQL"
		log_info "Configure managed database separately"
		exit 1
	fi

	require_cmd kubectl
	require_cmd tofu

	if ! kubectl cluster-info &>/dev/null; then
		log_error "Cannot connect to Kubernetes cluster"
		exit 1
	fi

	# Check if password is set
	if [[ -z "$POSTGRES_PASSWORD" ]]; then
		log_error "POSTGRES_PASSWORD not set"
		log_info "Set it via environment variable or --password flag"
		exit 1
	fi

	log_success "Prerequisites validated"
}

deploy_postgres() {
	local env="$1"

	log_header "Deploying PostgreSQL to $env"

	local namespace
	local storage_class
	local suffix

	namespace=$(get_env_config "$env" "namespace")
	storage_class=$(get_env_config "$env" "storage_class")
	suffix=$(get_env_config "$env" "environment_suffix")

	log_info "Configuration:"
	log_info "  Environment: $env"
	log_info "  Namespace: $namespace"
	log_info "  Database: $POSTGRES_DB"
	log_info "  User: $POSTGRES_USER"
	log_info "  Storage: $STORAGE_SIZE"
	log_info "  Storage Class: $storage_class"

	# Confirm deployment
	if [[ "$AUTO_APPROVE" != "true" ]]; then
		if ! confirm "Deploy PostgreSQL to $env?" "yes"; then
			exit 0
		fi
	fi

	# Create namespace if it doesn't exist
	if ! namespace_exists "$namespace"; then
		log_info "Creating namespace: $namespace"
		kubectl create namespace "$namespace"
	fi

	# Deploy using existing postgres-minikube module but with QA/Stage config
	local tf_dir="$PROJECT_ROOT/infrastructure/terraform/modules/database/postgres-minikube"

	log_step 1 3 "Creating Terraform configuration"

	# Create a temporary terraform workspace for this deployment
	local temp_dir="/tmp/postgres-deploy-$env-$(date +%s)"
	mkdir -p "$temp_dir"

	cat >"$temp_dir/main.tf" <<EOF
module "postgres" {
  source = "$tf_dir"

  name               = "postgres${suffix}"
  namespace          = "$namespace"
  postgres_version   = "15"
  postgres_username  = "$POSTGRES_USER"
  postgres_password  = "$POSTGRES_PASSWORD"
  postgres_database  = "$POSTGRES_DB"
  storage_class_name = "$storage_class"
  storage_size       = "$STORAGE_SIZE"
  enable_nodeport    = false
}

output "service_endpoint" {
  value = module.postgres.service_endpoint
}

output "connection_string" {
  value = "postgresql://${POSTGRES_USER}:****@postgres${suffix}-service.${namespace}.svc.cluster.local:5432/${POSTGRES_DB}"
  sensitive = true
}
EOF

	cat >"$temp_dir/providers.tf" <<EOF
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
EOF

	log_step 2 3 "Initializing and applying Terraform"
	cd "$temp_dir"

	if ! tofu init; then
		log_error "Terraform init failed"
		rm -rf "$temp_dir"
		exit 1
	fi

	if ! tofu apply -auto-approve; then
		log_error "Terraform apply failed"
		rm -rf "$temp_dir"
		exit 1
	fi

	# Cleanup
	rm -rf "$temp_dir"

	log_step 3 3 "Waiting for PostgreSQL to be ready"
	if ! wait_for_resource "statefulset/postgres${suffix}" "$namespace" 300; then
		log_warn "PostgreSQL may still be starting up"
	fi

	log_success "PostgreSQL deployed successfully to $env"
}

verify_deployment() {
	local env="$1"
	local namespace
	local suffix

	namespace=$(get_env_config "$env" "namespace")
	suffix=$(get_env_config "$env" "environment_suffix")

	log_header "Verifying PostgreSQL Deployment"

	# Check StatefulSet
	log_info "Checking StatefulSet..."
	kubectl get statefulset "postgres${suffix}" -n "$namespace" 2>/dev/null || log_warn "StatefulSet not found"

	# Check Service
	log_info "Checking Service..."
	kubectl get service "postgres${suffix}-service" -n "$namespace" 2>/dev/null || log_warn "Service not found"

	# Check Pods
	log_info "Checking Pods..."
	kubectl get pods -n "$namespace" -l app=postgres 2>/dev/null || log_warn "No pods found"

	# Check PVC
	log_info "Checking Persistent Volume Claim..."
	kubectl get pvc -n "$namespace" 2>/dev/null | grep "postgres" || log_warn "No PVC found"
}

main() {
	parse_args "$@"
	validate_prerequisites

	local start_time
	start_time=$(date +%s)

	deploy_postgres "$ENVIRONMENT"
	verify_deployment "$ENVIRONMENT"

	local end_time
	end_time=$(date +%s)
	local duration=$((end_time - start_time))

	log_header "Deployment Complete"
	log_success "PostgreSQL deployed to $ENVIRONMENT in $(format_duration $duration)"
	log_info ""
	log_info "Connection Info:"
	log_info "  Host: postgres$(get_env_config "$ENVIRONMENT" "environment_suffix")-service.$(get_namespace "$ENVIRONMENT").svc.cluster.local"
	log_info "  Port: 5432"
	log_info "  Database: $POSTGRES_DB"
	log_info "  User: $POSTGRES_USER"
}

main "$@"
