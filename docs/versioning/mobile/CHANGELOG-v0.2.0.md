# Changelog - Mobile Version 0.2.0

## [0.2.1] - 2026-02-18

### Security

**Flutter/Dart**
- Fixed unused imports:
  - `lib/core/error/error_logging_observer.dart` - removed unused `flutter/foundation.dart`
  - `lib/features/organizations/presentation/providers/organizations_provider.dart` - removed 3 unused imports
- Fixed null comparison: `lib/features/profile/presentation/pages/profile_page.dart`
- Added missing dependency: `connectivity_plus` to `pubspec.yaml`
- Formatted 142 files with Dart formatter

**Archivos modificados:**
- `lib/core/error/error_logging_observer.dart`
- `lib/features/organizations/presentation/providers/organizations_provider.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`
- `pubspec.yaml`

---

## [0.2.0] - 2026-02-16

### Added
- [x] Arquitectura offline-first inicial para perfil de usuario.
- [x] Cache local de `currentUser` con `Hive`:
  - `apps/mobile/lib/core/storage/profile_cache_store.dart`
- [x] Cola de sincronización offline para mutaciones de perfil con `sqflite`:
  - `apps/mobile/lib/core/sync/profile_update_queue_store.dart`
- [x] Metadata liviana en `shared_preferences`:
  - `apps/mobile/lib/core/storage/app_prefs_store.dart`
  - timestamp de último sync y contador de pendientes.
- [x] Dependencias agregadas en `apps/mobile/pubspec.yaml`:
  - `hive`
  - `hive_flutter`
  - `sqflite`
  - `path`

### Changed
- [x] `currentUserProvider` ahora:
  - hace `flush` de cola cuando hay conexión,
  - consulta backend,
  - persiste respuesta en cache local,
  - y usa fallback a cache cuando no hay red o falla de backend no-auth.
- [x] `updateUserProfileProvider` ahora:
  - en modo offline encola cambios y aplica actualización optimista al cache local,
  - en modo online sincroniza pendientes antes de aplicar la mutación actual.
- [x] Inicialización temprana de almacenamiento local (Hive) en `apps/mobile/lib/main.dart`.
- [x] Logout limpia token + cache + cola offline:
  - `apps/mobile/lib/features/auth/data/repositories/auth_repository.dart`

### Security
- [x] Se mantiene `flutter_secure_storage` como fuente de verdad para token/JWT.
- [x] No se almacenan credenciales en `shared_preferences`.

### Fixed
- [x] Estado de perfil vacío tras reiniciar app cuando backend no responde:
  - ahora hay recuperación desde cache local de perfil.

### Testing Notes
- [x] `flutter analyze` ejecutado sin errores de compilación (solo advertencias/info de lint existentes).
- [ ] Prueba manual recomendada:
  1. Login online y guardar perfil.
  2. Desconectar red y reabrir app: perfil debe mostrarse desde cache.
  3. Editar perfil offline: debe encolar cambios.
  4. Reconectar red y refrescar perfil: cola debe sincronizarse.

### Completado en v0.2.1 ✅
- [x] Exponer en UI el contador de cambios pendientes de sincronización.
- [x] Extender sync offline a más entidades fuera de perfil.

---

## [0.2.1] - 2026-02-18

### Added - UI de Sincronización
- [x] Provider de estado de sincronización: `sync_status_provider.dart`
  - Exposición de contador de cambios pendientes
  - Estados: sincronizado, sincronizando, cambios pendientes
- [x] Widgets de sincronización siguiendo Atomic Design:
  - **Átomo**: `SyncStatusIndicator` - Icono con estado visual
  - **Molécula**: `SyncBadge` - Badge con icono y contador
  - **Organismo**: `SyncStatusBanner` - Banner completo con acciones
- [x] Integración en `ProfilePage` con badge y banner de sincronización

### Added - Sync Offline Genérico
- [x] Store genérico: `GenericSyncQueueStore` soporta múltiples entidades
  - Tipos soportados: `profile`, `organization`, `rescue`, `donation`
  - Operaciones: `create`, `update`, `delete`
  - Retry automático con contador de intentos
- [x] Integración con Organizations:
  - `registerOrganization` soporta modo offline
  - Creación optimista de organizaciones temporales
  - Método `syncPendingOperations()` para sincronización manual
  - Estado extendido con `pendingSyncCount` y `hasPendingChanges`

### Architecture - Atomic Design
- [x] Estructura de widgets según metodología Atomic Design:
  - Átomos: Componentes básicos reutilizables
  - Moléculas: Grupos simples funcionando juntos
  - Organismos: Secciones complejas de UI
- [x] Uso de tokens de tema (colores, tipografía) de Material 3
- [x] Soporte para modo oscuro automático

### Changed
- [x] `currentUserProvider` integrado con `syncStatusProvider`
  - Actualiza estado de sincronización automáticamente
  - Marca como sincronizado al completar flush
  - Refresca conteo de pendientes después de cada operación
- [x] `OrganizationsNotifier` con soporte offline completo
  - Verificación de conexión antes de operaciones
  - Encolamiento automático en modo offline
  - Actualización optimista de UI

### Files Created
```
lib/core/sync/
  ├── sync_status_provider.dart      # Estado de sincronización
  └── generic_sync_queue_store.dart  # Cola offline genérica

lib/core/widgets/atoms/
  └── sync_status_indicator.dart     # Átomo: indicador visual

lib/core/widgets/molecules/
  └── sync_badge.dart                # Molécula: badge con contador

lib/core/widgets/organisms/
  └── sync_status_banner.dart        # Organismo: banner con acciones
```

### Usage Example
```dart
// En cualquier pantalla, mostrar badge de sincronización
const SyncBadge(compact: true)

// Banner automático en la parte superior
const SyncStatusBanner()

// Forzar sincronización manual
ref.read(syncStatusProvider.notifier).setSyncing(true);
```

### Notas de Implementación
- **MVP**: Se optó por una estrategia simple "last-write-wins" (último en escribir gana)
- **No se implementó**: Resolución de conflictos compleja (no es requisito del sistema)
- **Estrategia**: Si hay cambios pendientes, se sincronizan en orden FIFO cuando hay conexión
