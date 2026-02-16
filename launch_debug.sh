#!/bin/bash

# ==============================================================================
# AltruPets - Debug Launch Script (Android + Linux Desktop)
# ==============================================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

MOBILE_DIR="apps/mobile"
WIDGETBOOK_DIR="apps/widgetbook"
BACKEND_FORWARD_ENABLED=true
BACKEND_FORWARD_PID=""
BACKEND_CHECK_ENABLED=true
BACKEND_AUTO_BUILD_ENABLED=true
BACKEND_MAX_RECOVERY_ATTEMPTS=5
ADB_REVERSE_ENABLED=true
BACKEND_REDEPLOY_ENABLED=false
BACKEND_PRUNE_STALE_PODS=true

# ─── Helpers ──────────────────────────────────────────────────────────────────

decode_secret_key() {
    local namespace="$1"
    local secret_name="$2"
    local key="$3"
    kubectl -n "$namespace" get secret "$secret_name" -o "jsonpath={.data.${key}}" 2>/dev/null | base64 -d 2>/dev/null || true
}

sync_backend_db_secret_if_mismatched() {
    if ! kubectl -n altrupets-dev get secret backend-secret >/dev/null 2>&1; then
        return 0
    fi

    if ! kubectl -n default get secret postgres-dev-secret >/dev/null 2>&1; then
        return 0
    fi

    local backend_password
    local postgres_password
    local postgres_username
    local postgres_database

    backend_password="$(decode_secret_key "altrupets-dev" "backend-secret" "DB_PASSWORD")"
    postgres_password="$(decode_secret_key "default" "postgres-dev-secret" "password")"
    postgres_username="$(decode_secret_key "default" "postgres-dev-secret" "username")"
    postgres_database="$(decode_secret_key "default" "postgres-dev-secret" "database")"

    if [ -z "$postgres_password" ]; then
        return 0
    fi

    if [ "$backend_password" = "$postgres_password" ]; then
        return 0
    fi

    # Do not override intentionally different credentials (e.g. alternate DB role).
    # Only auto-heal when backend secret is missing required values.
    if [ -n "$backend_password" ]; then
        echo -e "${ORANGE}⚠️  backend-secret y postgres-dev-secret tienen credenciales distintas. Se conserva backend-secret.${NC}"
        return 0
    fi

    echo -e "${ORANGE}⚠️  backend-secret sin DB_PASSWORD. Recuperando desde postgres-dev-secret...${NC}"

    local pg_password_b64
    local pg_username_b64
    local pg_database_b64

    pg_password_b64="$(printf '%s' "$postgres_password" | base64 | tr -d '\n')"
    pg_username_b64="$(printf '%s' "${postgres_username:-postgres}" | base64 | tr -d '\n')"
    pg_database_b64="$(printf '%s' "${postgres_database:-altrupets_user_management}" | base64 | tr -d '\n')"

    kubectl -n altrupets-dev patch secret backend-secret --type merge \
        -p "{\"data\":{\"DB_PASSWORD\":\"${pg_password_b64}\",\"DB_USERNAME\":\"${pg_username_b64}\",\"DB_NAME\":\"${pg_database_b64}\"}}" >/dev/null

    if kubectl -n altrupets-dev get deploy/backend >/dev/null 2>&1; then
        echo -e "${BLUE}🔁 Reiniciando backend para tomar el secret sincronizado...${NC}"
        kubectl -n altrupets-dev rollout restart deployment/backend >/dev/null || true
    fi
}

_get_id_from_line() {
    awk -F' • ' '{print $2}' | tr -d ' \t'
}

get_android_emulator_id() {
    flutter devices 2>/dev/null | grep -E 'emulator|Emulator' | head -1 | _get_id_from_line
}

get_android_device_id() {
    flutter devices 2>/dev/null | grep -i android | grep -v -i emulator | head -1 | _get_id_from_line
}

cleanup_backend_forward() {
    if [ -n "$BACKEND_FORWARD_PID" ] && kill -0 "$BACKEND_FORWARD_PID" 2>/dev/null; then
        echo -e "${BLUE}🧹 Cerrando port-forward del backend (PID: $BACKEND_FORWARD_PID)...${NC}"
        kill "$BACKEND_FORWARD_PID" 2>/dev/null || true
    fi
}

