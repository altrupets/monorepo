# 🚀 Comandos de Lanzamiento (make dev-mobile-*)

Guía completa de los comandos automatizados para ejecutar AltruPets Mobile con verificación de backend y configuración automática.

## Descripción General

Los comandos `make dev-mobile-*` automatizan el flujo completo de desarrollo de la aplicación móvil, invocando el script `apps/mobile/launch_flutter_debug.sh` con las opciones correctas:

- ✅ Verificación automática del backend en Kubernetes
- 🔄 Recuperación automática de errores comunes
- 🌐 Configuración de port-forwarding y túneles
- 📝 Logs centralizados por dispositivo
- 🪟 Ventana separada con logs del backend (Linux)

## Ubicación

```bash
# Desde la raíz del monorepo
make dev-mobile-launch          # Menú interactivo
make dev-mobile-launch-desktop  # Linux desktop
make dev-mobile-launch-emulator # Android emulator
make dev-mobile-launch-device   # Android device
make dev-mobile-widgetbook      # Widgetbook UI catalog
```

## Sintaxis

```bash
make dev-mobile-<target>
```

## Plataformas Soportadas

### Desktop (Pruebas Rápidas)

```bash
make dev-mobile-launch-desktop
```

Lanza la app en el escritorio nativo (Linux/macOS/Windows). Ideal para:
- Pruebas rápidas de UI
- Desarrollo de lógica de negocio
- Debugging sin emulador

### Android Emulator

```bash
make dev-mobile-launch-emulator
```

Lanza en el emulador Android activo. Si no hay ninguno activo, intenta lanzar el primero disponible.

**Características:**
- Detección automática del emulador
- Lanzamiento automático si no está activo
- Configuración de túnel para backend

### Android Device (Físico)

```bash
make dev-mobile-launch-device
```

Lanza en un dispositivo Android físico conectado por USB.

**Características:**
- Detección automática del dispositivo
- Configuración de `adb reverse` para túnel localhost
- Verificación de autorización USB

### Widgetbook (Catálogo de Widgets)

```bash
make dev-mobile-widgetbook
```

Abre el catálogo de widgets en Linux desktop.

**Características:**
- Generación automática con `build_runner`
- Ideal para desarrollo de Design System
- No requiere backend activo

## Opciones Avanzadas del Script

Si necesitas opciones avanzadas, puedes invocar el script directamente desde `apps/mobile/`:

```bash
cd apps/mobile
./launch_flutter_debug.sh [OPCIONES]
```

### --dirty

Salta el paso de `flutter clean` en Android.

```bash
cd apps/mobile
./launch_flutter_debug.sh -d --dirty
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
cd apps/mobile
./launch_flutter_debug.sh --linux --no-backend-check
```

**Cuándo usar:**
- Desarrollo offline
- Cuando el backend no está en Kubernetes
- Para pruebas de UI sin backend

### --no-backend-auto-build

Desactiva el build automático de la imagen del backend si hay `ImagePullBackOff`.

```bash
cd apps/mobile
./launch_flutter_debug.sh --emulator --no-backend-auto-build
```

**Cuándo usar:**
- Cuando no quieres que el script modifique el backend
- En entornos CI/CD
- Si prefieres hacer el build manualmente

### --backend-retries N

Configura el número de intentos de recuperación del backend (default: 5).

```bash
cd apps/mobile
./launch_flutter_debug.sh --emulator --backend-retries 10
```

**Cuándo usar:**
- Backend lento en iniciar
- Recursos limitados en Minikube
- Debugging de problemas de deployment

### --backend-redeploy-argo

Flujo GitOps: build local + refresh/sync de ArgoCD (sin `rollout restart` manual).

```bash
cd apps/mobile
./launch_flutter_debug.sh --emulator --backend-redeploy-argo
```

**Cuándo usar:**
- Cuando usas ArgoCD para gestionar deployments
- Para mantener consistencia con GitOps
- En entornos compartidos

### --backend-rollout-restart

Flujo imperativo: ejecuta `kubectl rollout restart deployment/backend`.

```bash
cd apps/mobile
./launch_flutter_debug.sh --emulator --backend-rollout-restart
```

**Cuándo usar:**
- Desarrollo local rápido
- Cuando no usas ArgoCD
- Para forzar recreación de pods

### --no-backend-prune

Desactiva la eliminación automática de pods backend en `CrashLoopBackOff`.

```bash
cd apps/mobile
./launch_flutter_debug.sh --emulator --no-backend-prune
```

**Cuándo usar:**
- Debugging de problemas de backend
- Cuando quieres inspeccionar pods fallidos
- En entornos de producción

