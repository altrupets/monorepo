#!/bin/bash
#
# Deploy Harbor registry in Minikube via Helm
# Usage: ./setup-harbor.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

HARBOR_NAMESPACE="${HARBOR_NAMESPACE:-harbor}"
HARBOR_VERSION="${HARBOR_VERSION:-}"
STORAGE_SIZE="${STORAGE_SIZE:-20Gi}"
HTTPS_NODE_PORT="${HTTPS_NODE_PORT:-30003}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Harbor12345}"

log_header "Deploying Harbor Registry"

require_cmd helm "Install helm: https://helm.sh/docs/intro/install/"
require_cmd kubectl "Install kubectl: https://kubernetes.io/docs/tasks/tools/"

if ! minikube status >/dev/null 2>&1; then
	log_error "Minikube is not running. Start it first."
	exit 1
fi

kubectl create namespace "${HARBOR_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

log_info "Adding Harbor Helm repository..."
helm repo add harbor https://helm.goharbor.io 2>/dev/null || true
helm repo update

VERSION_FLAG=""
if [ -n "$HARBOR_VERSION" ]; then
	VERSION_FLAG="--version ${HARBOR_VERSION}"
fi

log_info "Installing Harbor via Helm (this may take a few minutes)..."
helm upgrade --install harbor harbor/harbor \
	-n "${HARBOR_NAMESPACE}" \
	$VERSION_FLAG \
	--set persistence.enabled=true \
	--set persistence.persistentVolumeClaim.registry.size="${STORAGE_SIZE}" \
	--set expose.type=nodePort \
	--set expose.tls.auto.commonName="localhost" \
	--set expose.nodePort.ports.https.nodePort="${HTTPS_NODE_PORT}" \
	--set externalURL="https://localhost:${HTTPS_NODE_PORT}" \
	--set harborAdminPassword="${ADMIN_PASSWORD}" \
	--set trivy.enabled=true \
	--set chartmuseum.enabled=true \
	--wait --timeout=15m

log_success "Harbor deployed successfully!"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Harbor Registry Access${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BLUE}URL:${NC}      https://localhost:${HTTPS_NODE_PORT}"
echo -e "  ${BLUE}Username:${NC} admin"
echo -e "  ${BLUE}Password:${NC} ${ADMIN_PASSWORD}"
echo ""
echo -e "${GREEN}Configure Docker/Podman:${NC}"
echo "  sudo mkdir -p /etc/docker/certs.d/localhost:${HTTPS_NODE_PORT}"
echo "  kubectl get secret -n ${HARBOR_NAMESPACE} harbor-ingress -o jsonpath='{.data.ca\.crt}' | base64 -d | sudo tee /etc/docker/certs.d/localhost:${HTTPS_NODE_PORT}/ca.crt"
echo ""
echo -e "${GREEN}Login:${NC}"
echo "  echo '${ADMIN_PASSWORD}' | podman login localhost:${HTTPS_NODE_PORT} -u admin --password-stdin"
echo ""
echo -e "${GREEN}Push images:${NC}"
echo "  podman tag localhost/altrupets-backend:dev localhost:${HTTPS_NODE_PORT}/altrupets/backend:dev"
echo "  podman push localhost:${HTTPS_NODE_PORT}/altrupets/backend:dev"
echo ""
