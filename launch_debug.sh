#!/bin/bash

# ==============================================================================
# AltruPets - Debug Launch Script (Multi-Device Support)
# ==============================================================================

# Navegar a la carpeta de la app
cd apps/mobile || exit 1

# Colores para el output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Definición de IDs de dispositivos
EMULATOR_ID="emulator-5554"
# ID del Xiaomi detectado: 863d005830483132385106b616f8bb
PHYSICAL_DEVICE_ID="863d005830483132385106b616f8bb"

# Función de ayuda
show_help() {
    echo "Uso: ./launch_debug.sh [OPCIÓN]"
    echo ""
    echo "Opciones:"
    echo "  -e, --emulator    Lanzar en el emulador de Android"
    echo "  -d, --device      Lanzar en el teléfono Xiaomi físico"
    echo "  -h, --help        Mostrar esta ayuda"
    echo ""
    echo "Si no se pasa ninguna opción, el script mostrará un menú interactivo."
}

# Parsear argumentos
TARGET_MODE=""
if [[ "$1" == "-e" || "$1" == "--emulator" ]]; then
    TARGET_MODE="EMULATOR"
elif [[ "$1" == "-d" || "$1" == "--device" ]]; then
    TARGET_MODE="DEVICE"
elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Selección interactiva si no hay argumentos
if [ -z "$TARGET_MODE" ]; then
    echo -e "${BLUE}📱 Selecciona el destino de compilación:${NC}"
    echo "1) Emulador (Android Studio)"
    echo "2) Teléfono Xiaomi (Hardware)"
    read -p "Opción [1-2]: " choice
    case $choice in
        1) TARGET_MODE="EMULATOR" ;;
        2) TARGET_MODE="DEVICE" ;;
        *) echo -e "${RED}❌ Opción inválida.${NC}"; exit 1 ;;
    esac
fi

# Configurar el DEVICE_ID según la selección
if [ "$TARGET_MODE" == "EMULATOR" ]; then
    DEVICE_ID="$EMULATOR_ID"
    # Verificar si el emulador está corriendo
    if ! flutter devices | grep -q "$EMULATOR_ID"; then
        echo -e "${ORANGE}⚠️  El emulador no está activo. Intentando lanzarlo...${NC}"
        flutter emulators --launch Medium_Phone_API_36.1
        echo "⏳ Esperando a que el emulador se inicie (10s)..."
        sleep 10
    fi
else
    DEVICE_ID="$PHYSICAL_DEVICE_ID"
    # Verificar permisos ( troubleshooting tips )
    if flutter devices | grep "$DEVICE_ID" | grep -q "unsupported"; then
        echo -e "${RED}❌ ERROR DE PERMISOS ADB:${NC}"
        echo "Asegúrate de haber aceptado el diálogo 'Permitir depuración USB' en tu Xiaomi."
        echo "Si ya lo hiciste y sigue fallando, intenta reconectar el cable."
        echo -e "${ORANGE}💡 Nota:${NC} Estás en el grupo 'plugdev', reinicia tu sesión de terminal si acabas de ser añadido."
        exit 1
    fi
fi

echo -e "${GREEN}🚀 Destino seleccionado: $DEVICE_ID ($TARGET_MODE)${NC}"

echo "🧹 Limpiando caché de construcción..."
flutter clean
flutter pub get

echo "🏗️  Iniciando compilación debug para $TARGET_MODE..."
flutter build apk --debug

echo "📲 Ejecutando aplicación..."
flutter run -d "$DEVICE_ID"