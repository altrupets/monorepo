#!/bin/bash
#
# Configure ArgoCD with local file:// repository
# This is an EMERGENCY setup for offline/air-gapped development
#
# IMPORTANT: This requires manual volume mount configuration in ArgoCD
# See: https://github.com/argoproj/argo-cd/discussions/9912
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

MOUNT_PATH="${MOUNT_PATH:-/mnt/altrupets-monorepo}"

log_header "Setting up ArgoCD Local Repository"

if ! kubectl get namespace argocd >/dev/null 2>&1; then
	log_error "ArgoCD is not installed. Run 'make dev-argocd-deploy' first."
	exit 1
fi

log_info "Creating local repository Secret..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: local-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  name: local-repo
  url: file://${MOUNT_PATH}
EOF

log_success "Local repository Secret created!"
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  IMPORTANT: Manual Steps Required${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}1. Mount local repository in Minikube:${NC}"
echo "   minikube mount ${PROJECT_ROOT}:${MOUNT_PATH} &"
echo ""
echo -e "${BLUE}2. Patch ArgoCD repo-server to mount the volume:${NC}"
echo "   kubectl patch deployment argocd-repo-server -n argocd --type='json' -p='["
echo "     {\"op\": \"add\", \"path\": \"/spec/template/spec/volumes/-\", \"value\": {"
echo "       \"name\": \"local-repo\", \"hostPath\": {\"path\": \"${MOUNT_PATH}\", \"type\": \"Directory\"}"
echo "     }},"
echo "     {\"op\": \"add\", \"path\": \"/spec/template/spec/containers/0/volumeMounts/-\", \"value\": {"
echo "       \"name\": \"local-repo\", \"mountPath\": \"${MOUNT_PATH}\""
echo "     }}"
echo "   ]'"
echo ""
echo -e "${BLUE}3. Update Applications to use local repo:${NC}"
echo "   kubectl patch application altrupets-backend-dev -n argocd --type='merge' -p='{"
echo "     \"spec\": {\"source\": {\"repoURL\": \"file://${MOUNT_PATH}\"}}"
echo "   }'"
echo ""
echo -e "${YELLOW}Note: This is an emergency setup. For regular development, use:${NC}"
echo -e "${YELLOW}  - make dev-argocd-push-and-deploy (push to remote)${NC}"
echo -e "${YELLOW}  - make dev-argocd-sync-local (sync from local)${NC}"
echo ""
