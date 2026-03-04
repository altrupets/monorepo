# Sprint 6 (v0.8.0): Endurecimiento

> **Tipo:** `Improvement`
> **Tamaño:** `M`
> **Estrategia:** `Solo`
> **Componentes:** `Backend`, `Frontend`, `Security`, `Performance`
> **Impacto:** `—`
> **Banderas:** `—`
> **Rama:** `feat/sprint-6-hardening`
> **Fuente de Spec:** `specs/altrupets/tasks.md` (sección Sprint 6)
> **Estado:** `Parcialmente Hecho`
> **Dependencias:** `Sprint 1 (Auth)`
> **Proyecto Linear:** `Backend` + `Mobile App` + `Infrastructure & DevOps`

---

## 👤 CAPA HUMANA

### Historia de Usuario

Como **operador de plataforma**, quiero **endurecimiento de seguridad, soporte offline y optimizaciones de rendimiento** para que **la plataforma sea confiable para usuarios en áreas rurales con baja conectividad y segura contra ataques**.

### Contexto / Por Qué

El Sprint 6 es un sprint de endurecimiento — sin funcionalidades nuevas, solo hacer las funcionalidades existentes más robustas. La detección de actividad sospechosa (5e) previene acceso no autorizado. Offline-first (31) permite coordinación de rescate en áreas con conectividad deficiente — crítico para zonas rurales de Costa Rica. Las optimizaciones de rendimiento (32) mejoran la experiencia de usuario en todas las funcionalidades.

### Auditoría del Estado Actual

| Tarea | Estado | Evidencia |
|------|--------|----------|
| 5e (Actividad Sospechosa) | PARCIAL | Sentry + rate limiting existen, sin detección de multi-login |
| 24 (KYC) | NO_INICIADA | Sin entidad ni flujo de trabajo |
| 31 (Offline-First) | PARCIAL | Cola de sincronización MVP, SQLite, Hive configurados; sin resolución de conflictos |
| 32 (Rendimiento) | PARCIAL | CacheModule existe (en memoria), sin Redis conectado, sin optimización de imágenes |

### Criterios de Aceptación

- [ ] 5e: Detectar múltiples inicios de sesión desde diferentes ubicaciones, notificar al usuario, permitir revocación de sesión
- [ ] 24: Formulario KYC simplificado para donaciones por encima de un umbral configurable
- [ ] 31: Datos críticos almacenados localmente (inventario de casa cuna, solicitudes pendientes), auto-sincronización al conectarse
- [ ] 31: Indicador de conectividad visible para el usuario
- [ ] 32: Imágenes auto-comprimidas antes de subir, carga diferida para listas, caché Redis conectado

### Estrategia del Agente

**Modo:** `Solo`

Un solo agente maneja todas las tareas secuencialmente ya que son mayormente mejoras pequeñas e independientes.

---

## 🔀 Recomendación de Paralelización

**Mecanismo recomendado:** `Ninguno (Solo)`

**Razonamiento:** Sprint de tamaño M con 4 mejoras independientes, cada una de tamaño S. Un solo agente puede manejarlas secuencialmente sin sobrecarga de coordinación.

**Estimación de costo:** ~1x costo base de tokens

---

## Recomendaciones de Issues en Linear

### Issue 1: Detección de Actividad Sospechosa
**Título:** Detectar inicios de sesión multi-ubicación, notificación push, revocación de sesión
**Proyecto:** Backend
**Prioridad:** Medium
**Etiquetas:** Improvement, S, Solo, Backend, Security

### Issue 2: KYC Simplificado
**Título:** Agregar formulario KYC para donaciones de alto valor (cumplimiento SUGEF)
**Proyecto:** Backend + Mobile App
**Prioridad:** Low
**Etiquetas:** Feature, S, Solo, Backend, Frontend, Security

### Issue 3: Mejora de Offline-First
**Título:** Mejorar soporte offline con resolución de conflictos y auto-sincronización
**Proyecto:** Mobile App
**Prioridad:** Medium
**Etiquetas:** Improvement, M, Solo, Frontend, Performance

### Issue 4: Optimizaciones de Rendimiento
**Título:** Conectar caché Redis, compresión de imágenes, carga diferida, optimización de GraphQL
**Proyecto:** Backend + Mobile App
**Prioridad:** Medium
**Etiquetas:** Improvement, S, Solo, Backend, Frontend, Performance

---

## Resumen de Archivos Afectados

| Acción | Ruta | Líneas Cambiadas (est.) |
|--------|------|---------------------|
| Crear | `apps/backend/src/security/` (3 archivos) | ~200 |
| Modificar | `apps/backend/src/app.module.ts` | ~10 |
| Modificar | `apps/mobile/lib/core/sync/` (3 archivos) | ~200 |
| Modificar | `apps/mobile/lib/core/services/` (2 archivos) | ~100 |
| Crear | `apps/backend/src/kyc/` (3 archivos) | ~150 |
