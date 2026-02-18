#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/infrastructure/terraform/environments/dev/.env"
ENV_NAME="${ENV_NAME:-dev}"

REPO_URL="${REPO_URL:-${1:-https://github.com/altrupets/monorepo.git}}"
TARGET_REVISION="${TARGET_REVISION:-main}"
FORCE_DB_CREDENTIALS_PROMPT=false

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

parse_args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--force-db-credentials)
			FORCE_DB_CREDENTIALS_PROMPT=true
			shift
			;;
		*)
			shift
			;;
		esac
	done
}

read_env_var() {
	local file="$1"
	local key="$2"
	if [ -f "$file" ]; then
		# Return empty string when key is missing (do not fail under set -euo pipefail)
		sed -n "s/^${key}=//p" "$file" | tail -n 1
	fi
}

upsert_env_var() {
	local file="$1"
	local key="$2"
	local value="$3"

	mkdir -p "$(dirname "$file")"
	touch "$file"
	chmod 600 "$file"

	if grep -q "^${key}=" "$file"; then
		sed -i "s|^${key}=.*|${key}=${value}|" "$file"
	else
		printf "%s=%s\n" "$key" "$value" >>"$file"
	fi
}

read_k8s_secret() {
	local namespace="$1"
	local secret_name="$2"
	local key="$3"
	kubectl -n "$namespace" get secret "$secret_name" -o "jsonpath={.data.${key}}" 2>/dev/null | base64 -d 2>/dev/null || true
}

prompt_db_credentials() {
	local username=""
	local password=""

	if command -v zenity >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
		local form
		form="$(zenity --forms --title='AltruPets PostgreSQL Credentials' \
			--text='Define usuario y contraseña PostgreSQL para backend-secret' \
			--add-entry='Usuario PostgreSQL' \
			--add-password='Contraseña PostgreSQL' 2>/dev/null || true)"
		username="$(printf '%s' "$form" | cut -d '|' -f1)"
		password="$(printf '%s' "$form" | cut -d '|' -f2)"
	elif command -v kdialog >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
		username="$(kdialog --inputbox 'Define el usuario PostgreSQL para backend-secret' 2>/dev/null || true)"
		password="$(kdialog --password 'Define la contraseña del usuario PostgreSQL para backend-secret' 2>/dev/null || true)"
	fi

	if [ -z "$username" ]; then
		read -rp "Define el usuario PostgreSQL para backend-secret: " username
	fi

	if [ -z "$password" ]; then
		read -rsp "Define la contraseña del usuario PostgreSQL para backend-secret: " password
		echo
	fi

	printf "%s\n%s" "$username" "$password"
}

prompt_admin_seed_credentials() {
	local username=""
	local password=""

	if command -v zenity >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
		local form
		form="$(zenity --forms --title='AltruPets App Seed Admin' \
			--text='Seed admin = usuario inicial de la app (no ArgoCD).' \
			--add-entry='Usuario' \
			--add-password='Contraseña' 2>/dev/null || true)"
		username="$(printf '%s' "$form" | cut -d '|' -f1)"
		password="$(printf '%s' "$form" | cut -d '|' -f2)"
	elif command -v kdialog >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
		username="$(kdialog --inputbox 'Seed admin = usuario inicial de la app (no ArgoCD). Usuario:' 2>/dev/null || true)"
		password="$(kdialog --password 'Seed admin = usuario inicial de la app (no ArgoCD). Contraseña:' 2>/dev/null || true)"
	fi

	if [ -z "$username" ]; then
		read -rp "Seed admin = usuario inicial de la app (no ArgoCD). Usuario: " username
	fi

	if [ -z "$password" ]; then
		read -rsp "Seed admin = usuario inicial de la app (no ArgoCD). Contraseña: " password
		echo
	fi

	printf "%s\n%s" "$username" "$password"
}

require_cmd kubectl
require_cmd minikube
require_cmd openssl

parse_args "$@"

if ! minikube status >/dev/null 2>&1; then
	echo -e "${RED}❌ Minikube is not running. Start it first.${NC}"
	exit 1
fi

echo -e "${BLUE}📌 Using repo: ${REPO_URL}${NC}"

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

DB_CREDS_SOURCE="env"

if [ "$FORCE_DB_CREDENTIALS_PROMPT" = true ]; then
	DB_CREDS_SOURCE="prompt"
	creds="$(prompt_db_credentials)"
	DB_USERNAME="$(printf '%s' "$creds" | sed -n '1p')"
	DB_PASSWORD="$(printf '%s' "$creds" | sed -n '2p')"
fi

if [ -z "${DB_PASSWORD}" ]; then
	echo -e "${ORANGE}⚠️  DB_PASSWORD not found in $ENV_FILE${NC}"
	if [ -z "${DB_USERNAME}" ]; then
		echo -e "${ORANGE}⚠️  POSTGRES_USERNAME not found in $ENV_FILE${NC}"
		creds="$(prompt_db_credentials)"
		DB_USERNAME="$(printf '%s' "$creds" | sed -n '1p')"
		DB_PASSWORD="$(printf '%s' "$creds" | sed -n '2p')"
		DB_CREDS_SOURCE="prompt"
	else
		DB_PASSWORD="$(prompt_db_credentials | sed -n '2p')"
		DB_CREDS_SOURCE="prompt"
	fi
fi

if [ -z "${DB_PASSWORD}" ]; then
	echo -e "${RED}❌ DB_PASSWORD is empty.${NC}"
	exit 1
fi

