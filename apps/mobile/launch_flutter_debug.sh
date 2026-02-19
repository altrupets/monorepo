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
LOG_BASE_DIR="$SCRIPT_DIR/logs/mobile"
BACKEND_CHECK_ENABLED=true
BACKEND_AUTO_BUILD_ENABLED=true
BACKEND_MAX_RECOVERY_ATTEMPTS=5
ADB_REVERSE_ENABLED=true
BACKEND_PRUNE_STALE_PODS=true
BACKEND_LOGS_WINDOW_ENABLED=true

# ─── Helpers ──────────────────────────────────────────────────────────────────

decode_secret_key() {
	local namespace="$1"
	local secret_name="$2"
	local key="$3"
	kubectl -n "$namespace" get secret "$secret_name" -o "jsonpath={.data.${key}}" 2>/dev/null | base64 -d 2>/dev/null || true
}

sync_backend_db_secret_if_mismatched() {
	# Infisical now manages backend-secret, this function is kept for compatibility
	# but no longer syncs from postgres-dev-secret
	if ! kubectl -n altrupets-dev get secret backend-secret >/dev/null 2>&1; then
		echo -e "${ORANGE}⚠️  backend-secret not found. Secrets should be managed by Infisical.${NC}"
		return 1
	fi

	local backend_password
	backend_password="$(decode_secret_key "altrupets-dev" "backend-secret" "DB_PASSWORD")"

	if [ -z "$backend_password" ]; then
		echo -e "${ORANGE}⚠️  backend-secret missing DB_PASSWORD. Check Infisical sync.${NC}"
		return 1
	fi

	return 0
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

is_local_backend_graphql_reachable()
	if ! command -v curl >/dev/null 2>&1; then
		return 1
	fi

	local status
	status="$(curl -sS -o /dev/null -m 2 -w "%{http_code}" \
		-X POST "http://127.0.0.1:3001/graphql" \
		-H "Content-Type: application/json" \
		--data '{"query":"query { __typename }"}' 2>/dev/null || true)"

	case "$status" in
	200 | 400)
		return 0
		;;
	*)
		return 1
		;;
	esac
}

init_mobile_logging() {
	local device_label="$1"
	local ts
	ts="$(date +%Y%m%d-%H%M%S)"
	local log_dir="$LOG_BASE_DIR/$device_label"
	mkdir -p "$log_dir"
	local log_file="$log_dir/launch-${ts}.log"
	echo -e "${BLUE}🧾 Mobile log file: ${log_file}${NC}"
	exec > >(tee -a "$log_file") 2>&1
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

prune_stale_backend_pods_if_safe()
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
	done <<<"$stale_pods"
}

prune_old_backend_replicaset_pods() {
	local current_rs
	current_rs="$(kubectl -n altrupets-dev get rs -l app=backend --sort-by=.metadata.creationTimestamp -o name 2>/dev/null | tail -n 1 | cut -d/ -f2)"
	if [ -z "$current_rs" ]; then
		return 0
	fi

	local current_hash
	current_hash="${current_rs#backend-}"
	if [ -z "$current_hash" ] || [ "$current_hash" = "$current_rs" ]; then
		return 0
	fi

	local old_pods
	old_pods="$(kubectl -n altrupets-dev get pods -l app=backend --no-headers -o custom-columns=NAME:.metadata.name,HASH:.metadata.labels.pod-template-hash 2>/dev/null | awk -v h="$current_hash" '$2 != h {print $1}')"
	if [ -z "$old_pods" ]; then
		return 0
	fi

	echo -e "${ORANGE}🧹 Detectados pods de ReplicaSet viejo. Forzando limpieza para destrabar rollout:${NC}"
	while IFS= read -r pod_name; do
		[ -z "$pod_name" ] && continue
		echo -e "  ${ORANGE}- $pod_name${NC}"
		kubectl -n altrupets-dev delete pod "$pod_name" --grace-period=0 --force >/dev/null 2>&1 || true
	done <<<"$old_pods"
}

