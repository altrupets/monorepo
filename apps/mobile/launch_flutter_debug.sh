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

WIDGETBOOK_DIR="../widgetbook"
LOG_BASE_DIR="$SCRIPT_DIR/logs/mobile"
ADB_REVERSE_ENABLED=true
LOG_LEVEL="debug"

# ─── Helpers ──────────────────────────────────────────────────────────────────

check_and_generate_icons() {
	# Verifica si los iconos necesitan regenerarse
	local icon_source="assets/icon.png"
	local android_icon="android/app/src/main/res/mipmap-hdpi/ic_launcher.png"

	if [ ! -f "$icon_source" ]; then
		echo -e "${ORANGE}⚠️  icon.png no encontrado en assets/${NC}"
		return 0
	fi

	# Si no existen los iconos o el source es más nuevo, regenerar
	if [ ! -f "$android_icon" ] || [ "$icon_source" -nt "$android_icon" ]; then
		echo -e "${BLUE}🎨 Generando iconos de la app desde icon.png...${NC}"
		if dart run flutter_launcher_icons 2>&1 | grep -q "Successfully generated"; then
			echo -e "${GREEN}✅ Iconos generados correctamente${NC}"
		else
			echo -e "${ORANGE}⚠️  No se pudieron generar los iconos${NC}"
		fi
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

	echo -e "${BLUE}🔁 Configurando túnel Android: localhost:3002 -> host:3002 (admin server)...${NC}"
	if adb -s "$DEVICE_ID" reverse tcp:3002 tcp:3002 >/dev/null 2>&1; then
		echo -e "${GREEN}✅ adb reverse (admin) activo para ${DEVICE_ID}${NC}"
	else
		echo -e "${ORANGE}⚠️  No se pudo configurar adb reverse 3002 para ${DEVICE_ID}.${NC}"
	fi
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
	echo "  Opciones:"
	echo "    --dirty           Saltar 'flutter clean' (útil en Android)"
	echo "    --no-adb-reverse  No configurar adb reverse en modo --device"
	echo "    -h, --help        Mostrar esta ayuda"
	echo ""
	echo "  Nota: El backend se gestiona con Makefile (make dev-gateway-start)"
}

# ─── Parse args ───────────────────────────────────────────────────────────────

TARGET=""
DEVICE_ID=""
DIRTY=false
ANDROID_TARGET_LABEL=""

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
	--no-adb-reverse)
		ADB_REVERSE_ENABLED=false
		shift
		;;
	-h | --help)
		show_help
		exit 0
		;;
	*)
		if [[ "$1" == -* ]]; then
			echo -e "${RED}Opción desconocida: $1${NC}"
			show_help
			exit 1
		fi
		break
		;;
	esac
done

# Post-parsing logic
if [ -z "$TARGET" ]; then
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
	flutter run -d "$DESKTOP_TARGET" --dart-define=LOG_LEVEL=$LOG_LEVEL
elif [ "$TARGET" = "desktop" ]; then
	echo -e "${BLUE}🖥️  AltruPets – $DESKTOP_LABEL Debug${NC}"
	init_mobile_logging "${DESKTOP_TARGET}"
	echo "🧹 flutter pub get..."
	flutter pub get
	check_and_generate_icons
	echo -e "${GREEN}🚀 Ejecutando en $DESKTOP_LABEL...${NC}"
	flutter run -d "$DESKTOP_TARGET" --dart-define=LOG_LEVEL=$LOG_LEVEL
elif [ "$TARGET" = "android" ]; then
	echo -e "${BLUE}📱 AltruPets – Android Debug ($DEVICE_ID)${NC}"
	if [ -z "$ANDROID_TARGET_LABEL" ]; then
		ANDROID_TARGET_LABEL="android-device"
	fi
	init_mobile_logging "$ANDROID_TARGET_LABEL"
	setup_adb_reverse_if_needed
	if [ "$DIRTY" = false ]; then
		echo "🧹 Limpiando caché de construcción..."
		flutter clean
	else
		echo "🚀 Modo DIRTY: Saltando limpieza..."
	fi
	flutter pub get
	check_and_generate_icons
	echo -e "${GREEN}🚀 Ejecutando en Android ($DEVICE_ID)...${NC}"
	flutter run -d "$DEVICE_ID" --dart-define=LOG_LEVEL=$LOG_LEVEL
fi
