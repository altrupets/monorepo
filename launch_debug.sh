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

# ─── Helpers ──────────────────────────────────────────────────────────────────

_get_id_from_line() {
    awk -F' • ' '{print $2}' | tr -d ' \t'
}

get_android_emulator_id() {
    flutter devices 2>/dev/null | grep -E 'emulator|Emulator' | head -1 | _get_id_from_line
}

get_android_device_id() {
    flutter devices 2>/dev/null | grep -i android | grep -v -i emulator | head -1 | _get_id_from_line
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
    cd "$MOBILE_DIR"
    echo "🧹 flutter pub get..."
    flutter pub get
    echo -e "${GREEN}🚀 Ejecutando en $DESKTOP_LABEL...${NC}"
    flutter run -d "$DESKTOP_TARGET"
elif [ "$TARGET" = "android" ]; then
    echo -e "${BLUE}📱 AltruPets – Android Debug ($DEVICE_ID)${NC}"
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