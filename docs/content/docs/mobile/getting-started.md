# 🚀 Getting Started

Guía completa para configurar y ejecutar AltruPets Mobile en tu entorno de desarrollo.

## Prerrequisitos

### Software Requerido

| Software | Versión Mínima | Propósito |
|----------|----------------|----------|
| Flutter SDK | 3.10.4+ | Framework |
| Dart SDK | 3.0+ | Incluido con Flutter |
| Android Studio | 2023.1+ | IDE y Android SDK |
| Xcode | 14.0+ | Solo macOS, para iOS |
| VS Code | Latest | IDE alternativo |

### Verificar Instalación

```bash
# Verificar que Flutter está correctamente instalado
flutter doctor -v

# Output esperado:
# [✓] Flutter (Channel stable, 3.10.x)
# [✓] Android toolchain
# [✓] Xcode (solo macOS)
# [✓] Chrome
# [✓] Android Studio
```

### Extensiones Recomendadas (VS Code)

- **Flutter** - Dart-Code.flutter
- **Dart** - Dart-Code.dart-code
- **Riverpod Snippets** - robert-brunhage.flutter-riverpod-snippets
- **Error Lens** - usernamehw.errorlens

## Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/altrupets/monorepo.git
cd monorepo/apps/mobile
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Generar Código

El proyecto usa Freezed y JSON Serializable para generar código:

```bash
# Generar una vez
flutter pub run build_runner build --delete-conflicting-outputs

# O en modo watch (regenera automáticamente al guardar)
flutter pub run build_runner watch --delete-conflicting-outputs
```

!!! warning "Archivos Generados"
    Los archivos `*.freezed.dart` y `*.g.dart` son generados automáticamente.
    **No los edites manualmente** - tus cambios se perderán.

### 4. Generar Localizaciones

```bash
flutter gen-l10n
```

Esto genera `lib/l10n/app_localizations.dart` desde los archivos `.arb`.

## Flujo de Desarrollo Completo (DEV)

AltruPets usa un flujo de desarrollo basado en Kubernetes local (Minikube) con ArgoCD para GitOps. El `Makefile` en la raíz del monorepo automatiza todo el proceso.

### Setup Inicial (Primera Vez)

```bash
# 1. Setup del entorno
make setup

# 2. Crear cluster Minikube
make dev-minikube-deploy

# 3. Desplegar Gateway API (instala CRDs)
make dev-gateway-deploy

# 4. Construir imagen del backend
make dev-backend-build

# 5. Desplegar ArgoCD + todas las apps
make dev-argocd-deploy

# 6. Iniciar port-forward del Gateway
make dev-gateway-start
```

### Comandos Útiles del Makefile

**Minikube:**
```bash
make dev-minikube-deploy          # Crear cluster
make dev-minikube-clear           # Limpiar namespaces estancados
make dev-minikube-destroy         # Eliminar cluster
```

**Backend:**
```bash
make dev-backend-build            # Rebuild imagen + rollout restart
make dev-backend-start            # Iniciar backend en modo dev
```

**Gateway:**
```bash
make dev-gateway-start            # Port-forward a localhost:3001
make dev-gateway-stop             # Detener port-forward
```

**ArgoCD:**
```bash
make dev-argocd-deploy            # Instalar ArgoCD + apps
make dev-argocd-status            # Ver estado de aplicaciones
make dev-argocd-password          # Obtener password de admin
make dev-argocd-destroy           # Eliminar ArgoCD
```

**PostgreSQL:**
```bash
make dev-postgres-deploy          # Desplegar PostgreSQL
make dev-postgres-logs            # Ver logs
make dev-postgres-port-forward    # Port-forward a localhost:5432
```

**Aplicaciones Web:**
```bash
make dev-superusers-start         # CRUD Superusers local
make dev-superusers-deploy        # Deploy a Kubernetes
make dev-b2g-start                # B2G local
make dev-b2g-deploy               # Deploy a Kubernetes
```

**Utilidades:**
```bash
make dev-superuser-seed           # Crear usuario SUPER_USER
make help                         # Ver todos los comandos
```

### Flujo de Trabajo Típico

```bash
# 1. Iniciar el día
make dev-minikube-deploy          # Si no está corriendo
make dev-gateway-start            # Port-forward del backend

# 2. Desarrollar en mobile
cd apps/mobile
make dev-mobile-launch-desktop              # Desktop para pruebas rápidas
# o
make dev-mobile-launch-emulator              # Emulador Android

# 3. Si cambias el backend
make dev-backend-build            # Rebuild + redeploy automático

# 4. Ver logs del backend
kubectl -n altrupets-dev logs -f deploy/backend --tail=100

# 5. Al terminar (opcional)
make dev-gateway-stop             # Detener port-forward
```

