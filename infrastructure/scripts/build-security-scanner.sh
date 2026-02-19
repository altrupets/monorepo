#!/bin/bash

# ==============================================================================
# AltruPets - Security Scanner Image Build
# ==============================================================================
# Builds the security scanner container image using Podman and loads it into
# Minikube for running security scans.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
IMAGE_NAME="localhost/altrupets-security-scanner"
IMAGE_TAG="latest"
DOCKERFILE="${PROJECT_ROOT}/infrastructure/docker/security-scanner/Dockerfile"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Building security scanner image...${NC}"

# Check podman
if ! command -v podman >/dev/null 2>&1; then
	echo -e "${RED}❌ podman is not installed${NC}"
	exit 1
fi

# Check minikube
if ! command -v minikube >/dev/null 2>&1; then
	echo -e "${RED}❌ minikube is not installed${NC}"
	exit 1
fi

# Build image
echo -e "${BLUE}📦 Building ${IMAGE_NAME}:${IMAGE_TAG}...${NC}"
podman build \
	-t "${IMAGE_NAME}:${IMAGE_TAG}" \
	-f "${DOCKERFILE}" \
	"${PROJECT_ROOT}"

# Load into minikube
echo -e "${BLUE}🔄 Loading image into minikube...${NC}"
podman save "${IMAGE_NAME}:${IMAGE_TAG}" | minikube image load -

echo -e "${GREEN}✓ Security scanner image built and loaded${NC}"
echo ""
echo -e "${BLUE}Run security scans with:${NC}"
echo "  make dev-security-scan"
