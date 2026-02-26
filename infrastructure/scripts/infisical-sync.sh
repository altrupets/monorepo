#!/bin/bash

# ==============================================================================
# AltruPets - Infisical Secrets Sync
# ==============================================================================
# Synchronizes secrets from Infisical to Kubernetes
# Installs Infisical operator if not present, or uses CLI as fallback
# Also configures OVHCloud CLI credentials from Infisical
#
# Usage:
#   ./infisical-sync.sh [--cli] [--ovh] [--stitch] [--stitch-setup]
#
# Options:
#   --cli         Use Infisical CLI instead of operator (useful for CI/CD)
#   --ovh         Configure OVHCloud CLI credentials from Infisical
#   --stitch      Sync Stitch API key to .env file
#   --stitch-setup Setup Stitch: gcloud login + create API key + save to .env + Infisical
#
# Prerequisites:
#   - kubectl configured with cluster access
#   - infisical CLI installed (if using --cli)
#   - Helm installed (if installing operator)
#
# OVHCloud CLI configuration:
#   Secrets required in Infisical (project: altrupets, env: dev):
#   - /ovh/application_key
#   - /ovh/application_secret
#   - /ovh/consumer_key
#   - /ovh/endpoint (optional, default: ovh-eu)
#
# Stitch configuration:
#   Secrets required in Infisical (project: altrupets, env: dev):
#   - /stitch/api_key
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="altrupets-dev"
OPERATOR_NAMESPACE="infisical-operator-system"
SECRET_NAME="backend-secret"
HARBOR_SECRET_NAME="harbor-registry-secret"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

USE_CLI=false
CONFIGURE_OVH=false
SYNC_STITCH=false
SETUP_STITCH=false

# Parse arguments
for arg in "$@"; do
	case $arg in
	--cli)
		USE_CLI=true
		shift
		;;
	--ovh)
		CONFIGURE_OVH=true
		shift
		;;
	--stitch)
		SYNC_STITCH=true
		shift
		;;
	--stitch-setup)
		SETUP_STITCH=true
		shift
		;;
	esac
done

setup_stitch() {
	echo -e "${BLUE}🔧 Stitch OAuth Setup - Step by Step${NC}"
	echo ""
	echo "Stitch now uses OAuth (gcloud) instead of API keys."
	echo "You need to configure the project numbers in Infisical:"
	echo ""
	echo "1. ${GREEN}Login to gcloud:${NC}"
	echo "   gcloud auth login"
	echo ""
	echo "2. ${GREEN}Set your project (numeric-replica-487322-d7):${NC}"
	echo "   gcloud config set project numeric-replica-487322-d7"
	echo ""
	echo "3. ${GREEN}Verify you can get an OAuth token:${NC}"
	echo "   gcloud auth print-access-token"
	echo ""
	echo "4. ${GREEN}Add secrets to Infisical (project: altrupets, env: dev):${NC}"
	echo "   - GOOGLE_CLOUD_PROJECT: 344341424155"
	echo "   - STITCH_PROJECT_ID: 9064173060952920822"
	echo ""
	echo "   infisical secrets set --projectId=71bc533b-cabf-4793-9bf0-03dba6caf417 --env=dev"
	echo ""
	echo "5. ${GREEN}Sync to .env:${NC}"
	echo "   make dev-stitch-sync"
	echo ""
}

sync_stitch_env() {
	echo -e "${BLUE}Syncing Stitch credentials to .env...${NC}"

	if ! command -v infisical >/dev/null 2>&1; then
		echo -e "${RED}Infisical CLI is not installed${NC}"
		return 1
	fi

	local google_cloud_project
	google_cloud_project=$(infisical secrets get GOOGLE_CLOUD_PROJECT --env=dev --projectId=71bc533b-cabf-4793-9bf0-03dba6caf417 --plain 2>/dev/null || echo "")

	local stitch_project_id
	stitch_project_id=$(infisical secrets get STITCH_PROJECT_ID --env=dev --projectId=71bc533b-cabf-4793-9bf0-03dba6caf417 --plain 2>/dev/null || echo "")

	if [ -z "$google_cloud_project" ]; then
		echo -e "${ORANGE}GOOGLE_CLOUD_PROJECT not found in Infisical (dev environment)${NC}"
		return 1
	fi

	if [ -z "$stitch_project_id" ]; then
		echo -e "${ORANGE}STITCH_PROJECT_ID not found in Infisical (dev environment)${NC}"
		return 1
	fi

	local project_root="$SCRIPT_DIR/../.."
	local env_file="$project_root/.env"

	if [ -f "$env_file" ]; then
		if grep -q "GOOGLE_CLOUD_PROJECT=" "$env_file"; then
			sed -i "s|GOOGLE_CLOUD_PROJECT=.*|GOOGLE_CLOUD_PROJECT=$google_cloud_project|" "$env_file"
		else
			echo "" >>"$env_file"
			echo "GOOGLE_CLOUD_PROJECT=$google_cloud_project" >>"$env_file"
		fi

		if grep -q "STITCH_PROJECT_ID=" "$env_file"; then
			sed -i "s|STITCH_PROJECT_ID=.*|STITCH_PROJECT_ID=$stitch_project_id|" "$env_file"
		else
			echo "STITCH_PROJECT_ID=$stitch_project_id" >>"$env_file"
		fi
	else
		echo "GOOGLE_CLOUD_PROJECT=$google_cloud_project" >"$env_file"
		echo "STITCH_PROJECT_ID=$stitch_project_id" >>"$env_file"
	fi

	echo -e "${GREEN}✅ Stitch config synced to .env${NC}"
	echo "   GOOGLE_CLOUD_PROJECT=$google_cloud_project"
	echo "   STITCH_PROJECT_ID=$stitch_project_id"
}