### Endpoints Disponibles

Cuando el Gateway está activo (`make dev-gateway-start`):

| Endpoint | Descripción |
|----------|-------------|
| `http://localhost:3001/graphql` | API GraphQL del backend |
| `http://localhost:3001/admin/login` | CRUD Superusers |
| `http://localhost:3001/b2g/login` | B2G (Business to Good) |

### Troubleshooting del Entorno

**Backend no está Ready:**
```bash
# Ver estado
kubectl -n altrupets-dev get pods

# Ver logs
kubectl -n altrupets-dev logs -f deploy/backend

# Rebuild forzado
make dev-backend-build

# Limpiar pods estancados
make dev-minikube-clear
```

**Port-forward no funciona:**
```bash
# Detener todos los port-forwards
make dev-gateway-stop

# Reiniciar
make dev-gateway-start
```

**Minikube lento o sin recursos:**
```bash
# Recrear con más recursos (edita Makefile o script)
make dev-minikube-destroy
# Edita: minikube start --cpus=8 --memory=16384
make dev-minikube-deploy
```

## Configuración del Backend

### URL del Backend

Edita `lib/core/utils/constants.dart`:

```dart
class AppConstants {
  // Desarrollo local
  static const String baseUrl = 'http://localhost:4000';
  
  // Para emulador Android (localhost no funciona)
  // static const String baseUrl = 'http://10.0.2.2:4000';
  
  // Para dispositivo físico Android (usa tu IP local)
  // static const String baseUrl = 'http://192.168.1.100:4000';
  
  // Staging
  // static const String baseUrl = 'https://api-staging.altrupets.com';
  
  // Producción
  // static const String baseUrl = 'https://api.altrupets.com';
}
```

### Variables de Entorno (Opcional)

Para múltiples ambientes, considera usar `flutter_dotenv`:

```bash
# .env.development
API_URL=http://localhost:4000

# .env.staging
API_URL=https://api-staging.altrupets.com

# .env.production
API_URL=https://api.altrupets.com
```

## Ejecutar la Aplicación

### Script de Lanzamiento Automatizado

AltruPets incluye comandos `make dev-mobile-*` que automatizan el flujo completo de desarrollo:

```bash
# Desde la raíz del monorepo
make dev-mobile-launch  # Menú interactivo
```

#### Opciones Disponibles

**Desktop (Pruebas Rápidas):**
```bash
make dev-mobile-launch-desktop, --linux       # Linux desktop
```

**Android:**
```bash
make dev-mobile-launch-desktop          # Linux desktop
make dev-mobile-launch-emulator         # Emulador Android
make dev-mobile-launch-device           # Dispositivo físico Android
```

**Widgetbook (Catálogo de Widgets):**
```bash
make dev-mobile-widgetbook  # Abre Widgetbook en Linux desktop
```

**Opciones Globales:**
```bash
--dirty                          # Saltar 'flutter clean' (útil en Android)
--no-backend-check               # No verificar backend en Kubernetes
--no-backend-auto-build          # No build automático si hay ImagePullBackOff
--backend-retries N              # Intentos de recuperación backend (default: 5)
--backend-redeploy-argo          # Flujo GitOps: build + refresh/sync ArgoCD
--backend-rollout-restart        # Flujo imperativo: rollout restart
--no-backend-prune               # No eliminar pods backend en CrashLoopBackOff
--no-backend-logs-window         # No abrir ventana con logs del backend
--no-adb-reverse                 # No configurar adb reverse en --device
```

#### Menú Interactivo

Si ejecutas el script sin argumentos, se muestra un menú interactivo:

```bash
make dev-mobile-launch

# 📱 AltruPets — Selecciona destino:
#   1) 🖥️  Linux desktop (prueba rápida)
#   2) 📱 Emulador Android
#   3) 📲 Dispositivo Android físico
#   4) 📖 Widgetbook (catálogo de widgets)
# Opción [1-4]:
```

#### Características del Script

El script `apps/mobile/launch_flutter_debug.sh` (invocado por `make dev-mobile-*`) realiza automáticamente:

1. **Verificación de Backend**: Comprueba que el backend en Kubernetes esté Ready
2. **Recuperación Automática**: Intenta resolver problemas comunes (ImagePullBackOff, pods estancados)
3. **Port-Forward Automático**: Configura túneles para acceder al backend desde la app
4. **adb reverse** (Android): Configura túnel `localhost:3001` en dispositivos físicos
5. **Logs Centralizados**: Guarda logs en `logs/mobile/<device>/launch-<timestamp>.log`
6. **Ventana de Logs Backend**: Abre terminal separada con logs del backend (Linux)

