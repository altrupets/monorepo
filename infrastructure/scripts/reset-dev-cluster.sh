#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/infrastructure/terraform/environments/dev/.env"
LOG_DIR="$PROJECT_ROOT/logs/backend/reset"

MODE="hard"
SKIP_BOOTSTRAP=false
DELETE_PVCS=false
REPO_URL="${REPO_URL:-}"
TARGET_REVISION="${TARGET_REVISION:-main}"
LOG_FILE="${LOG_FILE:-}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_step() {
  local current="$1"
  local total="$2"
  local message="$3"
  echo -e "${BLUE}▶️  [${current}/${total}] ${message}${NC}"
}

init_logging() {
  if [ -z "$LOG_FILE" ]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    LOG_FILE="$LOG_DIR/altrupets-reset-dev-${ts}.log"
  fi
  mkdir -p "$(dirname "$LOG_FILE")"
  touch "$LOG_FILE"
  echo -e "${BLUE}🧾 Log file: ${LOG_FILE}${NC}"
  exec > >(tee -a "$LOG_FILE") 2>&1
}

show_help() {
  cat <<EOF
Uso:
  ./infrastructure/scripts/reset-dev-cluster.sh [soft|hard|full] [opciones]

Opciones:
  --mode soft|hard|full     Nivel de reset (default: hard)
                            soft: borra recursos app (altrupets-dev + app/proyecto ArgoCD)
                            hard: soft + borra namespace argocd completo
                            full: hard + minikube delete (cluster desde cero)
  --repo-url URL            Repo para re-bootstrap ArgoCD (si no viene por env REPO_URL)
  --target-revision REF     Rama/tag para ArgoCD (default: main)
  --skip-bootstrap          Solo resetea, no reprovisiona/bootstrapea
  --delete-pvcs             Borra PVCs de PostgreSQL (app=postgres)
  -h, --help                Muestra esta ayuda

Ejemplos:
  REPO_URL=https://github.com/altrupets/monorepo.git \\
    ./infrastructure/scripts/reset-dev-cluster.sh --mode full

  ./infrastructure/scripts/reset-dev-cluster.sh hard

  ./infrastructure/scripts/reset-dev-cluster.sh --mode soft --skip-bootstrap
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo -e "${RED}❌ Comando requerido no encontrado: $1${NC}"
    exit 1
  fi
}

read_env_var() {
  local file="$1"
  local key="$2"
  if [ -f "$file" ]; then
    sed -n "s/^${key}=//p" "$file" | tail -n 1
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --mode requiere valor: soft|hard|full${NC}"
          exit 1
        fi
        MODE="$2"
        shift 2
        ;;
      --repo-url)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --repo-url requiere un valor${NC}"
          exit 1
        fi
        REPO_URL="$2"
        shift 2
        ;;
      --target-revision)
        if [[ -z "${2:-}" ]]; then
          echo -e "${RED}❌ --target-revision requiere un valor${NC}"
          exit 1
        fi
        TARGET_REVISION="$2"
        shift 2
        ;;
      --skip-bootstrap)
        SKIP_BOOTSTRAP=true
        shift
        ;;
      --delete-pvcs)
        DELETE_PVCS=true
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        if [[ "$1" == "soft" || "$1" == "hard" || "$1" == "full" ]]; then
          MODE="$1"
          shift
        else
          echo -e "${RED}❌ Opción desconocida: $1${NC}"
          show_help
          exit 1
        fi
        ;;
    esac
  done
}

