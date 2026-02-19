# 🚀 Script de Lanzamiento (launch_debug.sh)

Guía completa del script automatizado para ejecutar AltruPets Mobile con verificación de backend y configuración automática.

## Descripción General

`launch_debug.sh` es un script Bash que automatiza el flujo completo de desarrollo de la aplicación móvil, incluyendo:

- ✅ Verificación automática del backend en Kubernetes
- 🔄 Recuperación automática de errores comunes
- 🌐 Configuración de port-forwarding y túneles
- 📝 Logs centralizados por dispositivo
- 🪟 Ventana separada con logs del backend (Linux)

## Ubicación

```bash
# Desde la raíz del monorepo
./launch_debug.sh [OPCIONES]
```

## Sintaxis

```bash
./launch_debug.sh [PLATAFORMA] [OPCIONES_GLOBALES]
```

## Plataformas Soportadas

### Desktop (Pruebas Rápidas)

```bash
./launch_debug.sh -l
./launch_debug.sh --linux
```

Lanza la app en el escritorio nativo (Linux/macOS/Windows). Ideal para:
- Pruebas rápidas de UI
- Desarrollo de lógica de negocio
- Debugging sin emulador

### Android Emulator

```bash
./launch_debug.sh -e
./launch_debug.sh --emulator
```

Lanza en el emulador Android activo. Si no hay ninguno activo, intenta lanzar el primero disponible.

**Características:**
- Detección automática del emulador
- Lanzamiento automático si no está activo
- Configuración de túnel para backend

### Android Device (Físico)

```bash
./launch_debug.sh -d
./launch_debug.sh --device
```

Lanza en un dispositivo Android físico conectado por USB.

**Características:**
- Detección automática del dispositivo
- Configuración de `adb reverse` para túnel localhost
- Verificación de autorización USB

### Widgetbook (Catálogo de Widgets)

```bash
./launch_debug.sh -w
./launch_debug.sh --widgetbook
```

Abre el catálogo de widgets en Chrome (o desktop si Chrome no está disponible).

**Características:**
- Generación automática con `build_runner`
- Ideal para desarrollo de Design System
- No requiere backend activo

## Opciones Globales

### --dirty

Salta el paso de `flutter clean` en Android.

```bash
./launch_debug.sh -e --dirty
```

**Cuándo usar:**
- Builds incrementales rápidos
- Cuando no hay cambios en dependencias nativas
- Para ahorrar tiempo en iteraciones rápidas

**Cuándo NO usar:**
- Después de cambiar dependencias en `pubspec.yaml`
- Después de modificar código nativo (Android/iOS)
- Si hay errores de build extraños

### --no-backend-check

Desactiva la verificación de readiness del backend en Kubernetes.

```bash
./launch_debug.sh -l --no-backend-check
```

**Cuándo usar:**
- Desarrollo offline
- Cuando el backend no está en Kubernetes
- Para pruebas de UI sin backend

### --no-backend-auto-build

Desactiva el build automático de la imagen del backend si hay `ImagePullBackOff`.

```bash
./launch_debug.sh -e --no-backend-auto-build
```

**Cuándo usar:**
- Cuando no quieres que el script modifique el backend
- En entornos CI/CD
- Si prefieres hacer el build manualmente

### --backend-retries N

Configura el número de intentos de recuperación del backend (default: 5).

```bash
./launch_debug.sh -e --backend-retries 10
```

**Cuándo usar:**
- Backend lento en iniciar
- Recursos limitados en Minikube
- Debugging de problemas de deployment

### --backend-redeploy-argo

Flujo GitOps: build local + refresh/sync de ArgoCD (sin `rollout restart` manual).

```bash
./launch_debug.sh -e --backend-redeploy-argo
```

**Cuándo usar:**
- Cuando usas ArgoCD para gestionar deployments
- Para mantener consistencia con GitOps
- En entornos compartidos

### --backend-rollout-restart

