#!/bin/bash

# ==============================================================================
# AltruPets - Infisical Secrets Sync
# ==============================================================================
# Synchronizes secrets from Infisical to Kubernetes
# Installs Infisical operator if not present, or uses CLI as fallback
# Also configures OVHCloud CLI credentials from Infisical
#
# Usage:
#   ./infisical-sync.sh [--cli] [--ovh]
#
# Options:
#   --cli    Use Infisical CLI instead of operator (useful for CI/CD)
#   --ovh    Configure OVHCloud CLI credentials from Infisical
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
	esac
done

echo -e "${BLUE}🔐 AltruPets - Infisical Secrets Sync${NC}"
echo ""

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

sync_via_cli() {
	echo -e "${BLUE}📥 Syncing secrets via Infisical CLI...${NC}"

	if ! command -v infisical >/dev/null 2>&1; then
		echo -e "${RED}❌ Infisical CLI is not installed${NC}"
		echo -e "${ORANGE}Install with: brew install infisical${NC}"
		exit 1
	fi

	if ! command -v jq >/dev/null 2>&1; then
		echo -e "${RED}❌ jq is not installed${NC}"
		echo -e "${ORANGE}Install with: sudo apt install jq${NC}"
		exit 1
	fi

	# Export secrets and create/update Kubernetes secret
	echo -e "${BLUE}📤 Exporting secrets from Infisical (dev environment)...${NC}"

	# Create temporary file for secrets
	TEMP_FILE=$(mktemp)
	trap "rm -f $TEMP_FILE" EXIT

	# Export secrets in JSON format and convert to env format (avoids shell quoting issues)
	cd "$SCRIPT_DIR/../.."

	if ! infisical export --env=dev --projectId 71bc533b-cabf-4793-9bf0-03dba6caf417 --format=json --silent 2>&1 | jq -r '.[] | "\(.key)=\(.value)"' >"$TEMP_FILE"; then
		echo -e "${RED}❌ Failed to export secrets from Infisical${NC}"
		echo -e "${ORANGE}Make sure you are logged in: infisical login${NC}"
		exit 1
	fi

	# Check if file has content
	if [ ! -s "$TEMP_FILE" ]; then
		echo -e "${RED}❌ No secrets exported. Check if project exists and you have access.${NC}"
		exit 1
	fi

	# Create/update the Kubernetes secret
	echo -e "${BLUE}🔄 Updating Kubernetes secret $SECRET_NAME...${NC}"
	kubectl create secret generic "$SECRET_NAME" \
		--from-env-file="$TEMP_FILE" \
		--namespace="$NAMESPACE" \
		--dry-run=client -o yaml | kubectl apply -f -

	echo -e "${GREEN}✅ Secret $SECRET_NAME synchronized${NC}"

	# Show what was synced (keys only, not values)
	echo -e "${BLUE}📋 Keys synced:${NC}"
	kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath='{.data}' | jq -r 'keys[]' | sed 's/^/  - /'
}

check_operator() {
	kubectl get pods -n "$OPERATOR_NAMESPACE" -l app.kubernetes.io/name=infisical-operator 2>/dev/null | grep -q "Running"
}

install_operator() {
	echo -e "${BLUE}📦 Installing Infisical Operator...${NC}"

	if ! command -v helm >/dev/null 2>&1; then
		echo -e "${RED}❌ Helm is not installed${NC}"
		echo -e "${ORANGE}Install with: https://helm.sh/docs/intro/install/${NC}"
		exit 1
	fi

	# Create namespace
	kubectl create ns "$OPERATOR_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

	# Add Infisical Helm repo
	helm repo add infisical-helm-charts https://infisical.github.io/helm-charts 2>/dev/null || true
	helm repo update

	# Install operator
	helm upgrade --install infisical-operator infisical-helm-charts/infisical-operator \
		--namespace "$OPERATOR_NAMESPACE" \
		--set controllerManager.manager.env[0].name=LOG_LEVEL \
		--set controllerManager.manager.env[0].value=info

	# Wait for operator to be ready
	echo -e "${BLUE}⏳ Waiting for operator to be ready...${NC}"
	kubectl rollout status deployment/infisical-operator-controller-manager -n "$OPERATOR_NAMESPACE" --timeout=120s

	echo -e "${GREEN}✅ Infisical Operator installed${NC}"
}

apply_infisical_crd() {
	echo -e "${BLUE}📝 Applying InfisicalSecret CRD...${NC}"

	local CRD_FILE="$SCRIPT_DIR/../infisical/infisical-secrets.yaml"

	if [ ! -f "$CRD_FILE" ]; then
		echo -e "${RED}❌ CRD file not found: $CRD_FILE${NC}"
		exit 1
	fi

	kubectl apply -f "$CRD_FILE"

	echo -e "${GREEN}✅ InfisicalSecret CRD applied${NC}"
}