confirm_destructive_action() {
  echo -e "${RED}⚠️  ADVERTENCIA: operación destructiva en cluster local.${NC}"
  echo -e "${BLUE}Resumen por modo:${NC}"
  echo -e "  ${GREEN}soft${NC}: borra namespace ${ORANGE}altrupets-dev${NC} y limpia Application/AppProject de ArgoCD."
  echo -e "  ${GREEN}hard${NC}: todo lo de soft + borra namespace ${ORANGE}argocd${NC} completo."
  echo -e "  ${GREEN}full${NC}: todo lo de hard + ejecuta ${ORANGE}minikube delete${NC} (elimina cluster Minikube local: control plane y nodo)."
  echo -e "  ${GREEN}--delete-pvcs${NC}: opcional, borra PVCs con label ${ORANGE}app=postgres${NC}."
  echo
  echo -e "${ORANGE}Modo elegido: ${MODE}${NC}"
  echo -n "Para confirmar escribe exactamente: ${MODE} > "
  read -r confirmation
  if [ "$confirmation" != "$MODE" ]; then
    echo -e "${ORANGE}Operación cancelada.${NC}"
    exit 1
  fi
}

delete_namespace_if_exists() {
  local ns="$1"
  if kubectl get namespace "$ns" >/dev/null 2>&1; then
    echo -e "${BLUE}🗑️  Eliminando namespace ${ns}...${NC}"
    kubectl delete namespace "$ns" --wait=false >/dev/null

    local started_at
    started_at="$(date +%s)"
    while kubectl get namespace "$ns" >/dev/null 2>&1; do
      local phase
      local now
      local elapsed
      phase="$(kubectl get namespace "$ns" -o jsonpath='{.status.phase}' 2>/dev/null || echo "unknown")"
      now="$(date +%s)"
      elapsed=$((now - started_at))
      echo -e "${ORANGE}⏳ namespace/${ns} estado=${phase} (${elapsed}s)${NC}"
      kubectl get events -A \
        --field-selector "involvedObject.kind=Namespace,involvedObject.name=${ns}" \
        --sort-by=.lastTimestamp 2>/dev/null | tail -n 3 || true
      sleep 5
    done
    echo -e "${GREEN}✅ namespace/${ns} eliminado.${NC}"
  else
    echo -e "${ORANGE}ℹ️  Namespace ${ns} no existe. Saltando.${NC}"
  fi
}

delete_argocd_resource_if_exists() {
  local kind="$1"
  local name="$2"
  local timeout_seconds="${3:-120}"

  if ! kubectl -n argocd get "$kind" "$name" >/dev/null 2>&1; then
    echo -e "${ORANGE}     • ${kind}/${name} no existe${NC}"
    return 0
  fi

  echo -e "${ORANGE}     • Deleting ${kind}/${name}${NC}"
  kubectl -n argocd delete "$kind" "$name" --ignore-not-found=true --wait=false >/dev/null 2>&1 || true

  local started_at
  started_at="$(date +%s)"
  while kubectl -n argocd get "$kind" "$name" >/dev/null 2>&1; do
    local now elapsed finalizers
    now="$(date +%s)"
    elapsed=$((now - started_at))
    finalizers="$(kubectl -n argocd get "$kind" "$name" -o jsonpath='{.metadata.finalizers}' 2>/dev/null || echo "[]")"
    echo -e "${ORANGE}       ⏳ ${kind}/${name} sigue presente (${elapsed}s), finalizers=${finalizers}${NC}"
    kubectl -n argocd get events --sort-by=.lastTimestamp 2>/dev/null | tail -n 4 || true

    if [ "$elapsed" -ge "$timeout_seconds" ]; then
      echo -e "${ORANGE}       ⚠️  Timeout eliminando ${kind}/${name}. Intentando limpiar finalizers...${NC}"
      kubectl -n argocd patch "$kind" "$name" --type merge -p '{"metadata":{"finalizers":[]}}' >/dev/null 2>&1 || true
      kubectl -n argocd delete "$kind" "$name" --ignore-not-found=true --wait=false >/dev/null 2>&1 || true
      sleep 3
      if kubectl -n argocd get "$kind" "$name" >/dev/null 2>&1; then
        echo -e "${RED}       ❌ ${kind}/${name} sigue atascado después de limpiar finalizers.${NC}"
        return 1
      fi
      break
    fi
    sleep 5
  done

  echo -e "${GREEN}     ✓ ${kind}/${name} eliminado${NC}"
}