setup_adb_reverse_if_needed() {
    if [ "$ADB_REVERSE_ENABLED" = false ]; then
        return 0
    fi

    if ! command -v adb >/dev/null 2>&1; then
        echo -e "${ORANGE}⚠️  adb no está instalado. Saltando adb reverse.${NC}"
        return 0
    fi

    if [ -z "${DEVICE_ID:-}" ]; then
        return 0
    fi

    echo -e "${BLUE}🔁 Configurando túnel Android: localhost:3001 -> host:3001 (adb reverse)...${NC}"
    if adb -s "$DEVICE_ID" reverse tcp:3001 tcp:3001 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ adb reverse activo para ${DEVICE_ID}${NC}"
    else
        echo -e "${ORANGE}⚠️  No se pudo configurar adb reverse para ${DEVICE_ID}.${NC}"
        echo -e "${ORANGE}   Verifica conexión USB y autorización de depuración.${NC}"
    fi
}

backend_redeploy_if_requested() {
    if [ "$BACKEND_REDEPLOY_ENABLED" = false ]; then
        return 0
    fi

    if ! command -v kubectl >/dev/null 2>&1; then
        echo -e "${RED}❌ kubectl no está instalado. No se puede hacer --backend-redeploy.${NC}"
        return 1
    fi

    if ! kubectl get ns altrupets-dev >/dev/null 2>&1; then
        echo -e "${RED}❌ Namespace 'altrupets-dev' no existe. No se puede hacer --backend-redeploy.${NC}"
        return 1
    fi

    if [ ! -x "./infrastructure/scripts/build-backend-image-minikube.sh" ]; then
        echo -e "${RED}❌ Script faltante: infrastructure/scripts/build-backend-image-minikube.sh${NC}"
        return 1
    fi

    echo -e "${BLUE}♻️  --backend-redeploy: reconstruyendo imagen backend...${NC}"
    ./infrastructure/scripts/build-backend-image-minikube.sh

    echo -e "${BLUE}♻️  --backend-redeploy: reiniciando deployment/backend...${NC}"
    kubectl -n altrupets-dev rollout restart deployment/backend

    echo -e "${BLUE}♻️  --backend-redeploy: esperando rollout...${NC}"
    kubectl -n altrupets-dev rollout status deployment/backend --timeout=180s
}

prune_stale_backend_pods_if_safe() {
    if [ "$BACKEND_PRUNE_STALE_PODS" = false ]; then
        return 0
    fi

    local ready_replicas
    ready_replicas="$(kubectl -n altrupets-dev get deployment/backend -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
    ready_replicas="${ready_replicas:-0}"
    if [ "$ready_replicas" -lt 1 ]; then
        return 0
    fi

    local stale_pods
    stale_pods="$(kubectl -n altrupets-dev get pods -l app=backend --no-headers 2>/dev/null | awk '$3 ~ /CrashLoopBackOff|Error|ImagePullBackOff|ErrImagePull/ {print $1}')"

    if [ -z "$stale_pods" ]; then
        return 0
    fi

    echo -e "${ORANGE}🧹 Eliminando pods backend estancados (hay réplicas sanas):${NC}"
    while IFS= read -r pod_name; do
        [ -z "$pod_name" ] && continue
        echo -e "  ${ORANGE}- $pod_name${NC}"
        kubectl -n altrupets-dev delete pod "$pod_name" --wait=false >/dev/null || true
    done <<< "$stale_pods"
}

start_backend_forward_if_available() {
    if [ "$BACKEND_FORWARD_ENABLED" = false ]; then
        return 0
    fi

    if ! command -v kubectl >/dev/null 2>&1; then
        echo -e "${ORANGE}⚠️  kubectl no está instalado. Continuando sin port-forward.${NC}"
        return 0
    fi

    if ! kubectl get ns altrupets-dev >/dev/null 2>&1; then
        echo -e "${ORANGE}⚠️  Namespace 'altrupets-dev' no existe. Continuando sin port-forward.${NC}"
        return 0
    fi

    if ! kubectl -n altrupets-dev get svc/backend-service >/dev/null 2>&1; then
        echo -e "${ORANGE}⚠️  Service 'backend-service' no encontrado en altrupets-dev. Continuando sin port-forward.${NC}"
        return 0
    fi

    if ss -ltn 2>/dev/null | grep -qE '127\.0\.0\.1:3001|::1:3001'; then
        echo -e "${ORANGE}⚠️  El puerto localhost:3001 ya está en uso. Asumiendo backend ya expuesto.${NC}"
        return 0
    fi

    echo -e "${BLUE}🔌 Iniciando port-forward backend: localhost:3001 -> svc/backend-service:3001${NC}"
    kubectl -n altrupets-dev port-forward svc/backend-service 3001:3001 >/tmp/altrupets-backend-forward.log 2>&1 &
    BACKEND_FORWARD_PID=$!
    trap cleanup_backend_forward EXIT

    sleep 1
    if ! kill -0 "$BACKEND_FORWARD_PID" 2>/dev/null; then
        echo -e "${ORANGE}⚠️  No se pudo iniciar port-forward automático. Revisa /tmp/altrupets-backend-forward.log${NC}"
        BACKEND_FORWARD_PID=""
    fi
}

