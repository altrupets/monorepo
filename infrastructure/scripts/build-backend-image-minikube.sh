#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
IMAGE_TAG="${1:-altrupets-backend:dev}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🐳 Building backend image for Minikube: ${IMAGE_TAG}${NC}"

if ! command -v minikube >/dev/null 2>&1; then
  echo -e "${RED}❌ minikube is not installed${NC}"
  exit 1
fi

if ! minikube status >/dev/null 2>&1; then
  echo -e "${RED}❌ minikube is not running. Start it first.${NC}"
  exit 1
fi

minikube image build -t "${IMAGE_TAG}" -f "$PROJECT_ROOT/apps/backend/Dockerfile" "$PROJECT_ROOT/apps/backend"

echo -e "${GREEN}✅ Image built in Minikube runtime: ${IMAGE_TAG}${NC}"
echo -e "${BLUE}Tip:${NC} if pods are already running, restart deployment:"
echo -e "  kubectl -n altrupets-dev rollout restart deployment/backend"