open_backend_logs_window_if_available()
	if [ "$BACKEND_LOGS_WINDOW_ENABLED" = false ]; then
		return 0
	fi

	if ! command -v kubectl >/dev/null 2>&1; then
		return 0
	fi

	if ! kubectl get ns altrupets-dev >/dev/null 2>&1; then
		return 0
	fi

	if ! kubectl -n altrupets-dev get deploy/backend >/dev/null 2>&1; then
		return 0
	fi

	local logs_cmd
	logs_cmd="echo '📜 Backend logs (altrupets-dev/deploy/backend)'; echo; kubectl -n altrupets-dev logs -f deploy/backend --tail=200"

	if [ "$OS_NAME" = "Linux" ]; then
		if command -v gnome-terminal >/dev/null 2>&1; then
			gnome-terminal -- bash -lc "$logs_cmd; echo; read -r -p 'Cerrar ventana (ENTER)...' _" >/dev/null 2>&1 &
			echo -e "${GREEN}✅ Logs de backend abiertos en nueva terminal (gnome-terminal).${NC}"
			return 0
		fi
		if command -v x-terminal-emulator >/dev/null 2>&1; then
			x-terminal-emulator -e bash -lc "$logs_cmd; echo; read -r -p 'Cerrar ventana (ENTER)...' _" >/dev/null 2>&1 &
			echo -e "${GREEN}✅ Logs de backend abiertos en nueva terminal (x-terminal-emulator).${NC}"
			return 0
		fi
		if command -v konsole >/dev/null 2>&1; then
			konsole -e bash -lc "$logs_cmd; echo; read -r -p 'Cerrar ventana (ENTER)...' _" >/dev/null 2>&1 &
			echo -e "${GREEN}✅ Logs de backend abiertos en nueva terminal (konsole).${NC}"
			return 0
		fi
	fi

	echo -e "${ORANGE}⚠️  No se pudo abrir terminal adicional para logs de backend.${NC}"
	echo -e "${ORANGE}   Ejecuta manualmente: kubectl -n altrupets-dev logs -f deploy/backend --tail=200${NC}"
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
		local rollout_output
		local rollout_code
		set +e
		rollout_output="$(kubectl -n altrupets-dev rollout status deployment/backend --timeout=90s 2>&1)"
		rollout_code=$?
		set -e
		echo "$rollout_output"

		if [ "$rollout_code" -eq 0 ]; then
			return 0
		fi

		if echo "$rollout_output" | grep -q "old replicas are pending termination"; then
			echo -e "${ORANGE}⚠️  Rollout bloqueado por réplica vieja en terminación.${NC}"
			prune_old_backend_replicaset_pods
			attempt=$((attempt + 1))
			sleep 2
			continue
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
		pod_name="$(kubectl -n altrupets-dev get pod -l app=backend --sort-by=.metadata.creationTimestamp -o name 2>/dev/null | tail -n 1 | cut -d/ -f2)"

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
Linux*)
	DESKTOP_TARGET="linux"
	DESKTOP_LABEL="Linux desktop"
	;;
Darwin*)
	DESKTOP_TARGET="macos"
	DESKTOP_LABEL="macOS desktop"
	;;
CYGWIN* | MINGW* | MSYS*)
	DESKTOP_TARGET="windows"
	DESKTOP_LABEL="Windows desktop"
	;;
*)
	DESKTOP_TARGET="linux"
	DESKTOP_LABEL="Linux desktop"
	;;
esac

# ─── Help ─────────────────────────────────────────────────────────────────────

show_help() {
	echo "Uso: ./launch_flutter_debug.sh [OPCIÓN]"
	echo ""
	echo "  Desktop:"
	echo "    -l, --linux       Lanzar en $DESKTOP_LABEL (pruebas rápidas)"
	echo ""
	echo "  Android:"
	echo "    -e, --emulator    Lanzar en emulador Android"
	echo "    -d, --device      Lanzar en dispositivo Android físico"
	echo ""
	echo "  Widgetbook:"
	echo "    -w, --widgetbook  Lanzar Widgetbook en Linux desktop"
	echo ""
	echo "  Opciones Globales:"
	echo "    --dirty           Saltar 'flutter clean' (útil en Android)"
	echo "    --no-backend-forward  No iniciar port-forward automático del backend en desktop"
	echo "    --no-backend-check    No verificar readiness de backend en Kubernetes"
	echo "    --no-backend-auto-build  No intentar build automático si hay ImagePullBackOff"
	echo "    --backend-retries N    Cantidad de intentos de recuperación backend (default: 5)"
	echo "    --backend-redeploy-argo   Flujo GitOps: build local + refresh/sync ArgoCD (sin rollout restart manual)"
	echo "    --backend-rollout-restart Flujo imperativo: rollout restart deployment/backend"
	echo "    --no-backend-prune    No eliminar pods backend viejos en CrashLoopBackOff"
	echo "    --no-backend-logs-window  No abrir ventana separada con logs del backend"
	echo "    --no-adb-reverse       No configurar adb reverse en modo --device"
	echo "    -h, --help        Mostrar esta ayuda"
}