Flujo imperativo: ejecuta `kubectl rollout restart deployment/backend`.

```bash
./launch_debug.sh -e --backend-rollout-restart
```

**Cuándo usar:**
- Desarrollo local rápido
- Cuando no usas ArgoCD
- Para forzar recreación de pods

### --no-backend-prune

Desactiva la eliminación automática de pods backend en `CrashLoopBackOff`.

```bash
./launch_debug.sh -e --no-backend-prune
```

**Cuándo usar:**
- Debugging de problemas de backend
- Cuando quieres inspeccionar pods fallidos
- En entornos de producción

### --no-backend-logs-window

Desactiva la apertura automática de una ventana con logs del backend (solo Linux).

```bash
./launch_debug.sh -l --no-backend-logs-window
```

**Cuándo usar:**
- Cuando prefieres ver logs en la terminal principal
- En sistemas sin terminal gráfica
- Para reducir ventanas abiertas

### --no-adb-reverse

Desactiva la configuración de `adb reverse` en modo `--device`.

```bash
./launch_debug.sh -d --no-adb-reverse
```

**Cuándo usar:**
- Cuando usas IP directa en lugar de localhost
- Problemas con adb reverse
- Dispositivos que no soportan reverse

## Menú Interactivo

Si ejecutas el script sin argumentos, se muestra un menú interactivo:

```bash
./launch_debug.sh

📱 AltruPets — Selecciona destino:
  1) 🖥️  Linux desktop (prueba rápida)
  2) 📱 Emulador Android
  3) 📲 Dispositivo Android físico
  4) 📖 Widgetbook (catálogo de widgets)
Opción [1-4]:
```

## Flujo de Ejecución

### 1. Detección de Plataforma

El script detecta automáticamente el sistema operativo:
- Linux → `linux`
- macOS → `macos`
- Windows → `windows`

### 2. Verificación de Backend (si está habilitada)

```bash
# El script verifica:
1. kubectl está instalado
2. Namespace 'altrupets-dev' existe
3. Deployment 'backend' existe
4. Backend está Ready (readyReplicas >= 1)
```

**Recuperación automática:**
- Sincroniza secretos de DB si están desincronizados
- Elimina pods en `CrashLoopBackOff` si hay réplicas sanas
- Intenta build automático si hay `ImagePullBackOff`
- Limpia pods de ReplicaSets viejos que bloquean rollout

### 3. Configuración de Túneles

**Desktop:**
```bash
# Port-forward del backend (si está disponible)
kubectl port-forward -n altrupets-dev svc/backend-service 3001:3001
```

**Android Device:**
```bash
# adb reverse para túnel localhost
adb -s <device-id> reverse tcp:3001 tcp:3001
```

### 4. Logs Centralizados

Todos los logs se guardan en:
```
logs/mobile/<device-label>/launch-<timestamp>.log
```

Donde `<device-label>` es:
- `linux` / `macos` / `windows` para desktop
- `android-emulator` para emulador
- `android-device` para dispositivo físico

### 5. Ventana de Logs Backend (Linux)

En Linux, el script intenta abrir una terminal separada con:
```bash
kubectl -n altrupets-dev logs -f deploy/backend --tail=200
```

Soporta:
- `gnome-terminal`
- `x-terminal-emulator`
- `konsole`

### 6. Ejecución de Flutter

```bash
cd apps/mobile
flutter pub get
flutter run -d <device-id>
```

## Ejemplos de Uso

### Desarrollo Rápido en Desktop

```bash
./launch_debug.sh -l
```

### Android con Build Limpio

```bash
./launch_debug.sh -e
```

### Android Incremental (Rápido)

```bash
./launch_debug.sh -d --dirty
```

### Desarrollo Offline

```bash
./launch_debug.sh -l --no-backend-check
```

### Con Recuperación Agresiva del Backend

```bash
./launch_debug.sh -e --backend-retries 10 --backend-rollout-restart
```

### Debugging del Backend