ensure_backend_ready_if_available() {
    if [ "$BACKEND_CHECK_ENABLED" = false ]; then
        return 0
    fi

    if ! command -v kubectl >/dev/null 2>&1; then
        echo -e "${ORANGE}⚠️  kubectl no está instalado. Saltando verificación de backend.${NC}"
        return 0
    fi

    if ! kubectl get ns altrupets-dev >/dev/null 2>&1; then
        echo -e "${ORANGE}⚠️  Namespace 'altrupets-dev' no existe. Saltando verificación de backend.${NC}"
        return 0
    fi

    if ! kubectl -n altrupets-dev get deploy/backend >/dev/null 2>&1; then
        echo -e "${ORANGE}⚠️  Deployment 'backend' no encontrado en altrupets-dev.${NC}"
        echo -e "${ORANGE}   Ejecuta bootstrap ArgoCD/backend antes de lanzar la app.${NC}"
        return 0
    fi

    # Prevent CrashLoop when backend and postgres secrets drift out of sync.
    sync_backend_db_secret_if_mismatched

    local attempt=1
    while [ "$attempt" -le "$BACKEND_MAX_RECOVERY_ATTEMPTS" ]; do
        echo -e "${BLUE}🔎 Verificando backend en Kubernetes (intento ${attempt}/${BACKEND_MAX_RECOVERY_ATTEMPTS})...${NC}"
        if kubectl -n altrupets-dev rollout status deployment/backend --timeout=90s; then
            return 0
        fi

        local ready_replicas
        local available_replicas
        ready_replicas="$(kubectl -n altrupets-dev get deployment/backend -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
        available_replicas="$(kubectl -n altrupets-dev get deployment/backend -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
        ready_replicas="${ready_replicas:-0}"
        available_replicas="${available_replicas:-0}"
        if [ "$ready_replicas" -ge 1 ] && [ "$available_replicas" -ge 1 ]; then
            echo -e "${ORANGE}⚠️  rollout status expiró, pero backend ya tiene ${ready_replicas} réplica(s) lista(s). Continuando...${NC}"
            prune_stale_backend_pods_if_safe
            return 0
        fi

        echo -e "${ORANGE}⚠️  El backend no está Ready. Revisando causa...${NC}"
        local pod_name
        pod_name="$(kubectl -n altrupets-dev get pod -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"

        if [ -z "$pod_name" ]; then
            echo -e "${ORANGE}⚠️  No se encontró pod del backend.${NC}"
            attempt=$((attempt + 1))
            sleep 2
            continue
        fi

        local waiting_reason
        waiting_reason="$(kubectl -n altrupets-dev get pod "$pod_name" -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}' 2>/dev/null || true)"

        if [ "$BACKEND_AUTO_BUILD_ENABLED" = true ] && [[ "$waiting_reason" == "ImagePullBackOff" || "$waiting_reason" == "ErrImagePull" ]]; then
            echo -e "${ORANGE}⚠️  Detectado ${waiting_reason}. Intentando build automático de imagen...${NC}"
            if [ -x "./infrastructure/scripts/build-backend-image-minikube.sh" ]; then
                if ./infrastructure/scripts/build-backend-image-minikube.sh; then
                    echo -e "${BLUE}🔁 Reiniciando deployment/backend...${NC}"
                    kubectl -n altrupets-dev rollout restart deployment/backend
                else
                    echo -e "${ORANGE}⚠️  Falló el build automático de imagen.${NC}"
                fi
            else
                echo -e "${ORANGE}⚠️  Script de build no encontrado: infrastructure/scripts/build-backend-image-minikube.sh${NC}"
            fi
        else
            echo -e "${ORANGE}⚠️  Reason actual del contenedor: ${waiting_reason:-unknown}${NC}"
        fi

        attempt=$((attempt + 1))
        sleep 2
    done

    echo -e "${RED}❌ El backend sigue sin estar Ready después de ${BACKEND_MAX_RECOVERY_ATTEMPTS} intentos.${NC}"
    echo -e "${ORANGE}Últimos logs:${NC}"
    kubectl -n altrupets-dev logs deploy/backend --tail=40 || true
    return 1
}