#### Ejemplos de Uso

```bash
# Desarrollo rápido en desktop
make dev-mobile-launch-desktop

# Android con build limpio
make dev-mobile-launch-emulator

# Android sin limpiar caché (más rápido)
make dev-mobile-launch-device  # Usa --dirty por defecto

# Con recuperación automática del backend
make dev-mobile-launch-emulator --backend-retries 10

# Sin verificar backend (desarrollo offline)
make dev-mobile-launch-desktop --no-backend-check
```

### Listar Dispositivos Disponibles

```bash
flutter devices

# Output ejemplo:
# 3 connected devices:
# Pixel 6 (mobile)      • emulator-5554      • android-arm64
# macOS (desktop)       • macos              • darwin-x64
# Chrome (web)          • chrome             • web-javascript
```

### Ejecutar Manualmente (Sin Script)

```bash
# Dispositivo por defecto
flutter run

# Dispositivo específico
flutter run -d emulator-5554
flutter run -d chrome

# Con verbose logging
flutter run -v
```

### Ejecutar en Modo Release

```bash
# Android
flutter run --release

# iOS (requiere perfil de provisión)
flutter run --release -d <ios-device-id>
```

### Hot Reload vs Hot Restart

| Acción | Atajo | Uso |
|--------|-------|-----|
| Hot Reload | `r` | Cambios en UI, preserva estado |
| Hot Restart | `R` | Reinicia app, pierde estado |
| Quit | `q` | Salir de flutter run |

## Build para Producción

### Android

```bash
# APK (para distribución directa)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# App Bundle (para Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# Con ofuscación (recomendado para producción)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

### iOS

```bash
# Build para archivo (requiere Xcode)
flutter build ios --release

# Luego en Xcode:
# Product > Archive > Distribute App
```

### Firmar Builds

#### Android

Crea `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>/upload-keystore.jks
```

#### iOS

Configura en Xcode:
1. Signing & Capabilities
2. Selecciona tu Team
3. Configura Bundle Identifier

## Testing

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Test específico
flutter test test/features/auth/auth_provider_test.dart

# Con coverage
flutter test --coverage

# Ver reporte de coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Estructura de Tests

```
test/
├── features/
│   ├── auth/
│   │   ├── auth_provider_test.dart
│   │   └── auth_repository_test.dart
│   └── profile/
│       └── profile_provider_test.dart
├── core/
│   ├── graphql_client_test.dart
│   └── failures_test.dart
└── widget_test.dart
```

## Comandos Útiles

### Limpieza y Mantenimiento

```bash
# Limpiar caché y builds
flutter clean

# Regenerar pubspec.lock
rm pubspec.lock && flutter pub get

# Actualizar dependencias
flutter pub upgrade

# Ver dependencias desactualizadas
flutter pub outdated
```

### Análisis de Código

```bash
# Usar script SAST (recomendado)
./flutter-sast.sh analyze    # dart analyze
./flutter-sast.sh test       # unit tests
./flutter-sast.sh coverage   # tests con coverage
./flutter-sast.sh lint       # all linting
./flutter-sast.sh all        # full analysis

# O comandos directos
flutter analyze
dart format lib/
dart fix --apply
```

### Debugging

```bash
# Ver logs del dispositivo
flutter logs

# Capturar screenshot
flutter screenshot

# Abrir DevTools
flutter pub global activate devtools
devtools
```

## Troubleshooting

### Problemas con los Comandos make dev-mobile-*

#### Error: "Backend no disponible. Abortando launch"

**Causa**: El backend en Kubernetes no está Ready.

**Solución**:
```bash
# Ver estado del backend
kubectl -n altrupets-dev get pods

# Ver logs
kubectl -n altrupets-dev logs -f deploy/backend --tail=50

# Rebuild del backend
make dev-backend-build

# Si persiste, usar --no-backend-check
make dev-mobile-launch-desktop --no-backend-check
```

#### Error: "No se detectó dispositivo o emulador Android"

**Causa**: No hay dispositivos Android conectados o emuladores activos.

**Solución**:
```bash
# Listar emuladores disponibles
flutter emulators

# Lanzar emulador
flutter emulators --launch <emulator-id>

