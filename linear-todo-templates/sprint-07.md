# Sprint 7 (v0.9.0): Infraestructura Cloud

> **Tipo:** `Chore`
> **Tamaño:** `M`
> **Estrategia:** `Solo`
> **Componentes:** `Infra`, `Testing`, `Performance`
> **Impacto:** `—`
> **Banderas:** `—`
> **Rama:** `feat/sprint-7-cloud`
> **Fuente de Spec:** `specs/altrupets/tasks.md` (sección Sprint 7)
> **Estado:** `Parcialmente Hecho`
> **Dependencias:** `Sprint 6 (Endurecimiento)`
> **Proyecto Linear:** `Infrastructure & DevOps`

---

## 👤 CAPA HUMANA

### Historia de Usuario

Como **equipo de desarrollo**, quiero **analíticas, pruebas exhaustivas, CI/CD para tiendas y observabilidad completa** para que **podamos desplegar a producción con confianza y monitorear la plataforma en tiempo real**.

### Contexto / Por Qué

El Sprint 7 prepara la plataforma para el despliegue a producción. Las analíticas (33) proporcionan datos para decisiones de producto. Las pruebas (34) aseguran calidad. CI/CD (36) automatiza el despliegue a tiendas de aplicaciones y entornos cloud. El monitoreo (37) proporciona visibilidad sobre la salud en producción.

### Auditoría del Estado Actual

| Tarea | Estado | Evidencia |
|------|--------|----------|
| 33 (Analíticas) | PARCIAL | Solo seguimiento de eventos de Sentry; sin métricas personalizadas ni seguimiento de adopción de funcionalidades |
| 34 (Pruebas) | PARCIAL | 4 archivos spec de backend, 1 prueba de widget Flutter; <10% de cobertura |
| 36 (CI/CD) | PARCIAL | 8 workflows de GitHub Actions (build, QA, staging, prod, seguridad, uptime); sin despliegue a tienda móvil |
| 37 (Monitoreo) | PARCIAL | Sentry + HealthModule; sin Prometheus/Grafana |

### Criterios de Aceptación

- [ ] 33: Seguimiento de eventos personalizados para acciones de usuario y adopción de funcionalidades
- [ ] 33: Detección de anomalías en patrones de uso
- [ ] 34: Pruebas unitarias para todos los servicios de backend (≥70% de cobertura)
- [ ] 34: Pruebas de widgets para componentes de UI críticos
- [ ] 34: Pruebas de integración para flujos de usuario clave
- [ ] 36: Compilación y despliegue automatizado a tiendas móviles (Google Play, App Store)
- [ ] 36: Pipeline de promoción QA → Staging → Prod
- [ ] 37: Métricas de Prometheus expuestas desde NestJS
- [ ] 37: Dashboards de Grafana para latencia de API, tasas de error, rendimiento de base de datos
- [ ] 37: Reglas de alerta para métricas críticas

### Estrategia del Agente

**Modo:** `Solo`

Ejecución secuencial — las tareas de pruebas y CI/CD dependen unas de otras. Las analíticas y el monitoreo son independientes pero se benefician del enfoque secuencial.

---

## 🔀 Recomendación de Paralelización

**Mecanismo recomendado:** `Subagents` para escritura de pruebas

**Razonamiento:** La tarea de pruebas (34) es la más grande. Usar subagentes para escribir pruebas de diferentes módulos en paralelo mientras el agente principal configura CI/CD y monitoreo.

**Estimación de costo:** ~2x costo base de tokens

---

## Recomendaciones de Issues en Linear

### Issue 1: Sistema de Analíticas
**Título:** Implementar seguimiento de eventos personalizados y métricas de adopción de funcionalidades
**Proyecto:** Backend
**Prioridad:** Medium
**Etiquetas:** Feature, S, Solo, Backend, Performance

### Issue 2: Suite de Pruebas
**Título:** Alcanzar ≥70% de cobertura de pruebas en backend y móvil
**Proyecto:** Backend + Mobile App
**Prioridad:** High
**Etiquetas:** Chore, L, Team, Backend, Frontend, Testing

### Issue 3: CI/CD + Despliegue a Tiendas
**Título:** Automatizar despliegue a tiendas móviles (Google Play, App Store)
**Proyecto:** Infrastructure & DevOps
**Prioridad:** High
**Etiquetas:** Chore, M, Solo, Infra

### Issue 4: Monitoreo + Observabilidad
**Título:** Agregar métricas de Prometheus, dashboards de Grafana y reglas de alerta
**Proyecto:** Infrastructure & DevOps
**Prioridad:** Medium
**Etiquetas:** Chore, M, Solo, Infra, Performance

---

## Resumen de Archivos Afectados

| Acción | Ruta | Líneas Cambiadas (est.) |
|--------|------|---------------------|
| Crear | `apps/backend/src/analytics/` (3 archivos) | ~200 |
| Crear | `apps/backend/test/` (muchos archivos spec) | ~2000 |
| Crear | `apps/mobile/test/` (muchos archivos de prueba) | ~1500 |
| Modificar | `.github/workflows/` (3 archivos) | ~200 |
| Crear | `infrastructure/monitoring/` (prometheus.yml, grafana/) | ~300 |
| Crear | `k8s/base/monitoring/` (manifiestos) | ~200 |