# ─── OS Detection ─────────────────────────────────────────────────────────────

OS_NAME="$(uname -s)"
DESKTOP_TARGET="linux"
DESKTOP_LABEL="Linux desktop"

case "${OS_NAME}" in
    Linux*)     DESKTOP_TARGET="linux";   DESKTOP_LABEL="Linux desktop" ;;
    Darwin*)    DESKTOP_TARGET="macos";   DESKTOP_LABEL="macOS desktop" ;;
    CYGWIN*|MINGW*|MSYS*) DESKTOP_TARGET="windows"; DESKTOP_LABEL="Windows desktop" ;;
    *)          DESKTOP_TARGET="linux";   DESKTOP_LABEL="Linux desktop" ;;
esac

# ─── Help ─────────────────────────────────────────────────────────────────────

show_help() {
    echo "Uso: ./launch_debug.sh [OPCIÓN]"
    echo ""
    echo "  Desktop:"
    echo "    -l, --linux       Lanzar en $DESKTOP_LABEL (pruebas rápidas)"
    echo ""
    echo "  Android:"
    echo "    -e, --emulator    Lanzar en emulador Android"
    echo "    -d, --device      Lanzar en dispositivo Android físico"
    echo ""
    echo "  Widgetbook:"
    echo "    -w, --widgetbook  Lanzar Widgetbook en Chrome"
    echo ""
    echo "  Opciones Globales:"
    echo "    --dirty           Saltar 'flutter clean' (útil en Android)"
    echo "    --no-backend-forward  No iniciar port-forward automático del backend en desktop"
    echo "    --no-backend-check    No verificar readiness de backend en Kubernetes"
    echo "    --no-backend-auto-build  No intentar build automático si hay ImagePullBackOff"
    echo "    --backend-retries N    Cantidad de intentos de recuperación backend (default: 5)"
    echo "    --backend-redeploy    Ejecuta build+restart+rollout del backend antes de lanzar Flutter"
    echo "    --no-backend-prune    No eliminar pods backend viejos en CrashLoopBackOff"
    echo "    --no-adb-reverse       No configurar adb reverse en modo --device"
    echo "    -h, --help        Mostrar esta ayuda"
}

# ─── Parse args ───────────────────────────────────────────────────────────────

TARGET=""
DEVICE_ID=""
DIRTY=false

# Parsear todos los argumentos
while [[ $# -gt 0 ]]; do
    case "$1" in
        -l|--linux)
            TARGET="desktop"
            shift
            ;;
        -e|--emulator)
            TARGET="android"
            DEVICE_ID=$(get_android_emulator_id)
            shift
            ;;
        -d|--device)
            TARGET="android"
            DEVICE_ID=$(get_android_device_id)
            shift
            ;;
        -w|--widgetbook)
            TARGET="widgetbook"
            shift
            ;;
        --dirty)
            DIRTY=true
            shift
            ;;
        --no-backend-forward)
            BACKEND_FORWARD_ENABLED=false
            shift
            ;;
        --no-backend-check)
            BACKEND_CHECK_ENABLED=false
            shift
            ;;
        --no-backend-auto-build)
            BACKEND_AUTO_BUILD_ENABLED=false
            shift
            ;;
        --backend-retries)
            if [[ -n "${2:-}" && "${2:-}" =~ ^[0-9]+$ ]]; then
                BACKEND_MAX_RECOVERY_ATTEMPTS="$2"
                shift 2
            else
                echo -e "${RED}Uso inválido: --backend-retries requiere un entero${NC}"
                exit 1
            fi
            ;;
        --backend-redeploy)
            BACKEND_REDEPLOY_ENABLED=true
            shift
            ;;
        --no-backend-prune)
            BACKEND_PRUNE_STALE_PODS=false
            shift
            ;;
        --no-adb-reverse)
            ADB_REVERSE_ENABLED=false
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            # Si no es una opción conocida y no hemos asignado TARGET, 
            # podría ser un parámetro erróneo o el inicio del menú interactivo.
            if [[ "$1" == -* ]]; then
                echo -e "${RED}Opción desconocida: $1${NC}"
                show_help
                exit 1
            fi
            break # Salir del loop si es texto plano (para el menú interactivo)
            ;;
    esac
