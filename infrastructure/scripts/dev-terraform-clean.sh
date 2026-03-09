#!/bin/bash
# Clean local Terraform state (useful after minikube destroy)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/../terraform/environments/dev"

echo "🧹 Cleaning previous DEV Terraform state..."
if [ -d "$TF_DIR" ]; then
    cd "$TF_DIR"
    rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup 2>/dev/null || true
    echo "✅ Terraform state cleaned"
else
    echo "⚠️ Terraform directory not found: $TF_DIR"
fi
