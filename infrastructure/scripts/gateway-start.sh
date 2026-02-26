#!/bin/bash
#
# Start port-forward to Gateway API
# Usage: ./gateway-start.sh [environment]
# Default environment: dev
#

set -euo pipefail

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/env-config.sh"

ENVIRONMENT="${1:-dev}"

log_header "Starting Gateway port-forward for $ENVIRONMENT"

# Validate environment
validate_environment "$ENVIRONMENT"

# Get namespace and service name from config
NAMESPACE=$(get_env_config "$ENVIRONMENT" "namespace")

# Find the actual namespace where dev-gateway-nginx service exists
GATEWAY_SVC="dev-gateway-nginx"
ACTUAL_NAMESPACE=$(kubectl get svc "$GATEWAY_SVC" -o jsonpath='{.metadata.namespace}' 2>/dev/null || echo "")

if [ -n "$ACTUAL_NAMESPACE" ]; then
	NAMESPACE="$ACTUAL_NAMESPACE"
	log_info "Found service in namespace: $NAMESPACE"
elif [ "$ENVIRONMENT" != "dev" ]; then
	# For QA/Stage/Prod, we might have different service names or patterns
	GATEWAY_SVC="$ENVIRONMENT-gateway-nginx"
	ACTUAL_NAMESPACE=$(kubectl get svc "$GATEWAY_SVC" -o jsonpath='{.metadata.namespace}' 2>/dev/null || echo "$NAMESPACE")
	NAMESPACE="${ACTUAL_NAMESPACE:-$NAMESPACE}"
fi

log_info "Environment: $ENVIRONMENT"
log_info "Namespace:   $NAMESPACE"
log_info "Service:     $GATEWAY_SVC"

# Validate requirements/connectivity
"$SCRIPT_DIR/dev-validate.sh" || true

# Stop existing port-forwards for gateway
log_info "Stopping existing gateway port-forwards..."
pids=$(ps aux | grep "kubectl port-forward.*gateway" | grep -v grep | awk '{print $2}') || true
if [ -n "$pids" ]; then
	for pid in $pids; do
		kill "$pid" 2>/dev/null || true
	done
fi

# Start new port-forward
# We use nohup or just backgrounding to keep it alive
log_info "Starting port-forward on localhost:3001..."
kubectl port-forward -n "$NAMESPACE" "svc/$GATEWAY_SVC" 3001:80 >/dev/null 2>&1 &
PF_PID=$!

# Give it a moment to start
sleep 2

# Check if it's still running
if kill -0 "$PF_PID" 2>/dev/null; then
	log_success "Gateway port-forward started successfully (PID: $PF_PID)"
	log_info "✓ Gateway at http://localhost:3001"
	echo ""
	log_info "Endpoints:"
	echo "  http://localhost:3001/admin/login     (CRUD Superusers)"
	echo "  http://localhost:3001/b2g/login       (B2G)"
	echo "  http://localhost:3001/graphql         (GraphQL API)"
else
	log_error "Failed to start port-forward. Check service availability in $NAMESPACE."
	exit 1
fi