```bash
./launch_debug.sh -l --no-backend-prune --backend-retries 1
```

### Widgetbook sin Backend

```bash
./launch_debug.sh -w
# Backend check se salta automáticamente para Widgetbook
```

## Variables de Entorno Internas

El script usa estas variables (no necesitas configurarlas):

| Variable | Default | Descripción |
|----------|---------|-------------|
| `BACKEND_CHECK_ENABLED` | `true` | Verificar backend |
| `BACKEND_AUTO_BUILD_ENABLED` | `true` | Build automático |
| `BACKEND_MAX_RECOVERY_ATTEMPTS` | `5` | Intentos de recuperación |
| `ADB_REVERSE_ENABLED` | `true` | Configurar adb reverse |
| `BACKEND_PRUNE_STALE_PODS` | `true` | Eliminar pods estancados |
| `BACKEND_LOGS_WINDOW_ENABLED` | `true` | Abrir ventana de logs |

## Troubleshooting

### "Backend no disponible. Abortando launch"

**Causa:** El backend no está Ready después de todos los intentos.

**Solución:**
```bash
# Ver estado
kubectl -n altrupets-dev get pods

# Ver logs
kubectl -n altrupets-dev logs -f deploy/backend

# Rebuild manual
make dev-backend-build

# O saltar verificación
./launch_debug.sh -l --no-backend-check
```

### "No se detectó dispositivo o emulador Android"

**Causa:** No hay dispositivos conectados.

**Solución:**
```bash
# Listar emuladores
flutter emulators

# Lanzar emulador
flutter emulators --launch <emulator-id>

# Verificar
flutter devices
adb devices
```

### "adb reverse failed"

**Causa:** Dispositivo no autorizado o sin depuración USB.

**Solución:**
1. Habilita "Depuración USB" en el dispositivo
2. Acepta el diálogo de autorización
3. Verifica: `adb devices`
4. O usa: `./launch_debug.sh -d --no-adb-reverse`

### "No se pudo abrir terminal adicional para logs"

**Causa:** Terminal no soportada o no disponible.

**Solución:**
```bash
# Ver logs manualmente
kubectl -n altrupets-dev logs -f deploy/backend --tail=200

# O desactiva la ventana
./launch_debug.sh -l --no-backend-logs-window
```

### Logs no se guardan

**Causa:** Directorio `logs/mobile/` no existe o sin permisos.

**Solución:**
```bash
mkdir -p logs/mobile/{android-device,android-emulator,linux}
chmod -R 755 logs/
```

## Integración con Makefile

El script se integra con los comandos del Makefile:

```bash
# Setup completo
make setup
make dev-minikube-deploy
make dev-gateway-deploy
make dev-backend-build
make dev-argocd-deploy

# Lanzar app
./launch_debug.sh -e

# Si cambias backend
make dev-backend-build
# El script detectará el cambio automáticamente
```

## Mejores Prácticas

1. **Usa `--dirty` para iteraciones rápidas** en Android (ahorra ~30s por build)
2. **Revisa los logs centralizados** si hay problemas: `logs/mobile/*/launch-*.log`
3. **Usa desktop para desarrollo de UI** (más rápido que emulador)
4. **Usa `--backend-retries 10`** si Minikube es lento
5. **Desactiva verificación de backend** si trabajas offline: `--no-backend-check`

## Próximas Mejoras

- [ ] Soporte para iOS (detección de simuladores)
- [ ] Configuración de variables de entorno por archivo `.env`
- [ ] Selección interactiva de múltiples dispositivos
- [ ] Integración con Firebase Test Lab
- [ ] Modo "watch" para rebuild automático del backend

## Ver También

- [Getting Started](getting-started.md) - Guía completa de instalación
- [Makefile Commands](../infrastructure/makefile.md) - Comandos de infraestructura
- [Backend Setup](../backend/setup.md) - Configuración del backend
- [Troubleshooting](getting-started.md#troubleshooting) - Solución de problemas comunes
