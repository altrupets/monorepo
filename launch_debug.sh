#!/bin/bash

# Navegar a la carpeta de la app
cd apps/mobile || exit 1

echo "🔍 Verificando estado de dispositivos..."

# Obtener IDs de dispositivos activos de forma robusta
# Usamos el delimitador de bala (•) y xargs para limpiar espacios
DEVICE_ID=$(flutter devices | grep -E "emulator-|android" | head -n 1 | awk -F '•' '{print $2}' | xargs)

if [ -z "$DEVICE_ID" ]; then
    echo "⚠️ No se detectó emulador activo. Lanzando emulador configurado..."
    flutter emulators --launch Medium_Phone_API_36.1
    
    echo "⏳ Esperando a que el emulador se inicie..."
    # Intento de re-obtener el ID después de un breve delay
    sleep 10
    DEVICE_ID=$(flutter devices | grep -E "emulator-|android" | head -n 1 | awk -F '•' '{print $2}' | xargs)
else
    echo "🚀 Emulador detectado: $DEVICE_ID. Omitiendo lanzamiento."
fi

echo "🧹 Limpiando caché de construcción..."
flutter clean
flutter pub get

echo "🏗️  Iniciando compilación debug..."
flutter build apk --debug

echo "📲 Ejecutando aplicación..."
if [ -n "$DEVICE_ID" ]; then
    flutter run -d "$DEVICE_ID"
else
    echo "❓ No se pudo detectar el ID del emulador automáticamente. Intentando ejecución general..."
    flutter run
fi