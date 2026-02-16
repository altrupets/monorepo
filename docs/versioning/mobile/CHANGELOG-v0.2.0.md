# Changelog - Mobile Version 0.2.0

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

### Pending / Next
- [ ] Exponer en UI el contador de cambios pendientes de sincronización.
- [ ] Resolver conflictos de edición offline/online con estrategia explícita.
- [ ] Extender sync offline a más entidades fuera de perfil.