done

# Post-parsing logic
if [ -z "$TARGET" ]; then
    # Menú interactivo
    echo -e "${BLUE}📱 AltruPets — Selecciona destino:${NC}"
    echo "  1) 🖥️  $DESKTOP_LABEL (prueba rápida)"
    echo "  2) 📱 Emulador Android"
    echo "  3) 📲 Dispositivo Android físico"
    echo "  4) 📖 Widgetbook (catálogo de widgets)"
    read -rp "Opción [1-4]: " choice
    case $choice in
        1) TARGET="desktop" ;;
        2)
            TARGET="android"
            DEVICE_ID=$(get_android_emulator_id)
            if [ -z "$DEVICE_ID" ]; then
                echo -e "${ORANGE}⚠️  Emulador no activo. Intentando lanzar...${NC}"
                flutter emulators --launch "$(flutter emulators 2>/dev/null | grep 'id:' | head -1 | sed 's/.*id: \([^ ]*\).*/\1/')" 2>/dev/null || true
                sleep 5
                DEVICE_ID=$(get_android_emulator_id)
            fi
            ;;
        3)
            TARGET="android"
            DEVICE_ID=$(get_android_device_id)
            ;;
        4) TARGET="widgetbook" ;;
        *) echo -e "${RED}❌ Opción inválida.${NC}"; exit 1 ;;
    esac
fi

# Validación final por plataforma
if [ "$TARGET" = "android" ] && [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}❌ No se detectó dispositivo o emulador Android.${NC}"
    echo "Conecta tu dispositivo USB o inicia un emulador."
    flutter devices
    exit 1
fi

# ─── Execute ──────────────────────────────────────────────────────────────────

if [ "$TARGET" = "widgetbook" ]; then
    echo -e "${BLUE}📖 AltruPets Widgetbook${NC}"
    cd "$WIDGETBOOK_DIR"
    echo "🧹 flutter pub get..."
    flutter pub get
    echo "⚙️  Generando directorios (build_runner)..."
    dart run build_runner build -d
    # Intentar Chrome, si no está disponible usar escritorio nativo
    if flutter devices 2>/dev/null | grep -qi chrome; then
        echo -e "${GREEN}🚀 Abriendo Widgetbook en Chrome...${NC}"
        flutter run -d chrome
    else
        echo -e "${ORANGE}⚠️  Chrome no disponible como dispositivo Flutter.${NC}"
        echo -e "${GREEN}🚀 Abriendo Widgetbook en $DESKTOP_LABEL...${NC}"
        flutter run -d "$DESKTOP_TARGET"
    fi
elif [ "$TARGET" = "desktop" ]; then
    echo -e "${BLUE}🖥️  AltruPets – $DESKTOP_LABEL Debug${NC}"
    if ! backend_redeploy_if_requested; then
        exit 1
    fi
    if ! ensure_backend_ready_if_available; then
        echo -e "${RED}❌ Backend no disponible. Abortando launch de Flutter para evitar sesión rota.${NC}"
        exit 1
    fi
    start_backend_forward_if_available
    cd "$MOBILE_DIR"
    echo "🧹 flutter pub get..."
    flutter pub get
    echo -e "${GREEN}🚀 Ejecutando en $DESKTOP_LABEL...${NC}"
    flutter run -d "$DESKTOP_TARGET"
elif [ "$TARGET" = "android" ]; then
    echo -e "${BLUE}📱 AltruPets – Android Debug ($DEVICE_ID)${NC}"
    if ! backend_redeploy_if_requested; then
        exit 1
    fi
    if ! ensure_backend_ready_if_available; then
        echo -e "${RED}❌ Backend no disponible. Abortando launch de Flutter para evitar sesión rota.${NC}"
        exit 1
    fi
    start_backend_forward_if_available
    setup_adb_reverse_if_needed
    cd "$MOBILE_DIR"
    if [ "$DIRTY" = false ]; then
        echo "🧹 Limpiando caché de construcción..."
        flutter clean
    else
        echo "🚀 Modo DIRTY: Saltando limpieza..."
    fi
    flutter pub get
    echo -e "${GREEN}🚀 Ejecutando en Android ($DEVICE_ID)...${NC}"
    flutter run -d "$DEVICE_ID"
fi
