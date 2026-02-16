#!/bin/bash

# AltruPets - Deploy PostgreSQL to Minikube
# This script deploys PostgreSQL to Minikube using Terraform or OpenTofu
# Supports both Terraform and OpenTofu (uses whichever is available)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/infrastructure/terraform/environments/dev"
ENV_FILE="$TERRAFORM_DIR/.env"
BACKEND_ENV_FILE="$PROJECT_ROOT/apps/backend/.env"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

upsert_env_var() {
  local file="$1"
  local key="$2"
  local value="$3"
  local escaped_value=""

  mkdir -p "$(dirname "$file")"
  touch "$file"
  chmod 600 "$file"

  escaped_value="${value//\\/\\\\}"
  escaped_value="${escaped_value//&/\\&}"
  escaped_value="${escaped_value//|/\\|}"

  if grep -q "^${key}=" "$file"; then
    sed -i "s|^${key}=.*|${key}=${escaped_value}|" "$file"
  else
    printf "%s=%s\n" "$key" "$value" >> "$file"
  fi
}

read_env_var() {
  local file="$1"
  local key="$2"
  if [ -f "$file" ]; then
    grep -E "^${key}=" "$file" | tail -n 1 | cut -d '=' -f2-
  fi
}

prompt_password() {
  local password=""

  if command -v zenity &> /dev/null && [ -n "${DISPLAY:-}" ]; then
    password="$(zenity --password --title='AltruPets PostgreSQL Secret' 2>/dev/null || true)"
  elif command -v kdialog &> /dev/null && [ -n "${DISPLAY:-}" ]; then
    password="$(kdialog --password 'PostgreSQL password (local dev)' 2>/dev/null || true)"
  fi

  if [ -z "$password" ]; then
    read -rsp "Enter PostgreSQL password for local dev: " password
    echo
  fi

  echo "$password"
}

ensure_local_secret() {
  local db_password=""
  local postgres_username=""
  local postgres_database=""

  db_password="$(read_env_var "$ENV_FILE" "DB_PASSWORD")"
  postgres_username="$(read_env_var "$ENV_FILE" "POSTGRES_USERNAME")"
  postgres_database="$(read_env_var "$ENV_FILE" "POSTGRES_DATABASE")"

  if [ -z "$db_password" ]; then
    echo -e "${ORANGE}⚠️  DB_PASSWORD not found in $ENV_FILE${NC}"
    db_password="$(prompt_password)"
  fi

  if [ -z "$db_password" ]; then
    echo -e "${RED}❌ Empty password. Cannot continue.${NC}"
    exit 1
  fi

  if [ -z "$postgres_username" ]; then
    postgres_username="postgres"
  fi

  if [ -z "$postgres_database" ]; then
    postgres_database="altrupets_user_management"
  fi

  umask 077
  upsert_env_var "$ENV_FILE" "DB_PASSWORD" "$db_password"
  upsert_env_var "$ENV_FILE" "POSTGRES_USERNAME" "$postgres_username"
  upsert_env_var "$ENV_FILE" "POSTGRES_DATABASE" "$postgres_database"

  # Sync to backend .env for local development convenience
  upsert_env_var "$BACKEND_ENV_FILE" "DB_PASSWORD" "$db_password"
  upsert_env_var "$BACKEND_ENV_FILE" "DB_USERNAME" "$postgres_username"
  upsert_env_var "$BACKEND_ENV_FILE" "DB_NAME" "$postgres_database"
  upsert_env_var "$BACKEND_ENV_FILE" "DB_HOST" "postgres-dev-service"
  upsert_env_var "$BACKEND_ENV_FILE" "DB_PORT" "5432"

  export DB_PASSWORD="$db_password"
  export POSTGRES_USERNAME="$postgres_username"
  export POSTGRES_DATABASE="$postgres_database"
}

print_podman_help() {
  echo -e "${ORANGE}Podman driver detected, but Minikube could not use it without sudo.${NC}"
  echo -e "${BLUE}Option A (recommended): enable rootless mode for Minikube${NC}"
  echo -e "  ${GREEN}minikube config set driver podman${NC}"
  echo -e "  ${GREEN}minikube config set rootless true${NC}"
  echo -e "  ${GREEN}minikube start --driver=podman${NC}"
  echo -e ""
  echo -e "${BLUE}Option B: allow passwordless sudo for podman (advanced)${NC}"
  echo -e "  ${GREEN}sudo visudo${NC}"
  echo -e "  Add: ${GREEN}$USER ALL=(ALL) NOPASSWD: /usr/bin/podman${NC}"
  echo -e ""
  echo -e "${BLUE}Verify Podman rootless status:${NC}"
  echo -e "  ${GREEN}podman info --format '{{.Host.Security.Rootless}}'${NC}"
}

echo -e "${BLUE}🚀 Deploying PostgreSQL to Minikube...${NC}"

# Verificar si Minikube está instalado
if ! command -v minikube &> /dev/null; then
  echo -e "${RED}❌ Minikube is not installed.${NC}"
  echo -e "${ORANGE}Install Minikube:${NC}"
  echo -e "  Ubuntu/Debian: curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
  echo -e "                 sudo install minikube-linux-amd64 /usr/local/bin/minikube"
  echo -e "  Or visit: https://minikube.sigs.k8s.io/docs/start/"
  exit 1
fi

# Verificar y manejar estado de Minikube
if minikube status &>/dev/null && minikube status | grep -q "Running"; then
  echo -e "${GREEN}✅ Minikube is already running${NC}"
