#!/bin/bash

# ==============================================================================
# AltruPets - Create Fallback Dev Secret
# ==============================================================================
# Creates a backend-secret with auto-generated dev defaults when Infisical
# is unavailable. Secrets are generated at runtime, never stored in source.
#
# Usage: ./create-fallback-secret.sh
#
# This is a DEV-ONLY fallback. For real secrets, use:
#   infisical login && make dev-infisical-sync-cli
# ==============================================================================

set -euo pipefail

NAMESPACE="altrupets-dev"
SECRET_NAME="backend-secret"

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'

echo -e "${ORANGE}⚠️  Infisical unavailable — creating fallback dev secret...${NC}"

# Generate random passwords at runtime (never hardcoded in source)
DB_PASSWORD="dev-$(openssl rand -hex 12)"
JWT_SECRET="dev-jwt-$(openssl rand -hex 24)"
SEED_PASSWORD="dev-admin-$(openssl rand -hex 8)"

kubectl create secret generic "$SECRET_NAME" \
  --from-literal=DB_HOST="postgres-dev-service.${NAMESPACE}.svc.cluster.local" \
  --from-literal=DB_PORT=5432 \
  --from-literal=DB_USERNAME=altrupets_dev \
  --from-literal=DB_PASSWORD="$DB_PASSWORD" \
  --from-literal=DB_NAME=altrupets_dev \
  --from-literal=JWT_SECRET="$JWT_SECRET" \
  --from-literal=SEED_ADMIN_USERNAME=admin@altrupets.app \
  --from-literal=SEED_ADMIN_PASSWORD="$SEED_PASSWORD" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✅ Fallback dev secret created with auto-generated passwords${NC}"
echo -e "${ORANGE}⚠️  NOT for production — run 'infisical login' + 'make dev-infisical-sync-cli' when available${NC}"
