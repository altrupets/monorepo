#!/bin/bash
#
# Stop port-forward to Gateway API
# Usage: ./gateway-stop.sh [environment]
# Default environment: dev
#

set -euo pipefail

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/env-config.sh"

ENVIRONMENT="${1:-dev}"

log_header "Stopping Port-forward for $ENVIRONMENT"

# Stop existing port-forwards
log_info "Stopping all port-forwards..."
pids=$(ps aux | grep "kubectl port-forward" | grep -v grep | awk '{print $2}') || true
if [ -n "$pids" ]; then
    for pid in $pids; do
        kill "$pid" 2>/dev/null || true
    done
fi

log_success "Port-forward stopped successfully"