force_sync_via_annotation() {
	echo -e "${BLUE}🔄 Forcing secret sync via annotation...${NC}"

	# Add/update annotation to trigger resync
	kubectl annotate infisicalsecret infisical-backend-secret -n "$NAMESPACE" \
		"infisical.com/force-sync=$(date +%s)" --overwrite 2>/dev/null ||
		kubectl annotate secret "$SECRET_NAME" -n "$NAMESPACE" \
			"infisical.com/force-sync=$(date +%s)" --overwrite 2>/dev/null || true

	# Wait a moment for sync
	sleep 5

	echo -e "${GREEN}✅ Sync triggered${NC}"
}

restart_backend() {
	echo -e "${BLUE}🔄 Restarting backend to pick up new secrets...${NC}"
	kubectl rollout restart deployment/backend -n "$NAMESPACE"
	kubectl rollout status deployment/backend -n "$NAMESPACE" --timeout=120s
	echo -e "${GREEN}✅ Backend restarted${NC}"
}

configure_ovhcloud_cli() {
	echo -e "${BLUE}Configuring OVHCloud CLI from Infisical...${NC}"

	if ! command -v infisical >/dev/null 2>&1; then
		echo -e "${RED}Infisical CLI is not installed${NC}"
		exit 1
	fi

	# Get OVH credentials from Infisical
	local ovh_app_key=$(infisical get -q --path /ovh/application_key --project=altrupets --env=dev 2>/dev/null || echo "")
	local ovh_app_secret=$(infisical get -q --path /ovh/application_secret --project=altrupets --env=dev 2>/dev/null || echo "")
	local ovh_consumer_key=$(infisical get -q --path /ovh/consumer_key --project=altrupets --env=dev 2>/dev/null || echo "")
	local ovh_endpoint=$(infisical get -q --path /ovh/endpoint --project=altrupets --env=dev 2>/dev/null || echo "ovh-eu")

	if [ -z "$ovh_app_key" ] || [ -z "$ovh_app_secret" ] || [ -z "$ovh_consumer_key" ]; then
		echo -e "${ORANGE}OVH credentials not found in Infisical (dev environment)${NC}"
		echo "Required secrets:"
		echo "  - /ovh/application_key"
		echo "  - /ovh/application_secret"
		echo "  - /ovh/consumer_key"
		return 1
	fi

	# Create OVH config directory
	local ovh_config_dir="$HOME/.config/ovhcloud"
	mkdir -p "$ovh_config_dir"

	# Create .ovh.conf file
	local ovh_conf_file="$ovh_config_dir/ovh.conf"
	cat >"$ovh_conf_file" <<EOF
[default]
endpoint = $ovh_endpoint
application_key = $ovh_app_key
application_secret = $ovh_app_secret
consumer_key = $ovh_consumer_key

EOF

	chmod 600 "$ovh_conf_file"
	echo -e "${GREEN}OVHCloud CLI configured successfully${NC}"
	echo "Config file: $ovh_conf_file"

	# Verify it works
	if command -v ovhcloud >/dev/null 2>&1; then
		if ovhcloud cloud project list >/dev/null 2>&1; then
			echo -e "${GREEN}OVHCloud CLI authentication verified${NC}"
		else
			echo -e "${ORANGE}OVHCloud CLI configured but authentication failed${NC}"
		fi
	fi
}

create_harbor_registry_secret() {
	local harbor_user="${1:-}"
	local harbor_pass="${2:-}"
	local harbor_host="${3:-localhost:30003}"

	if [ -z "$harbor_user" ] || [ -z "$harbor_pass" ]; then
		echo -e "${ORANGE}⚠️  Harbor credentials not provided, skipping harbor-registry-secret creation${NC}"
		return
	fi

	echo -e "${BLUE}🔄 Creating/Updating $HARBOR_SECRET_NAME...${NC}"

	# Create the auth string (base64 of user:pass)
	local auth=$(echo -n "$harbor_user:$harbor_pass" | base64 | tr -d '\n')

	# Create the .dockerconfigjson structure
	local docker_config_json=$(
		cat <<EOF
{
  "auths": {
    "$harbor_host": {
      "auth": "$auth"
    }
  }
}
EOF
	)

	echo "$docker_config_json" | kubectl create secret generic "$HARBOR_SECRET_NAME" \
		--from-literal=.dockerconfigjson=/dev/stdin \
		--type=kubernetes.io/dockerconfigjson \
		--namespace="$NAMESPACE" \
		--dry-run=client -o yaml | kubectl apply -f -

	echo -e "${GREEN}✅ Secret $HARBOR_SECRET_NAME synchronized${NC}"
}

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
