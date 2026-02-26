#!/bin/bash

# ==============================================================================
# AltruPets - Terraform Deployment with Infisical
# ==============================================================================
# Deploys Terraform environments using secrets from Infisical
#
# Usage:
#   ./deploy-terraform.sh <environment> [options]
#
# Environments:
#   qa       - Deploy to QA (OVHCloud + self-managed PostgreSQL)
#   staging  - Deploy to Staging (OVHCloud + self-managed PostgreSQL)
#   prod     - Deploy to Production (OVHCloud + OVH Managed PostgreSQL)
#
# Options:
#   --plan       Show plan without applying
#   --destroy    Destroy resources instead of deploying
#   --auto-approve  Auto-approve terraform apply (not for prod)
#
# Examples:
#   ./deploy-terraform.sh qa              # Deploy QA
#   ./deploy-terraform.sh qa --plan      # Show plan only
#   ./deploy-terraform.sh staging        # Deploy Staging
#   ./deploy-terraform.sh prod --destroy # Destroy Production
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform/environments"

# Defaults
ENVIRONMENT=""
PLAN_ONLY=false
DESTROY=false
AUTO_APPROVE=""

# Infisical projects (free tier: 3 environments per project)
declare -A INFISICAL_PROJECTS=(
	["qa"]="altrupets"
	["staging"]="altrupets"
	["prod"]="altrupets-prod"
)

declare -A INFISICAL_ENVS=(
	["qa"]="qa"
	["staging"]="stage"
	["prod"]="prod"
)

# Parse arguments
for arg in "$@"; do
	case $arg in
	qa | staging | prod)
		ENVIRONMENT="$arg"
		;;
	--plan)
		PLAN_ONLY=true
		;;
	--destroy)
		DESTROY=true
		;;
	--auto-approve)
		AUTO_APPROVE="-auto-approve"
		;;
	-h | --help)
		echo "Usage: $0 <environment> [options]"
		echo ""
		echo "Environments: qa, staging, prod"
		echo "Options: --plan, --destroy, --auto-approve"
		exit 0
		;;
	esac
done

if [ -z "$ENVIRONMENT" ]; then
	echo "ERROR: Environment is required"
	echo "Usage: $0 <environment> [options]"
	echo "Environments: qa, staging, prod"
	exit 1
fi

echo "=========================================="
echo "AltruPets - Terraform Deployment"
echo "=========================================="
echo ""
echo "Environment: $ENVIRONMENT"
echo "Infisical Project: ${INFISICAL_PROJECTS[$ENVIRONMENT]}"
echo "Infisical Env: ${INFISICAL_ENVS[$ENVIRONMENT]}"
echo ""

# Check prerequisites
if ! command -v terraform >/dev/null 2>&1 && ! command -v tofu >/dev/null 2>&1; then
	echo "ERROR: Terraform or OpenTofu is required"
	exit 1
fi

# Detect terraform/tofu
TF_CMD="terraform"
if command -v tofu >/dev/null 2>&1; then
	TF_CMD="tofu"
fi
echo "Using: $TF_CMD"

# Check Infisical
if ! command -v infisical >/dev/null 2>&1; then
	echo "WARNING: Infisical CLI not found, installing..."
	curl -fsSL https://infisical.com/install-cli | sh
fi

# Check if logged in
if ! infisical whoami >/dev/null 2>&1; then
	echo "ERROR: Not logged in to Infisical"
	echo "Run: infisical login"
	exit 1
fi

# Check environment directory
ENV_DIR="$TERRAFORM_DIR/$ENVIRONMENT"
if [ ! -d "$ENV_DIR" ]; then
	echo "ERROR: Environment directory not found: $ENV_DIR"
	exit 1
fi

cd "$ENV_DIR"

# Check if terraform.tfvars exists or create from example
if [ ! -f "terraform.tfvars" ] && [ -f "terraform.tfvars.example" ]; then
	echo "WARNING: No terraform.tfvars found, using example values"
	echo "Some variables may be empty - ensure secrets exist in Infisical"
fi

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
$TF_CMD init

# Get secrets from Infisical and export as TF_VARs
echo ""
echo "Loading secrets from Infisical..."

INFISICAL_PROJECT="${INFISICAL_PROJECTS[$ENVIRONMENT]}"
INFISICAL_ENV="${INFISICAL_ENVS[$ENVIRONMENT]}"

# Export OVH credentials
export TF_VAR_ovh_service_name=$(infisical get -q --path /ovh/service_name --project="$INFISICAL_PROJECT" --env="$INFISICAL_ENV" 2>/dev/null || echo "")
export TF_VAR_ovh_application_key=$(infisical get -q --path /ovh/application_key --project="$INFISICAL_PROJECT" --env="$INFISICAL_ENV" 2>/dev/null || echo "")
export TF_VAR_ovh_application_secret=$(infisical get -q --path /ovh/application_secret --project="$INFISICAL_PROJECT" --env="$INFISICAL_ENV" 2>/dev/null || echo "")
export TF_VAR_ovh_consumer_key=$(infisical get -q --path /ovh/consumer_key --project="$INFISICAL_PROJECT" --env="$INFISICAL_ENV" 2>/dev/null || echo "")

# Export Cloudflare token (common across environments)
export TF_VAR_cloudflare_api_token=$(infisical get -q --path /cloudflare/api_token --project="$INFISICAL_PROJECT" --env="$INFISICAL_ENV" 2>/dev/null || echo "")

# Show which secrets were loaded
if [ -n "$TF_VAR_ovh_service_name" ]; then
	echo "  - OVH credentials: loaded"
else
	echo "  - OVH credentials: missing"
fi

if [ -n "$TF_VAR_cloudflare_api_token" ]; then
	echo "  - Cloudflare token: loaded"
else
	echo "  - Cloudflare token: missing"
fi

# Run terraform plan or apply
if [ "$PLAN_ONLY" = true ]; then
	echo ""
	echo "Running Terraform Plan..."
	$TF_CMD plan
elif [ "$DESTROY" = true ]; then
	echo ""
	echo "WARNING: Running Terraform Destroy..."
	read -p "Type '$ENVIRONMENT' to confirm: " confirm
	if [ "$confirm" != "$ENVIRONMENT" ]; then
		echo "Cancelled"
		exit 1
	fi
	$TF_CMD destroy
elif [ "$ENVIRONMENT" = "prod" ]; then
	echo ""
	echo "WARNING: Production deployment requires manual approval"
	$TF_CMD apply
else
	echo ""
	echo "Running Terraform Apply..."
	$TF_CMD apply $AUTO_APPROVE
fi

# Show outputs
echo ""
echo "Terraform Outputs:"
$TF_CMD output 2>/dev/null || true

echo ""
echo "Deployment complete!"