# Verificar dispositivos
flutter devices
adb devices
```

#### Error: "adb reverse failed"

**Causa**: Dispositivo Android no autorizado o sin depuración USB.

**Solución**:
1. Habilita "Depuración USB" en el dispositivo
2. Acepta el diálogo de autorización
3. Verifica con `adb devices`
4. O usa `--no-adb-reverse` y configura IP manualmente

#### Backend en CrashLoopBackOff

**Causa**: Error en la imagen del backend o secretos desincronizados.

**Solución**:
```bash
# El script intenta recuperación automática, pero puedes forzar:
make dev-backend-build

# O con el script:
make dev-mobile-launch-desktop --backend-rollout-restart

# Limpiar pods estancados
make dev-minikube-clear
```

#### Logs no se guardan

**Causa**: Permisos o directorio `logs/mobile/` no existe.

**Solución**:
```bash
# Crear directorio manualmente
mkdir -p logs/mobile/android-device
mkdir -p logs/mobile/android-emulator
mkdir -p logs/mobile/linux

# Verificar permisos
chmod -R 755 logs/
```

### Error: "SocketException: Connection refused"

**Causa**: El backend no está corriendo o la URL es incorrecta.

**Solución**:
1. Verifica que el backend esté corriendo:
   ```bash
   kubectl -n altrupets-dev get pods
   make dev-gateway-start
   ```
2. Si usas emulador Android, cambia a `10.0.2.2:3001`
3. Si usas dispositivo físico:
   - Verifica `adb reverse`: `adb reverse --list`
   - O usa la IP de tu máquina: `192.168.x.x:3001`

### Error: "Could not find generator 'freezed'"

**Causa**: build_runner no está instalado o caché corrupto.

**Solución**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error: "Gradle build failed"

**Solución**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error: "CocoaPods not installed" (macOS)

**Solución**:
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### Hot Reload no funciona

**Causa**: Cambios en código nativo o archivos de configuración.

**Solución**: Usa Hot Restart (`R`) o reinicia completamente con `flutter run`.

### Port-forward se desconecta constantemente

**Causa**: Minikube inestable o recursos insuficientes.

**Solución**:
```bash
# Reiniciar port-forward
make dev-gateway-stop
make dev-gateway-start

# O aumentar recursos de Minikube (edita Makefile)
make dev-minikube-destroy
# Edita: --cpus=8 --memory=16384
make dev-minikube-deploy
```

### Widgetbook no abre en Chrome

**Causa**: Chrome no está disponible como dispositivo Flutter.

**Solución**:
```bash
# Verificar dispositivos
flutter devices

# Si Linux desktop no aparece, verifica que esté habilitado
flutter config --enable-linux-desktop
make dev-mobile-widgetbook

# O ejecuta manualmente
cd apps/widgetbook
flutter run -d linux  # o macos/windows
```



## Logs y Debugging Avanzado

### Logs Centralizados (make dev-mobile-*)

Los comandos `make dev-mobile-*` guardan automáticamente todos los logs en:

```
logs/mobile/
├── android-device/
│   └── launch-20250218-143022.log
├── android-emulator/
│   └── launch-20250218-140512.log
└── linux/
    └── launch-20250218-135401.log
```

**Ver logs en tiempo real:**
```bash
# Último log de Android device
tail -f logs/mobile/android-device/launch-*.log

# Buscar errores
grep -i error logs/mobile/*/launch-*.log
```

### Ventana de Logs del Backend (Linux)

En Linux, el script abre automáticamente una terminal separada con los logs del backend:

```bash
# Si no se abre automáticamente, ejecuta manualmente:
kubectl -n altrupets-dev logs -f deploy/backend --tail=200

# O desactiva la ventana:
make dev-mobile-launch-desktop --no-backend-logs-window
```

### Flutter DevTools

```bash
# Activar DevTools globalmente
flutter pub global activate devtools

# Ejecutar
devtools

# O desde flutter run:
# Presiona 'v' para abrir DevTools en el navegador
```

### Debugging con VS Code

Crea `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Debug)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--dart-define=ENV=dev"]
    },
    {
      "name": "Flutter (Profile)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "flutterMode": "profile"
    }
  ]
}
```

### Análisis de Performance

```bash
# Ejecutar en modo profile
flutter run --profile

# Capturar timeline
flutter screenshot --type=skia --observatory-url=<url>

# Ver en DevTools
devtools --appSizeBase=<path-to-app-size-json>
```

## Recursos Adicionales

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [GraphQL Flutter](https://github.com/zino-hofmann/graphql-flutter)
- [AltruPets Backend API](../backend/api.md)
- [Design System](design-system.md)
- [Architecture Guide](architecture.md)