echo -e "${BLUE}🔐 AltruPets - Infisical Secrets Sync${NC}"
echo ""

# Handle stitch-only operations (no kubectl needed)
if [ "$SYNC_STITCH" = true ]; then
	sync_stitch_env
	exit 0
fi

if [ "$SETUP_STITCH" = true ]; then
	setup_stitch
	exit 0
fi

# Verify kubectl
if ! command -v kubectl >/dev/null 2>&1; then
	echo -e "${RED}❌ kubectl is not installed${NC}"
	exit 1
fi

# Verify namespace exists
if ! kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
	echo -e "${BLUE}📦 Creating namespace $NAMESPACE...${NC}"
	kubectl create ns "$NAMESPACE"
fi

# Configure OVHCloud CLI if requested
if [ "$CONFIGURE_OVH" = true ]; then
	configure_ovhcloud_cli
	echo ""
fi

# Main logic
if [ "$USE_CLI" = true ]; then
	sync_via_cli
else
	# Check if operator is installed
	if check_operator; then
		echo -e "${GREEN}✅ Infisical Operator is running${NC}"

		# Check if CRD exists
		if kubectl get infisicalsecret infisical-backend-secret -n "$NAMESPACE" >/dev/null 2>&1; then
			echo -e "${GREEN}✅ InfisicalSecret CRD exists${NC}"
			force_sync_via_annotation
		else
			echo -e "${ORANGE}⚠️  InfisicalSecret CRD not found, applying...${NC}"
			apply_infisical_crd
			force_sync_via_annotation
		fi
	else
		echo -e "${ORANGE}⚠️  Infisical Operator not found${NC}"
		echo ""
		echo -e "${BLUE}Options:${NC}"
		echo "  1. Install operator (requires Helm)"
		echo "  2. Use CLI instead (--cli flag)"
		echo ""
		read -p "Install operator? [y/N]: " -n 1 -r
		echo

		if [[ $REPLY =~ ^[Yy]$ ]]; then
			install_operator
			apply_infisical_crd
			force_sync_via_annotation
		else
			echo -e "${BLUE}Falling back to CLI sync...${NC}"
			sync_via_cli
		fi
	fi
fi

# Harbor Registry Secret
HARBOR_USER=$(kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" -o jsonpath="{.data.HARBOR_USERNAME}" 2>/dev/null | base64 -d 2>/dev/null || echo "admin")
HARBOR_PASS=$(kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" -o jsonpath="{.data.HARBOR_PASSWORD}" 2>/dev/null | base64 -d 2>/dev/null || echo "Harbor12345")
HARBOR_HOST=$(kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" -o jsonpath="{.data.HARBOR_HOST}" 2>/dev/null | base64 -d 2>/dev/null || echo "localhost:30003")

create_harbor_registry_secret "$HARBOR_USER" "$HARBOR_PASS" "$HARBOR_HOST"

# Verify secrets were synced
echo ""
echo -e "${BLUE}🔍 Verifying secrets...${NC}"

SYNCED_KEYS=$(kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath='{.data}' | jq -r 'keys[]')

if echo "$SYNCED_KEYS" | grep -q "SEED_ADMIN_USERNAME"; then
	echo -e "${GREEN}✅ SEED_ADMIN_USERNAME found in secret${NC}"
else
	echo -e "${ORANGE}⚠️  SEED_ADMIN_USERNAME not found in secret${NC}"
	echo -e "${ORANGE}   Make sure it's defined in Infisical (dev environment)${NC}"
fi

# Cleanup old seed secret if exists
if kubectl get secret backend-seed-secret -n "$NAMESPACE" >/dev/null 2>&1; then
	echo ""
	echo -e "${ORANGE}🗑️  Removing legacy backend-seed-secret...${NC}"
	kubectl delete secret backend-seed-secret -n "$NAMESPACE"
	echo -e "${GREEN}✅ Legacy secret removed${NC}"
fi

# Update deployment to use only backend-secret
echo ""
echo -e "${BLUE}🔧 Ensuring deployment uses correct secret...${NC}"
kubectl set env deployment/backend -n "$NAMESPACE" SEED_ADMIN=true --dry-run=client -o yaml | kubectl apply -f - >/dev/null 2>&1 || true

# Update envFrom to use backend-secret
kubectl patch deployment backend -n "$NAMESPACE" --type=json -p '[{"op": "replace", "path": "/spec/template/spec/containers/0/envFrom", "value": [{"secretRef": {"name": "backend-secret"}}]}]' 2>/dev/null || true

echo ""
echo -e "${GREEN}✅ Infisical sync complete!${NC}"
echo ""
echo -e "${BLUE}📋 Current secrets in $SECRET_NAME:${NC}"
echo "$SYNCED_KEYS" | sed 's/^/  - /'