# ─── Parse args ───────────────────────────────────────────────────────────────

TARGET=""
DEVICE_ID=""
DIRTY=false
ANDROID_TARGET_LABEL=""

# Parsear todos los argumentos
while [[ $# -gt 0 ]]; do
	case "$1" in
	-l | --linux)
		TARGET="desktop"
		shift
		;;
	-e | --emulator)
		TARGET="android"
		DEVICE_ID=$(get_android_emulator_id)
		ANDROID_TARGET_LABEL="android-emulator"
		shift
		;;
	-d | --device)
		TARGET="android"
		DEVICE_ID=$(get_android_device_id)
		ANDROID_TARGET_LABEL="android-device"
		shift
		;;
	-w | --widgetbook)
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
	--backend-redeploy-argo)
		BACKEND_REDEPLOY_ARGO_ENABLED=true
		shift
		;;
	--backend-rollout-restart)
		BACKEND_ROLLOUT_RESTART_ENABLED=true
		shift
		;;
	--no-backend-prune)
		BACKEND_PRUNE_STALE_PODS=false
		shift
		;;
	--no-backend-logs-window)
		BACKEND_LOGS_WINDOW_ENABLED=false
		shift
		;;
	--no-adb-reverse)
		ADB_REVERSE_ENABLED=false
		shift
		;;
	-h | --help)
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

if [ "$BACKEND_REDEPLOY_ARGO_ENABLED" = true ] && [ "$BACKEND_ROLLOUT_RESTART_ENABLED" = true ]; then
	echo -e "${RED}❌ Usa solo uno: --backend-redeploy-argo o --backend-rollout-restart.${NC}"
	exit 1
fi

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
		ANDROID_TARGET_LABEL="android-emulator"
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
		ANDROID_TARGET_LABEL="android-device"
		;;
	4) TARGET="widgetbook" ;;
	*)
		echo -e "${RED}❌ Opción inválida.${NC}"
		exit 1
		;;
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
	echo -e "${GREEN}🚀 Abriendo Widgetbook en $DESKTOP_LABEL...${NC}"
	flutter run -d "$DESKTOP_TARGET"
elif [ "$TARGET" = "desktop" ]; then
	echo -e "${BLUE}🖥️  AltruPets – $DESKTOP_LABEL Debug${NC}"
	init_mobile_logging "${DESKTOP_TARGET}"
	if ! backend_redeploy_argo_if_requested; then
		exit 1
	fi
	if ! backend_rollout_restart_if_requested; then
		exit 1
	fi
	if ! ensure_backend_ready_if_available; then
		echo -e "${RED}❌ Backend no disponible. Abortando launch de Flutter para evitar sesión rota.${NC}"
		exit 1
	fi
	open_backend_logs_window_if_available
	start_backend_forward_if_available
	cd "$MOBILE_DIR"
	echo "🧹 flutter pub get..."
	flutter pub get
	echo -e "${GREEN}🚀 Ejecutando en $DESKTOP_LABEL...${NC}"
	flutter run -d "$DESKTOP_TARGET"
elif [ "$TARGET" = "android" ]; then
	echo -e "${BLUE}📱 AltruPets – Android Debug ($DEVICE_ID)${NC}"
	if [ -z "$ANDROID_TARGET_LABEL" ]; then
		ANDROID_TARGET_LABEL="android-device"
	fi
	init_mobile_logging "$ANDROID_TARGET_LABEL"
	if ! backend_redeploy_argo_if_requested; then
		exit 1
	fi
	if ! backend_rollout_restart_if_requested; then
		exit 1
	fi
	if ! ensure_backend_ready_if_available; then
		echo -e "${RED}❌ Backend no disponible. Abortando launch de Flutter para evitar sesión rota.${NC}"
		exit 1
	fi
	open_backend_logs_window_if_available
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
