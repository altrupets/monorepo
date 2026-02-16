#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/infrastructure/terraform/environments/dev/.env"

REPO_URL="${REPO_URL:-${1:-}}"
TARGET_REVISION="${TARGET_REVISION:-main}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo -e "${RED}❌ Required command not found: $1${NC}"
    exit 1
  fi
}

read_env_var() {
  local file="$1"
  local key="$2"
  if [ -f "$file" ]; then
    # Return empty string when key is missing (do not fail under set -euo pipefail)
    sed -n "s/^${key}=//p" "$file" | tail -n 1
  fi
}

prompt_password() {
  local password=""

  if command -v zenity >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
    password="$(zenity --password --title='AltruPets PostgreSQL Secret' 2>/dev/null || true)"
  fi

  if [ -z "$password" ]; then
    read -rsp "Enter PostgreSQL password for backend-secret: " password
    echo
  fi

  echo "$password"
}

prompt_admin_seed_password() {
  local password=""

  if command -v zenity >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
    password="$(zenity --password --title='AltruPets Admin Seed Password' \
      --text='Define la contraseña para dev_demo_admin' 2>/dev/null || true)"
  elif command -v kdialog >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
    password="$(kdialog --password 'Define la contraseña para dev_demo_admin' 2>/dev/null || true)"
  fi

  if [ -z "$password" ]; then
    read -rsp "Define la contraseña para dev_demo_admin: " password
    echo
  fi

  echo "$password"
}

require_cmd kubectl
require_cmd minikube
require_cmd openssl

if ! minikube status >/dev/null 2>&1; then
  echo -e "${RED}❌ Minikube is not running. Start it first.${NC}"
  exit 1
fi

if [ -z "$REPO_URL" ]; then
  echo -e "${RED}❌ Missing repo URL.${NC}"
  echo -e "Use: REPO_URL=https://github.com/<org>/<repo>.git $0"
  exit 1
fi

echo -e "${BLUE}🚀 Installing/ensuring ArgoCD in Minikube...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
# Use server-side apply to avoid oversized last-applied annotation on large CRDs.
# If there are field-manager conflicts from previous client-side installs, force takeover in dev.
if ! kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml; then
  echo -e "${ORANGE}⚠️  ArgoCD apply had field-manager conflicts. Retrying with --force-conflicts (dev mode).${NC}"
  kubectl apply --server-side --force-conflicts -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
fi
kubectl -n argocd rollout status deployment/argocd-server --timeout=180s

echo -e "${BLUE}🔐 Creating backend secret in namespace altrupets-dev...${NC}"
kubectl create namespace altrupets-dev --dry-run=client -o yaml | kubectl apply -f -

DB_PASSWORD="$(read_env_var "$ENV_FILE" "DB_PASSWORD")"
DB_USERNAME="$(read_env_var "$ENV_FILE" "POSTGRES_USERNAME")"
DB_NAME="$(read_env_var "$ENV_FILE" "POSTGRES_DATABASE")"
SEED_ADMIN_USERNAME="${SEED_ADMIN_USERNAME:-$(read_env_var "$ENV_FILE" "SEED_ADMIN_USERNAME")}"
SEED_ADMIN_PASSWORD="${SEED_ADMIN_PASSWORD:-$(read_env_var "$ENV_FILE" "SEED_ADMIN_PASSWORD")}"
ENABLE_ADMIN_SEED="${ENABLE_ADMIN_SEED:-true}"

if [ -z "${DB_PASSWORD}" ]; then
  echo -e "${ORANGE}⚠️  DB_PASSWORD not found in $ENV_FILE${NC}"
  DB_PASSWORD="$(prompt_password)"
fi

if [ -z "${DB_PASSWORD}" ]; then
  echo -e "${RED}❌ DB_PASSWORD is empty.${NC}"
  exit 1
fi

if [ -z "${DB_USERNAME}" ]; then
  DB_USERNAME="postgres"
fi

if [ -z "${DB_NAME}" ]; then
  DB_NAME="altrupets_user_management"
fi

JWT_SECRET="$(read_env_var "$ENV_FILE" "JWT_SECRET")"
if [ -z "${JWT_SECRET}" ]; then
  JWT_SECRET="$(openssl rand -hex 32)"
fi

if [ "$ENABLE_ADMIN_SEED" = "true" ]; then
  if [ -z "${SEED_ADMIN_USERNAME}" ]; then
    SEED_ADMIN_USERNAME="dev_demo_admin"
  fi
  if [ -z "${SEED_ADMIN_PASSWORD}" ]; then
    SEED_ADMIN_PASSWORD="$(prompt_admin_seed_password)"
  fi
  if [ -z "${SEED_ADMIN_PASSWORD}" ]; then
    echo -e "${RED}❌ Debes definir la contraseña para ${SEED_ADMIN_USERNAME}.${NC}"
    exit 1
  fi
  if [ "${#SEED_ADMIN_PASSWORD}" -lt 12 ]; then
    echo -e "${RED}❌ La contraseña para ${SEED_ADMIN_USERNAME} debe tener al menos 12 caracteres.${NC}"
    exit 1
  fi
fi

kubectl -n altrupets-dev create secret generic backend-secret \
  --from-literal=DB_USERNAME="${DB_USERNAME}" \
  --from-literal=DB_PASSWORD="${DB_PASSWORD}" \
  --from-literal=JWT_SECRET="${JWT_SECRET}" \
  --from-literal=SEED_ADMIN="${ENABLE_ADMIN_SEED}" \
  --from-literal=SEED_ADMIN_USERNAME="${SEED_ADMIN_USERNAME:-}" \
  --from-literal=SEED_ADMIN_PASSWORD="${SEED_ADMIN_PASSWORD:-}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo -e "${BLUE}📦 Applying ArgoCD project...${NC}"
kubectl apply -f "$PROJECT_ROOT/k8s/argocd/projects/altrupets-dev-project.yaml"

echo -e "${BLUE}📦 Applying ArgoCD application...${NC}"
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: altrupets-backend-dev
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: altrupets-dev
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${TARGET_REVISION}
    path: k8s/overlays/dev/backend
  destination:
    server: https://kubernetes.default.svc
    namespace: altrupets-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

echo -e "${GREEN}✅ ArgoCD bootstrapped for backend dev${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1) Build image in Minikube runtime:"
echo -e "     ${GREEN}./infrastructure/scripts/build-backend-image-minikube.sh${NC}"
echo -e "  2) Check app sync:"
echo -e "     ${GREEN}kubectl -n argocd get applications${NC}"
echo -e "  3) Port-forward backend:"
echo -e "     ${GREEN}kubectl -n altrupets-dev port-forward svc/backend-service 3001:3001${NC}"
echo -e "  4) ArgoCD admin password:"
echo -e "     ${GREEN}kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo${NC}"
if [ "$ENABLE_ADMIN_SEED" = "true" ]; then
  echo -e "  5) Backend seed admin credentials (dev):"
  echo -e "     ${GREEN}username=${SEED_ADMIN_USERNAME}${NC}"
  echo -e "     ${GREEN}password=${SEED_ADMIN_PASSWORD}${NC}"
fi
