#!/bin/bash
#
# Deploy Gateway API infrastructure for dev, QA and Staging environments
# Usage: ./deploy-gateway-api.sh <environment>
# Environments: dev, qa, staging
#

set -euo pipefail

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/env-config.sh"

# ============================================
# Configuration
# ============================================

ENVIRONMENT=""
AUTO_APPROVE="${AUTO_APPROVE:-false}"
SKIP_GATEWAY="${SKIP_GATEWAY:-false}"
SKIP_ISTIO="${SKIP_ISTIO:-false}"
FORCE_RECREATE="${FORCE_RECREATE:-false}"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ============================================
# Functions
# ============================================

show_help() {
	cat <<EOF
Usage: $(basename "$0") <environment> [options]

Deploy Gateway API infrastructure (NGINX Gateway + Istio Service Mesh)

Arguments:
  environment              Target environment: dev, qa, staging

Options:
  --skip-gateway           Skip NGINX Gateway deployment
  --skip-istio             Skip Istio Service Mesh deployment
  --auto-approve           Auto-approve Terraform changes
  --force-recreate         Force recreation of Gateway manifest
  -h, --help              Show this help message

Environment Variables:
  AUTO_APPROVE            Auto-approve Terraform changes (true/false)
  SKIP_GATEWAY            Skip NGINX Gateway (true/false)
  SKIP_ISTIO              Skip Istio (true/false)
  FORCE_RECREATE          Force Gateway recreation (true/false)

Examples:
  $(basename "$0") dev
  $(basename "$0") qa --auto-approve
  $(basename "$0") staging --skip-istio

EOF
}

parse_args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--skip-gateway)
			SKIP_GATEWAY=true
			shift
			;;
		--skip-istio)
			SKIP_ISTIO=true
			shift
			;;
		--auto-approve)
			AUTO_APPROVE=true
			shift
			;;
		--force-recreate)
			FORCE_RECREATE=true
			shift
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

	# Validate environment
	if [[ -z "$ENVIRONMENT" ]]; then
		log_error "Environment not specified"
		show_help
		exit 1
	fi

	validate_environment "$ENVIRONMENT"

	if [[ "$ENVIRONMENT" == "prod" ]]; then
		log_warn "Production deployment not yet implemented"
		log_info "PROD gateway configuration is TBD"
		exit 1
	fi

	# Check required commands
	require_cmd kubectl "Install kubectl: https://kubernetes.io/docs/tasks/tools/"
	require_cmd tofu "Install OpenTofu: https://opentofu.org/docs/intro/install/"

	# Check kubeconfig
	if ! kubectl cluster-info &>/dev/null; then
		log_error "Cannot connect to Kubernetes cluster"
		log_info "Check your kubeconfig and cluster connectivity"
		exit 1
	fi

	log_success "Prerequisites validated"
}

get_tf_vars() {
	local env="$1"

	local namespace
	local nginx_enabled
	local istio_enabled
	local deployment_method

	namespace=$(get_env_config "$env" "namespace")
	nginx_enabled=$(get_env_config "$env" "nginx_gateway_enabled")
	istio_enabled=$(get_env_config "$env" "istio_enabled")
	deployment_method=$(get_env_config "$env" "deployment_method")

	# Override with CLI flags
	[[ "$SKIP_GATEWAY" == "true" ]] && nginx_enabled="false"
	[[ "$SKIP_ISTIO" == "true" ]] && istio_enabled="false"

	cat <<EOF
{
  "environment": "$env",
  "namespace": "$namespace",
  "enable_nginx_gateway": $nginx_enabled,
  "enable_istio_service_mesh": $istio_enabled,
  "deployment_method": "$deployment_method"
}
EOF
}

deploy_gateway_api() {
	local env="$1"
	local tf_dir
	tf_dir=$(get_tf_dir "$env" "$PROJECT_ROOT")

	if [[ -z "$tf_dir" ]] || [[ ! -d "$tf_dir" ]]; then
		log_error "Terraform directory not found for environment: $env"
		exit 1
	fi

	log_header "Deploying Gateway API to $env"

	# Get configuration
	local namespace
	local nginx_enabled
	local istio_enabled

	namespace=$(get_env_config "$env" "namespace")
	nginx_enabled=$(get_env_config "$env" "nginx_gateway_enabled")
	istio_enabled=$(get_env_config "$env" "istio_enabled")

	# Override with CLI flags
	[[ "$SKIP_GATEWAY" == "true" ]] && nginx_enabled="false"
	[[ "$SKIP_ISTIO" == "true" ]] && istio_enabled="false"

	log_info "Configuration:"
	log_info "  Environment: $env"
	log_info "  Namespace: $namespace"
	log_info "  NGINX Gateway: $nginx_enabled"
	log_info "  Istio Service Mesh: $istio_enabled"

	if [[ "$FORCE_RECREATE" == "true" ]]; then
		log_warn "Force recreate enabled - Gateway manifest will be destroyed first"
	fi

	# Confirm deployment
	if [[ "$AUTO_APPROVE" != "true" ]]; then
		if ! confirm "Deploy Gateway API to $env?" "yes"; then
			exit 0
		fi
	fi

	# Initialize Terraform
	log_step 1 4 "Initializing Terraform"
	cd "$tf_dir"
	if ! tofu init; then
		log_error "Terraform initialization failed"
		exit 1
	fi

	# Create tfvars file
	local tfvars_file="gateway-api.auto.tfvars.json"
	get_tf_vars "$env" >"$tfvars_file"
	log_debug "Created $tfvars_file"

	# Check if gateway manifest needs recreation
	log_step 2 4 "Checking Gateway manifest status"
	local needs_recreate=false

	if [[ "$FORCE_RECREATE" == "true" ]]; then
		needs_recreate=true
		log_warn "Force recreate requested"
	else
		if tofu plan -target='module.gateway_api.kubernetes_manifest.main_gateway[0]' -detailed-exitcode 2>/dev/null; then
			log_success "Gateway manifest is in sync"
		elif [ $? -eq 2 ]; then
			if tofu plan -target='module.gateway_api.kubernetes_manifest.main_gateway[0]' 2>&1 | grep -qE "forces replacement|forces new resource|inconsistent"; then
				needs_recreate=true
				log_warn "Gateway manifest requires recreation"
			fi
		fi
	fi

	# Destroy gateway manifest if needed
	if [[ "$needs_recreate" == "true" ]]; then
		log_step 3 4 "Destroying Gateway manifest for recreation"
		if ! tofu destroy -target='module.gateway_api.kubernetes_manifest.main_gateway[0]' -auto-approve; then
			log_error "Failed to destroy gateway manifest"
			rm -f "$tfvars_file"
			exit 1
		fi
		log_success "Gateway manifest destroyed"
	fi

	# Plan and Apply
	log_step 4 4 "Applying changes"
	local apply_args=""
	[[ "$AUTO_APPROVE" == "true" ]] && apply_args="-auto-approve"

	if ! tofu apply -target=module.gateway_api $apply_args; then
		log_error "Terraform apply failed"
		rm -f "$tfvars_file"
		exit 1
	fi

	# Cleanup
	rm -f "$tfvars_file"

	log_success "Gateway API deployed successfully to $env"
}