### --no-backend-logs-window

Desactiva la apertura automática de una ventana con logs del backend (solo Linux).

```bash
cd apps/mobile
./launch_flutter_debug.sh --linux --no-backend-logs-window
```

**Cuándo usar:**
- Cuando prefieres ver logs en la terminal principal
- En sistemas sin terminal gráfica
- Para reducir ventanas abiertas

### --no-adb-reverse

Desactiva la configuración de `adb reverse` en modo `--device`.

```bash
./launch_flutter_debug.sh -d --no-adb-reverse
```

**Cuándo usar:**
- Cuando usas IP directa en lugar de localhost
- Problemas con adb reverse
- Dispositivos que no soportan reverse

## Menú Interactivo

Si ejecutas el script sin argumentos, se muestra un menú interactivo:

```bash
cd apps/mobile
./launch_flutter_debug.sh

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
make dev-mobile-launch-desktop
```

### Android con Build Limpio

```bash
make dev-mobile-launch-emulator
```

### Android Incremental (Rápido)

```bash
cd apps/mobile
./launch_flutter_debug.sh -d --dirty
```

### Desarrollo Offline

```bash
cd apps/mobile
./launch_flutter_debug.sh --linux --no-backend-check
```

### Con Recuperación Agresiva del Backend

```bash
cd apps/mobile
./launch_flutter_debug.sh --emulator --backend-retries 10 --backend-rollout-restart
```

### Debugging del Backend

```bash
cd apps/mobile
./launch_flutter_debug.sh --linux --no-backend-prune --backend-retries 1
```

### Widgetbook sin Backend

```bash
make dev-mobile-widgetbook
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
cd apps/mobile
./launch_flutter_debug.sh --linux --no-backend-check
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
4. O usa directamente: `cd apps/mobile && ./launch_flutter_debug.sh -d --no-adb-reverse`

### "No se pudo abrir terminal adicional para logs"

**Causa:** Terminal no soportada o no disponible.

**Solución:**
```bash
# Ver logs manualmente
kubectl -n altrupets-dev logs -f deploy/backend --tail=200

# O desactiva la ventana
cd apps/mobile
./launch_flutter_debug.sh --linux --no-backend-logs-window
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
make dev-mobile-launch-emulator

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

---

## Admin Server (Backend desde Mobile)

El **Admin Server** es un servicio HTTP que permite a la app mobile ejecutar comandos de backend (como reiniciar el backend) directamente desde el dispositivo Android.

### Para qué sirve

Cuando estás desarrollando en un dispositivo Android físico y el backend no está corriendo, puedes presionar "Reiniciar Backend" en la app. Esta llamada llega al Admin Server en tu laptop, que ejecuta el comando de despliegue de Minikube.

### Instalación

```bash
# Una sola vez - instala el servicio systemd
sudo ./scripts/install_admin_server.sh
```

### Verificación

```bash
# Ver estado del servicio
sudo systemctl status altrupets-admin

# Probar endpoint de salud
curl http://localhost:3002/health
# {"status":"ok","service":"altrupets-admin"}

# Probar reinicio de backend (cuidado: ejecuta todo el pipeline)
curl -X POST http://localhost:3002/restart-backend
```

### Comandos útiles

```bash
# Iniciar servicio
sudo systemctl start altrupets-admin

# Detener servicio
sudo systemctl stop altrupets-admin

# Reiniciar servicio
sudo systemctl restart altrupets-admin

# Ver logs en tiempo real
sudo journalctl -u altrupets-admin -f
```

### Makefile

También puedes usar el target de Makefile:

```bash
make dev-admin-server-install   # Instalar servicio
make dev-admin-server-start      # Iniciar servicio
make dev-admin-server-stop      # Detener servicio
make dev-admin-server-restart  # Reiniciar servicio
make dev-admin-server-status    # Ver estado
```

### Cómo funciona

1. El script de launch (`launch_flutter_debug.sh`) configura automáticamente:
   - `adb reverse tcp:3001 tcp:3001` - Tunnel para el backend GraphQL
   - `adb reverse tcp:3002 tcp:3002` - Tunnel para el Admin Server

2. Cuando presionas "Reiniciar Backend" en la app:
   - La app Android llama a `http://localhost:3002/restart-backend`
   - El request pasa por ADB reverse al Admin Server en tu laptop
   - El Admin Server ejecuta el comando de despliegue
   - El resultado se devuelve a la app

### Logs

Los logs del Admin Server se encuentran en:

```
logs/backend/admin-server-YYYYMMDD-HHMMSS.log
```