else
  echo -e "${ORANGE}⚠️  Minikube is not running. Starting Minikube...${NC}"
  echo -e "${BLUE}⏳ This may take a few minutes on first run...${NC}"
  
  START_DRIVER_ARGS=()
  if command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
    START_DRIVER_ARGS=(--driver=podman)
    echo -e "${BLUE}🔧 Podman detected as primary runtime. Trying Minikube with --driver=podman...${NC}"
  fi

  # Intentar iniciar Minikube (capturamos salida para diagnóstico sin reintentar dos veces)
  MINIKUBE_START_LOG="$(mktemp)"
  if minikube start "${START_DRIVER_ARGS[@]}" > >(tee "$MINIKUBE_START_LOG") 2> >(tee -a "$MINIKUBE_START_LOG" >&2); then
    echo -e "${GREEN}✅ Minikube started successfully!${NC}"
    # Esperar un momento para que el contexto se configure
    sleep 2
  else
    echo -e "${RED}❌ Failed to start Minikube.${NC}"

    # Diagnóstico específico para Podman
    if command -v podman &> /dev/null; then
      if grep -Eqi "sudo: a password is required|no new privileges|DRV_NOT_HEALTHY|PROVIDER_PODMAN_NOT_RUNNING" "$MINIKUBE_START_LOG"; then
        print_podman_help
      fi
    fi

    echo -e "${ORANGE}Common issues:${NC}"
    echo -e "  - Docker not running: sudo systemctl start docker"
    echo -e "  - User not in docker group: sudo usermod -aG docker \$USER"
    echo -e "  - Podman rootless: minikube config set rootless true"
    echo -e "  - Try manually: minikube start${NC}"
    rm -f "$MINIKUBE_START_LOG"
    exit 1
  fi
  rm -f "$MINIKUBE_START_LOG"
fi

# Configurar contexto de kubectl
echo -e "${BLUE}📋 Configuring kubectl context...${NC}"
kubectl config use-context minikube || {
  echo -e "${ORANGE}⚠️  Could not set kubectl context. Continuing anyway...${NC}"
}

# Detectar Terraform o OpenTofu
if command -v tofu &> /dev/null; then
  TERRAFORM_CMD="tofu"
  echo -e "${BLUE}✅ Using OpenTofu${NC}"
elif command -v terraform &> /dev/null; then
  TERRAFORM_CMD="terraform"
  echo -e "${BLUE}✅ Using Terraform${NC}"
else
  echo -e "${RED}❌ Neither Terraform nor OpenTofu is installed.${NC}"
  echo -e "${ORANGE}Install one of them:${NC}"
  echo -e "  Terraform: https://developer.hashicorp.com/terraform/downloads"
  echo -e "  OpenTofu: https://opentofu.org/docs/intro/install/"
  exit 1
fi

# Secret local handling
ensure_local_secret
echo -e "${GREEN}🔐 Local secret loaded from ${ENV_FILE}${NC}"
echo -e "${BLUE}📝 Password is not stored in terraform.tfvars; passed via runtime variables.${NC}"

# Ir al directorio de Terraform
cd "$TERRAFORM_DIR"

# Inicializar Terraform/OpenTofu
echo -e "${BLUE}🔧 Initializing ${TERRAFORM_CMD}...${NC}"
$TERRAFORM_CMD init

# Aplicar configuración
echo -e "${BLUE}🚀 Applying ${TERRAFORM_CMD} configuration...${NC}"
$TERRAFORM_CMD apply -auto-approve \
  -var "postgres_username=${POSTGRES_USERNAME}" \
  -var "postgres_password=${DB_PASSWORD}" \
  -var "postgres_database=${POSTGRES_DATABASE}"

# Esperar a que el pod esté listo
echo -e "${BLUE}⏳ Waiting for PostgreSQL pod to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s || {
  echo -e "${RED}❌ PostgreSQL pod did not become ready in time${NC}"
  echo -e "${ORANGE}Checking pod status...${NC}"
  kubectl get pods -l app=postgres
  exit 1
}

echo -e "${GREEN}✅ PostgreSQL deployed successfully!${NC}"
echo ""
echo -e "${BLUE}📊 Connection Information:${NC}"
echo -e "  Internal endpoint: ${GREEN}$($TERRAFORM_CMD output -raw postgres_service_endpoint)${NC}"
echo -e "  External NodePort: ${GREEN}$($TERRAFORM_CMD output -raw postgres_nodeport_url)${NC}"
echo ""
echo -e "${BLUE}🔗 To access PostgreSQL externally (DBeaver, etc.):${NC}"
echo -e "  ${GREEN}minikube service postgres-dev-nodeport --url${NC}"
echo ""
echo -e "${BLUE}🔌 Or use port-forward:${NC}"
echo -e "  ${GREEN}kubectl port-forward svc/postgres-dev-service 5432:5432${NC}"
echo ""
echo -e "${BLUE}📝 Backend environment variables:${NC}"
echo -e "  ${GREEN}DB_HOST=postgres-dev-service${NC}"
echo -e "  ${GREEN}DB_PORT=5432${NC}"
echo -e "  ${GREEN}DB_NAME=altrupets_user_management${NC}"
echo -e "  ${GREEN}DB_USERNAME=$($TERRAFORM_CMD output -raw postgres_username 2>/dev/null || echo 'postgres')${NC}"
