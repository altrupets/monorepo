#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/apps/backend"
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

BUILD_LOG="$(mktemp)"
if [ ! -d "$BACKEND_DIR" ]; then
  echo -e "${RED}❌ Backend directory not found: $BACKEND_DIR${NC}"
  rm -f "$BUILD_LOG"
  exit 1
fi

cd "$BACKEND_DIR"
if ! minikube image build -t "${IMAGE_TAG}" -f Dockerfile . 2>&1 | tee "$BUILD_LOG"; then
  echo -e "${RED}❌ Minikube image build command failed.${NC}"
  rm -f "$BUILD_LOG"
  exit 1
fi

if grep -qi "ERROR: failed to build" "$BUILD_LOG"; then
  echo -e "${RED}❌ Build output reported failure (ERROR: failed to build).${NC}"
  rm -f "$BUILD_LOG"
  exit 1
fi

if ! minikube image ls | grep -Fq "${IMAGE_TAG}"; then
  echo -e "${RED}❌ Image ${IMAGE_TAG} not found in Minikube runtime after build.${NC}"
  rm -f "$BUILD_LOG"
  exit 1
fi

rm -f "$BUILD_LOG"

echo -e "${GREEN}✅ Image built in Minikube runtime: ${IMAGE_TAG}${NC}"
echo -e "${BLUE}Tip:${NC} if pods are already running, restart deployment:"
echo -e "  kubectl -n altrupets-dev rollout restart deployment/backend"
