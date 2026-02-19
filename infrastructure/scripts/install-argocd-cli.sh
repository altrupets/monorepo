#!/bin/bash
# Install ArgoCD CLI if not present
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

if command -v argocd >/dev/null 2>&1; then
	VERSION=$(argocd version --client --short 2>/dev/null || echo "installed")
	echo -e "${GREEN}✓ ArgoCD CLI already installed: ${VERSION}${NC}"
	exit 0
fi

echo -e "${BLUE}Installing ArgoCD CLI...${NC}"

VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo -e "${BLUE}Downloading version: ${VERSION}${NC}"

curl -sSL -o /tmp/argocd "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64"

if command -v sudo >/dev/null 2>&1; then
	sudo install -m 555 /tmp/argocd /usr/local/bin/argocd
else
	install -m 555 /tmp/argocd "${HOME}/.local/bin/argocd"
fi

rm -f /tmp/argocd

INSTALLED_VERSION=$(argocd version --client --short 2>/dev/null || echo "installed")
echo -e "${GREEN}✓ ArgoCD CLI installed: ${INSTALLED_VERSION}${NC}"