if [ -z "${DB_USERNAME}" ]; then
	DB_USERNAME="dev_demo_admin"
fi

if [ -z "${DB_NAME}" ]; then
	DB_NAME="altrupets_${ENV_NAME}_database"
fi

POSTGRES_SECRET_PASSWORD="$(read_k8s_secret "default" "postgres-dev-secret" "password")"
POSTGRES_SECRET_USERNAME="$(read_k8s_secret "default" "postgres-dev-secret" "username")"
POSTGRES_SECRET_DATABASE="$(read_k8s_secret "default" "postgres-dev-secret" "database")"

if [ -n "${POSTGRES_SECRET_PASSWORD}" ] && [ -z "${DB_PASSWORD}" ]; then
	DB_PASSWORD="${POSTGRES_SECRET_PASSWORD}"
	DB_CREDS_SOURCE="cluster-secret"
fi

if [ -n "${POSTGRES_SECRET_USERNAME}" ] && [ -z "${DB_USERNAME}" ]; then
	DB_USERNAME="${POSTGRES_SECRET_USERNAME}"
	DB_CREDS_SOURCE="cluster-secret"
fi

if [ -n "${POSTGRES_SECRET_DATABASE}" ] && [ -z "${DB_NAME}" ]; then
	DB_NAME="${POSTGRES_SECRET_DATABASE}"
fi

JWT_SECRET="$(read_env_var "$ENV_FILE" "JWT_SECRET")"
if [ -z "${JWT_SECRET}" ]; then
	JWT_SECRET="$(openssl rand -hex 32)"
	echo -e "${BLUE}🔐 JWT_SECRET was missing. Generated and persisted to ${ENV_FILE}.${NC}"
	upsert_env_var "$ENV_FILE" "JWT_SECRET" "$JWT_SECRET"
fi

if [ "$ENABLE_ADMIN_SEED" = "true" ]; then
	if [ -z "${SEED_ADMIN_USERNAME}" ] || [ -z "${SEED_ADMIN_PASSWORD}" ]; then
		creds="$(prompt_admin_seed_credentials)"
		if [ -z "${SEED_ADMIN_USERNAME}" ]; then
			SEED_ADMIN_USERNAME="$(printf '%s' "$creds" | sed -n '1p')"
		fi
		if [ -z "${SEED_ADMIN_PASSWORD}" ]; then
			SEED_ADMIN_PASSWORD="$(printf '%s' "$creds" | sed -n '2p')"
		fi
	fi
	if [ -z "${SEED_ADMIN_USERNAME}" ]; then
		SEED_ADMIN_USERNAME="dev_demo_admin"
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

echo -e "${BLUE}📝 DB credentials source: ${DB_CREDS_SOURCE}${NC}"

kubectl -n altrupets-dev create secret generic backend-secret \
	--from-literal=DB_USERNAME="${DB_USERNAME}" \
	--from-literal=DB_PASSWORD="${DB_PASSWORD}" \
	--from-literal=DB_NAME="${DB_NAME}" \
	--from-literal=ENV_NAME="${ENV_NAME}" \
	--from-literal=JWT_SECRET="${JWT_SECRET}" \
	--from-literal=SEED_ADMIN="${ENABLE_ADMIN_SEED}" \
	--from-literal=SEED_ADMIN_USERNAME="${SEED_ADMIN_USERNAME:-}" \
	--from-literal=SEED_ADMIN_PASSWORD="${SEED_ADMIN_PASSWORD:-}" \
	--dry-run=client -o yaml | kubectl apply -f -

echo -e "${BLUE}📦 Applying ArgoCD project...${NC}"
kubectl apply -f "$PROJECT_ROOT/k8s/argocd/projects/altrupets-dev-project.yaml"

echo -e "${BLUE}📦 Applying ArgoCD applications...${NC}"

# Backend application
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

# Web Superusers application
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: altrupets-web-superusers-dev
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: altrupets-dev
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${TARGET_REVISION}
    path: k8s/overlays/dev/web-superusers
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

# Web B2G application
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: altrupets-web-b2g-dev
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: altrupets-dev
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${TARGET_REVISION}
    path: k8s/overlays/dev/web-b2g
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

echo -e "${GREEN}✅ ArgoCD bootstrapped with 3 applications${NC}"
echo -e "${BLUE}Applications:${NC}"
echo -e "  - altrupets-backend-dev"
echo -e "  - altrupets-web-superusers-dev"
echo -e "  - altrupets-web-b2g-dev"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1) Build images in Minikube runtime:"
echo -e "     ${GREEN}./infrastructure/scripts/build-backend-image-minikube.sh${NC}"
echo -e "     ${GREEN}./infrastructure/scripts/build-web-images-minikube.sh superusers${NC}"
echo -e "     ${GREEN}./infrastructure/scripts/build-web-images-minikube.sh b2g${NC}"
echo -e "  2) Check app sync:"
echo -e "     ${GREEN}kubectl -n argocd get applications${NC}"
echo -e "  3) Port-forward Gateway:"
echo -e "     ${GREEN}kubectl port-forward -n nginx-gateway svc/gateway-nodeport 3001:80${NC}"
echo -e "  4) ArgoCD admin password:"
echo -e "     ${GREEN}kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo${NC}"
if [ "$ENABLE_ADMIN_SEED" = "true" ]; then
	echo -e "  5) Backend seed admin credentials (dev):"
	echo -e "     ${GREEN}username=${SEED_ADMIN_USERNAME}${NC}"
	echo -e "     ${GREEN}password=[REDACTED]${NC}"
fi