verify_deployment() {
	local env="$1"
	local namespace
	namespace=$(get_env_config "$env" "namespace")

	log_header "Verifying Deployment"

	# Check CRDs
	log_info "Checking Gateway API CRDs..."
	if kubectl get crd gatewayclasses.gateway.networking.k8s.io &>/dev/null; then
		log_success "GatewayClass CRD installed"
	else
		log_warn "GatewayClass CRD not found"
	fi

	# Check GatewayClass
	log_info "Checking GatewayClasses..."
	kubectl get gatewayclass 2>/dev/null || log_warn "No GatewayClasses found"

	# Check Gateways
	log_info "Checking Gateways in $namespace..."
	kubectl get gateway -n "$namespace" 2>/dev/null || log_warn "No Gateways found in $namespace"

	# Check Istio (if enabled)
	local istio_enabled
	istio_enabled=$(get_env_config "$env" "istio_enabled")
	if [[ "$istio_enabled" == "true" ]] && [[ "$SKIP_ISTIO" != "true" ]]; then
		log_info "Checking Istio installation..."
		if kubectl get pods -n istio-system &>/dev/null; then
			log_success "Istio pods found in istio-system"
			kubectl get pods -n istio-system
		else
			log_warn "No Istio pods found"
		fi
	fi

	# Check NGINX Gateway (if enabled)
	local nginx_enabled
	nginx_enabled=$(get_env_config "$env" "nginx_gateway_enabled")
	if [[ "$nginx_enabled" == "true" ]] && [[ "$SKIP_GATEWAY" != "true" ]]; then
		log_info "Checking NGINX Gateway..."
		local nginx_ns
		nginx_ns=$(get_env_config "$env" "namespace")
		# NGINX Gateway creates its own namespace
		if kubectl get pods -n nginx-gateway &>/dev/null; then
			log_success "NGINX Gateway pods found"
			kubectl get pods -n nginx-gateway
		else
			log_warn "NGINX Gateway pods not found"
		fi
	fi
}

apply_environment_fixes() {
	local env="$1"
	local namespace
	namespace=$(get_env_config "$env" "namespace")

	if [[ "$env" == "dev" ]]; then
		log_header "Applying Environment Fixes for $env"

		# 1. Fix GraphQL HTTPRoute (ensuring hostnames are present)
		local httproute_file="$PROJECT_ROOT/k8s/base/backend/httproute.yaml"
		if [[ -f "$httproute_file" ]]; then
			log_info "Applying $httproute_file..."
			if kubectl apply -f "$httproute_file"; then
				log_success "GraphQL HTTPRoute applied"
			else
				log_warn "Failed to apply GraphQL HTTPRoute"
			fi
		else
			log_warn "GraphQL HTTPRoute file not found: $httproute_file"
		fi

		# 2. Restart Gateway to pick up route changes if needed
		# Note: In Gateway API, restarts are usually not needed for HTTPRoute changes,
		# but added here for consistency with the user's "fix" command.
		log_info "Restarting NGINX Gateway deployment..."
		if kubectl rollout restart deployment/dev-gateway-nginx -n "$namespace" 2>/dev/null; then
			log_success "NGINX Gateway restart initiated"
		else
			log_warn "NGINX Gateway deployment 'dev-gateway-nginx' not found in $namespace"
		fi
	fi
}

main() {
	parse_args "$@"
	validate_prerequisites

	local start_time
	start_time=$(date +%s)

	deploy_gateway_api "$ENVIRONMENT"
	apply_environment_fixes "$ENVIRONMENT"
	verify_deployment "$ENVIRONMENT"

	local end_time
	end_time=$(date +%s)
	local duration=$((end_time - start_time))

	log_header "Deployment Complete"
	log_success "Gateway API deployed to $ENVIRONMENT in $(format_duration $duration)"
	log_info ""
	log_info "Next steps:"
	log_info "  1. Deploy your applications"
	log_info "  2. Create HTTPRoutes: kubectl apply -f your-route.yaml"
	log_info "  3. Verify: kubectl get httproute -n $(get_namespace "$ENVIRONMENT")"
}

main "$@"