reset_soft() {
  echo -e "${BLUE}🧹 Reset SOFT: limpiando recursos de app...${NC}"
  echo -e "${BLUE}   - Objetivo 1: namespace altrupets-dev${NC}"
  delete_namespace_if_exists "altrupets-dev"

  if kubectl get namespace argocd >/dev/null 2>&1; then
    echo -e "${BLUE}   - Objetivo 2: limpiar recursos ArgoCD de la app${NC}"
    delete_argocd_resource_if_exists "application" "altrupets-backend-dev" 120
    delete_argocd_resource_if_exists "appproject" "altrupets-dev" 120
    echo -e "${GREEN}   - Limpieza ArgoCD finalizada${NC}"
  else
    echo -e "${ORANGE}   - Namespace argocd no existe. No hay recursos ArgoCD que limpiar.${NC}"
  fi
}

reset_hard() {
  echo -e "${BLUE}🧹 Reset HARD: reset soft + ArgoCD completo...${NC}"
  echo -e "${BLUE}   - Subpaso A: ejecutar reset_soft${NC}"
  reset_soft
  echo -e "${GREEN}   - Subpaso A completado${NC}"
  echo -e "${BLUE}   - Subpaso B: limpiar PostgreSQL dev (statefulset/secret/service)${NC}"
  if kubectl -n default get statefulset postgres-dev >/dev/null 2>&1; then
    echo -e "${ORANGE}     • Deleting statefulset/postgres-dev${NC}"
    kubectl -n default delete statefulset postgres-dev --wait=false >/dev/null 2>&1 || true
  else
    echo -e "${ORANGE}     • statefulset/postgres-dev no existe${NC}"
  fi
  if kubectl -n default get svc postgres-dev-service >/dev/null 2>&1; then
    echo -e "${ORANGE}     • Deleting service/postgres-dev-service${NC}"
    kubectl -n default delete svc postgres-dev-service --wait=false >/dev/null 2>&1 || true
  else
    echo -e "${ORANGE}     • service/postgres-dev-service no existe${NC}"
  fi
  if kubectl -n default get secret postgres-dev-secret >/dev/null 2>&1; then
    echo -e "${ORANGE}     • Deleting secret/postgres-dev-secret${NC}"
    kubectl -n default delete secret postgres-dev-secret --wait=false >/dev/null 2>&1 || true
  else
    echo -e "${ORANGE}     • secret/postgres-dev-secret no existe${NC}"
  fi
  if [ "$DELETE_PVCS" = true ]; then
    local pg_pvcs
    pg_pvcs="$(kubectl -n default get pvc -l app=postgres --no-headers 2>/dev/null | awk '{print $1}')"
    if [ -n "$pg_pvcs" ]; then
      echo -e "${ORANGE}     • Deleting PVCs (app=postgres)${NC}"
      while IFS= read -r pvc_name; do
        [ -z "$pvc_name" ] && continue
        echo -e "       - pvc/${pvc_name}"
        kubectl -n default delete pvc "$pvc_name" --wait=false >/dev/null 2>&1 || true
      done <<< "$pg_pvcs"
    else
      echo -e "${ORANGE}     • No PVCs con label app=postgres${NC}"
    fi
  else
    echo -e "${ORANGE}     • PVCs no se borran (usa --delete-pvcs para eliminarlos)${NC}"
  fi
  echo -e "${GREEN}   - Subpaso B completado${NC}"
  echo -e "${BLUE}   - Subpaso C: eliminar namespace argocd${NC}"
  delete_namespace_if_exists "argocd"
  echo -e "${GREEN}   - Subpaso C completado${NC}"
  echo -e "${GREEN}✅ Reset HARD completado${NC}"
}

reset_full() {
  echo -e "${BLUE}🧨 Reset FULL: reset hard + minikube delete...${NC}"
  reset_hard
  if minikube status >/dev/null 2>&1; then
    echo -e "${BLUE}🗑️  Ejecutando minikube delete...${NC}"
    minikube delete
    echo -e "${GREEN}✅ minikube delete completado.${NC}"
  else
    echo -e "${ORANGE}ℹ️  Minikube no está corriendo. Saltando minikube delete.${NC}"
  fi
}

