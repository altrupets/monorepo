#!/bin/bash
#
# Environment configuration library
# Provides environment-specific settings for deployment scripts
#

# ============================================
# Environment Configuration
# ============================================

# Get configuration for a specific environment
get_env_config() {
	local env="$1"
	local key="$2"

	case "$env" in
	dev)
		get_dev_config "$key"
		;;
	qa)
		get_qa_config "$key"
		;;
	staging)
		get_staging_config "$key"
		;;
	prod)
		get_prod_config "$key"
		;;
	*)
		echo ""
		;;
	esac
}

# ============================================
# DEV Configuration (Local Minikube)
# ============================================

get_dev_config() {
	local key="$1"

	case "$key" in
	cluster_type)
		echo "minikube"
		;;
	cloud_provider)
		echo "local"
		;;
	namespace)
		echo "altrupets-dev"
		;;
	postgres_type)
		echo "container" # Self-managed in cluster
		;;
	postgres_version)
		echo "15-alpine"
		;;
	gateway_controller)
		echo "nginx+istio"
		;;
	nginx_gateway_enabled)
		echo "true"
		;;
	istio_enabled)
		echo "true"
		;;
	deployment_method)
		echo "terraform-only"
		;;
	storage_class)
		echo "standard"
		;;
	replicas_gateway)
		echo "1"
		;;
	enable_tls)
		echo "false"
		;;
	enable_monitoring)
		echo "false"
		;;
	environment_suffix)
		echo "-dev"
		;;
	*)
		echo ""
		;;
	esac
}

# ============================================
# QA Configuration (OVHCloud - Ephemeral)
# ============================================

get_qa_config() {
	local key="$1"

	case "$key" in
	cluster_type)
		echo "ovh-kubernetes"
		;;
	cloud_provider)
		echo "ovhcloud"
		;;
	namespace)
		echo "altrupets-qa"
		;;
	postgres_type)
		echo "container" # Self-managed in cluster
		;;
	postgres_version)
		echo "15"
		;;
	gateway_controller)
		echo "nginx+istio"
		;;
	nginx_gateway_enabled)
		echo "true"
		;;
	istio_enabled)
		echo "true"
		;;
	deployment_method)
		echo "helm-kustomize"
		;;
	storage_class)
		echo "csi-cinder-classic"
		;;
	replicas_gateway)
		echo "2"
		;;
	enable_tls)
		echo "true"
		;;
	enable_monitoring)
		echo "true"
		;;
	environment_suffix)
		echo "-qa"
		;;
	ephemeral)
		echo "true" # QA is ephemeral (created/destroyed per PR)
		;;
	*)
		echo ""
		;;
	esac
}

# ============================================
# STAGING Configuration (OVHCloud - Prod-like)
# ============================================

get_staging_config() {
	local key="$1"

	case "$key" in
	cluster_type)
		echo "ovh-kubernetes"
		;;
	cloud_provider)
		echo "ovhcloud"
		;;
	namespace)
		echo "altrupets-stage"
		;;
	postgres_type)
		echo "container" # Self-managed in cluster
		;;
	postgres_version)
		echo "15"
		;;
	gateway_controller)
		echo "nginx+istio"
		;;
	nginx_gateway_enabled)
		echo "true"
		;;
	istio_enabled)
		echo "true"
		;;
	deployment_method)
		echo "helm-kustomize"
		;;
	storage_class)
		echo "csi-cinder-classic"
		;;
	replicas_gateway)
		echo "2"
		;;
	enable_tls)
		echo "true"
		;;
	enable_monitoring)
		echo "true"
		;;
	environment_suffix)
		echo "-staging"
		;;
	ephemeral)
		echo "false"
		;;
	*)
		echo ""
		;;
	esac
}

# ============================================
# PROD Configuration (OVHCloud - Production)
# ============================================

get_prod_config() {
	local key="$1"

	case "$key" in
	cluster_type)
		echo "ovh-kubernetes"
		;;
	cloud_provider)
		echo "ovhcloud"
		;;
	namespace)
		echo "altrupets-prod"
		;;
	postgres_type)
		echo "managed" # OVH Managed PostgreSQL
		;;
	postgres_version)
		echo "15"
		;;
	gateway_controller)
		echo "tbd" # To be defined for production
		;;
	nginx_gateway_enabled)
		echo "tbd"
		;;
	istio_enabled)
		echo "tbd"
		;;
	deployment_method)
		echo "helm-kustomize"
		;;
	storage_class)
		echo "csi-cinder-classic"
		;;
	replicas_gateway)
		echo "3"
		;;
	enable_tls)
		echo "true"
		;;
	enable_monitoring)
		echo "true"
		;;
	environment_suffix)
		echo "-prod"
		;;
	ephemeral)
		echo "false"
		;;
	requires_approval)
		echo "true" # Requires manual approval
		;;
	*)
		echo ""
		;;
	esac
}

# ============================================
# Helper Functions
# ============================================

# Check if environment is ephemeral (can be destroyed/recreated)
is_ephemeral() {
	local env="$1"
	local ephemeral
	ephemeral=$(get_env_config "$env" "ephemeral")
	[[ "$ephemeral" == "true" ]]
}

# Check if environment requires approval for deployment
requires_approval() {
	local env="$1"
	local approval
	approval=$(get_env_config "$env" "requires_approval")
	[[ "$approval" == "true" ]]
}

# Get Terraform directory for environment
get_tf_dir() {
	local env="$1"
	local project_root="${2:-}"

	if [[ -z "$project_root" ]]; then
		# Try to find project root
		if [[ -d "infrastructure/terraform/environments/$env" ]]; then
			echo "infrastructure/terraform/environments/$env"
		else
			echo ""
		fi
	else
		echo "$project_root/infrastructure/terraform/environments/$env"
	fi
}

# Get namespace for environment
get_namespace() {
	local env="$1"
	get_env_config "$env" "namespace"
}

# Get all environments
get_all_environments() {
	echo "dev qa staging prod"
}

# Get non-prod environments
get_non_prod_environments() {
	echo "dev qa staging"
}

# ============================================
# Export functions
# ============================================

export -f get_env_config get_dev_config get_qa_config get_staging_config get_prod_config
export -f is_ephemeral requires_approval
export -f get_tf_dir get_namespace
export -f get_all_environments get_non_prod_environments
