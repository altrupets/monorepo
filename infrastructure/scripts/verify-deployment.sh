#!/bin/bash
#
# Verify deployment status for any environment
# Usage: ./verify-deployment.sh <environment>
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/env-config.sh"

# ============================================
# Configuration
# ============================================

ENVIRONMENT="${1:-}"

# ============================================
# Functions
# ============================================

show_help() {
	cat <<EOF
Usage: $(basename "$0") <environment>

Verify deployment status for an environment

Arguments:
  environment    Environment to verify: dev, qa, staging, prod

Examples:
  $(basename "$0") dev
  $(basename "$0") qa

EOF
}

validate_args() {
	if [[ -z "$ENVIRONMENT" ]]; then
		log_error "Environment not specified"
		show_help
		exit 1
	fi

	validate_environment "$ENVIRONMENT"
}

verify_kubernetes() {
	local env="$1"

	log_header "Kubernetes Cluster Status"

	if ! kubectl cluster-info &>/dev/null; then
		log_error "Cannot connect to Kubernetes cluster"
		exit 1
	fi

	log_success "Connected to Kubernetes cluster"
	kubectl cluster-info
}

verify_gateway_api() {
	local env="$1"
	local namespace
	namespace=$(get_namespace "$env")

	log_header "Gateway API Status"

	# Check CRDs
	log_info "Checking Gateway API CRDs..."
	local crds=("gatewayclasses" "gateways" "httproutes")
	for crd in "${crds[@]}"; do
		if kubectl get crd "${crd}.gateway.networking.k8s.io" &>/dev/null; then
			log_success "✓ CRD: $crd"
		else
			log_warn "✗ CRD not found: $crd"
		fi
	done

	# Check GatewayClasses
	log_info "Checking GatewayClasses..."
	kubectl get gatewayclass 2>/dev/null || log_warn "No GatewayClasses found"

	# Check Gateways
	log_info "Checking Gateways in $namespace..."
	kubectl get gateway -n "$namespace" 2>/dev/null || log_warn "No Gateways found in $namespace"

	# Check HTTPRoutes
	log_info "Checking HTTPRoutes in $namespace..."
	kubectl get httproute -n "$namespace" 2>/dev/null || log_warn "No HTTPRoutes found in $namespace"
}

verify_istio() {
	local env="$1"
	local istio_enabled
	istio_enabled=$(get_env_config "$env" "istio_enabled")

	if [[ "$istio_enabled" != "true" ]]; then
		log_info "Istio not enabled for $env, skipping"
		return 0
	fi

	log_header "Istio Service Mesh Status"

	# Check istio-system namespace
	if namespace_exists "istio-system"; then
		log_success "✓ Istio namespace exists"

		log_info "Istio pods:"
		kubectl get pods -n istio-system 2>/dev/null || log_warn "No Istio pods found"

		log_info "Istio services:"
		kubectl get svc -n istio-system 2>/dev/null || log_warn "No Istio services found"
	else
		log_warn "✗ Istio namespace not found"
	fi

	# Check sidecar injection
	local namespace
	namespace=$(get_namespace "$env")

	log_info "Checking sidecar injection in $namespace..."
	local pods
	pods=$(kubectl get pods -n "$namespace" --no-headers 2>/dev/null | wc -l)

	if [[ $pods -gt 0 ]]; then
		local pods_with_sidecar
		pods_with_sidecar=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[*].spec.containers[*].name}' 2>/dev/null | tr ' ' '\n' | grep -c "istio-proxy" || echo "0")

		if [[ $pods_with_sidecar -gt 0 ]]; then
			log_success "✓ $pods_with_sidecar pods have Istio sidecars"
		else
			log_warn "⚠ No pods with Istio sidecars found"
		fi
	else
		log_warn "⚠ No pods found in $namespace"
	fi
}

verify_postgres() {
	local env="$1"
	local namespace
	local suffix
	namespace=$(get_namespace "$env")
	suffix=$(get_env_config "$env" "environment_suffix")

	log_header "PostgreSQL Status"

	# Check if using managed PostgreSQL (prod)
	local pg_type
	pg_type=$(get_env_config "$env" "postgres_type")

	if [[ "$pg_type" == "managed" ]]; then
		log_info "Using OVH Managed PostgreSQL"
		log_info "Check OVH console for database status"
		return 0
	fi

	# Check StatefulSet
	log_info "Checking PostgreSQL StatefulSet..."
	if kubectl get statefulset "postgres${suffix}" -n "$namespace" &>/dev/null; then
		log_success "✓ StatefulSet postgres${suffix} exists"
		kubectl get statefulset "postgres${suffix}" -n "$namespace"
	else
		log_warn "✗ StatefulSet postgres${suffix} not found"
	fi

	# Check Service
	log_info "Checking PostgreSQL Service..."
	if kubectl get svc "postgres${suffix}-service" -n "$namespace" &>/dev/null; then
		log_success "✓ Service postgres${suffix}-service exists"
		kubectl get svc "postgres${suffix}-service" -n "$namespace"
	else
		log_warn "✗ Service not found"
	fi

	# Check Pods
	log_info "Checking PostgreSQL Pods..."
	local pod_count
	pod_count=$(kubectl get pods -n "$namespace" -l app=postgres --no-headers 2>/dev/null | wc -l)

	if [[ $pod_count -gt 0 ]]; then
		log_success "✓ $pod_count PostgreSQL pod(s) running"
		kubectl get pods -n "$namespace" -l app=postgres
	else
		log_warn "✗ No PostgreSQL pods found"
	fi

	# Check PVC
	log_info "Checking PostgreSQL PVC..."
	kubectl get pvc -n "$namespace" 2>/dev/null | grep "postgres" || log_warn "No PVC found"
}

verify_applications() {
	local env="$1"
	local namespace
	namespace=$(get_namespace "$env")

	log_header "Application Status"

	# Check all pods
	log_info "All pods in $namespace:"
	kubectl get pods -n "$namespace" 2>/dev/null || log_warn "No pods found"

	# Check services
	log_info "All services in $namespace:"
	kubectl get svc -n "$namespace" 2>/dev/null || log_warn "No services found"

	# Check deployments
	log_info "All deployments in $namespace:"
	kubectl get deployments -n "$namespace" 2>/dev/null || log_warn "No deployments found"
}

print_summary() {
	local env="$1"

	log_header "Summary"

	log_info "Environment: $env"
	log_info "Namespace: $(get_namespace "$env")"
	log_info "Gateway Controller: $(get_env_config "$env" "gateway_controller")"
	log_info "Istio Enabled: $(get_env_config "$env" "istio_enabled")"
	log_info "PostgreSQL Type: $(get_env_config "$env" "postgres_type")"

	echo ""
	log_info "Useful commands:"
	log_info "  kubectl get all -n $(get_namespace "$env")"
	log_info "  kubectl logs -n $(get_namespace "$env") -l app=postgres"
	log_info "  kubectl get gateway -n $(get_namespace "$env")"
}

main() {
	validate_args

	verify_kubernetes "$ENVIRONMENT"
	verify_gateway_api "$ENVIRONMENT"
	verify_istio "$ENVIRONMENT"
	verify_postgres "$ENVIRONMENT"
	verify_applications "$ENVIRONMENT"
	print_summary "$ENVIRONMENT"

	log_success "Verification complete for $ENVIRONMENT"
}

main "$@"