run_orphan_checks() {
  echo -e "${BLUE}🧪 Verificando basura huérfana en altrupets-dev...${NC}"

  local all_output
  local cm_secret_output
  local ns_output

  all_output="$(kubectl get all -n altrupets-dev 2>&1 || true)"
  cm_secret_output="$(kubectl get cm,secret -n altrupets-dev 2>&1 || true)"
  ns_output="$(kubectl get ns altrupets-dev 2>&1 || true)"

  echo -e "${BLUE}   > kubectl get all -n altrupets-dev${NC}"
  echo "$all_output"
  echo -e "${BLUE}   > kubectl get cm,secret -n altrupets-dev${NC}"
  echo "$cm_secret_output"
  echo -e "${BLUE}   > kubectl get ns altrupets-dev${NC}"
  echo "$ns_output"

  if echo "$all_output" | grep -q "No resources found" && \
     echo "$cm_secret_output" | grep -q "No resources found" && \
     echo "$ns_output" | grep -qE "NotFound|not found"; then
    echo -e "${GREEN}✅ Sin basura huérfana detectable en altrupets-dev.${NC}"
  else
    echo -e "${ORANGE}⚠️  Se detectaron restos o estado no esperado. Revisa la salida anterior.${NC}"
  fi
}

run_bootstrap() {
  if [ "$SKIP_BOOTSTRAP" = true ]; then
    echo -e "${ORANGE}⏭️  --skip-bootstrap activo. Reset finalizado sin reprovisionar.${NC}"
    return 0
  fi

  if [ -z "$REPO_URL" ]; then
    REPO_URL="$(read_env_var "$ENV_FILE" "REPO_URL")"
  fi

  if [ -z "$REPO_URL" ]; then
    echo -e "${RED}❌ Falta REPO_URL para bootstrap de ArgoCD.${NC}"
    echo -e "${ORANGE}Usa --repo-url, exporta REPO_URL, o agrega REPO_URL en ${ENV_FILE}.${NC}"
    exit 1
  fi

  log_step 3 4 "Reprovisionando PostgreSQL (OpenTofu/Terraform)"
  "$PROJECT_ROOT/infrastructure/scripts/deploy-postgres-dev.sh"

  log_step 4 4 "Reinstalando ArgoCD y aplicación backend"
  REPO_URL="$REPO_URL" TARGET_REVISION="$TARGET_REVISION" \
    "$PROJECT_ROOT/infrastructure/scripts/setup-argocd-dev.sh"

  echo -e "${BLUE}🐳 Construyendo imagen backend en Minikube...${NC}"
  "$PROJECT_ROOT/infrastructure/scripts/build-backend-image-minikube.sh"

  echo -e "${GREEN}✅ Reset + bootstrap completados.${NC}"
}

main() {
  parse_args "$@"

  case "$MODE" in
    soft|hard|full) ;;
    *)
      echo -e "${RED}❌ Mode inválido: ${MODE}. Usa soft|hard|full.${NC}"
      exit 1
      ;;
  esac
  if [[ "$MODE" == "hard" || "$MODE" == "full" ]] && [ "$SKIP_BOOTSTRAP" = true ]; then
    echo -e "${RED}❌ ${MODE} requiere bootstrap. Quita --skip-bootstrap o usa mode=soft.${NC}"
    exit 1
  fi

  require_cmd kubectl
  require_cmd minikube

  init_logging
  confirm_destructive_action

  echo -e "${BLUE}🧭 Iniciando reset dev cluster (mode=${MODE})...${NC}"
  log_step 1 4 "Aplicando reset (${MODE})"
  case "$MODE" in
    soft)
      reset_soft
      ;;
    hard)
      reset_hard
      ;;
    full)
      reset_full
      ;;
  esac

  run_orphan_checks
  log_step 2 4 "Reset completado, iniciando bootstrap"
  run_bootstrap
}

main "$@"
