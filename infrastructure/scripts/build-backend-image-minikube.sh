#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/apps/backend"
IMAGE_TAG="localhost/altrupets-backend:dev"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🐳 Building backend image: ${IMAGE_TAG}${NC}"

if ! command -v podman >/dev/null 2>&1; then
	echo -e "${RED}❌ podman is not installed${NC}"
	exit 1
fi

if ! command -v minikube >/dev/null 2>&1; then
	echo -e "${RED}❌ minikube is not installed${NC}"
	exit 1
fi

if ! minikube status >/dev/null 2>&1; then
	echo -e "${RED}❌ minikube is not running. Start it first.${NC}"
	exit 1
fi

if [ ! -d "$BACKEND_DIR" ]; then
	echo -e "${RED}❌ Backend directory not found: $BACKEND_DIR${NC}"
	exit 1
fi

cd "$PROJECT_ROOT"

if ! podman build -t "${IMAGE_TAG}" -f "$BACKEND_DIR/Dockerfile" "$BACKEND_DIR" 2>&1; then
	echo -e "${RED}❌ Failed to build backend image${NC}"
	exit 1
fi

echo -e "${BLUE}📦 Loading image into minikube...${NC}"
if ! podman save "${IMAGE_TAG}" | minikube image load -; then
	echo -e "${RED}❌ Failed to load image into minikube${NC}"
	exit 1
fi

echo -e "${GREEN}✅ Image built and loaded: ${IMAGE_TAG}${NC}"
