# Resumen de Implementación de AltruPets

> **Generado:** 2026-03-03 | **Fuente:** `specs/altrupets/tasks.md`
> **Objetivo:** $10K MRR | **Cronograma:** 6 meses | **Sprints Totales:** 8

---

## Progreso General

| Sprint | Versión | Estado | % Completo | Ingresos en Riesgo |
|--------|---------|--------|------------|-----------------|
| **Sprint 1** | v0.3.0 | **Parcialmente Hecho** | ~8% | Bloquea todo |
| **Sprint 2** | v0.4.0 | **Bloqueado** (por Sprint 1) | 0% | $6,825/mes |
| **Sprint 3** | v0.5.0 | **Bloqueado** (por Sprint 1+2) | 0% | $1,135/mes |
| **Sprint 4** | v0.6.0 | **Bloqueado** (por Sprint 1+2) | 0% | $672/mes |
| **Sprint 5** | v0.7.0 | **Bloqueado** (por Sprint 3+4) | 0% | Reducción de deserción |
| **Sprint 6** | v0.8.0 | **Parcialmente Hecho** | ~15% | Confiabilidad |
| **Sprint 7** | v0.9.0 | **Parcialmente Hecho** | ~25% | Desplegabilidad |
| **Sprint 8** | v1.0.0 | **Parcialmente Hecho** | ~15% | Lanzamiento |

**Completación General de la Plataforma: ~8%**
(La infraestructura está ~90% madura, pero la implementación de funcionalidades está ~5%)

---

## Lo Que Ya Funciona

| Componente | Estado | Detalles |
|-----------|--------|---------|
| Registro de usuario + login | Funcionando | JWT, hashing dual SHA-256, selección de rol |
| API de Backend (NestJS + GraphQL) | Funcionando | 6 módulos: auth, users, captures, organizations, health, web |
| Shell de app móvil (Flutter) | Funcionando | 8 carpetas de funcionalidades, gestión de estado con Riverpod |
| Scaffold de app web B2G | Funcionando | Vue 3 + Inertia.js, 3 stubs de rutas |
| Infraestructura K8s | Funcionando | Minikube, Kustomize, ArgoCD, Gateway API |
| Pipelines CI/CD | Funcionando | 8 workflows de GitHub Actions (build, QA, staging, prod, seguridad) |
| Gestión de secretos | Funcionando | Infisical integrado |
| Monitoreo (parcial) | Funcionando | Seguimiento de errores + profiling con Sentry |
| Chat (parcial) | Funcionando | Mensajería P2P con Firebase Firestore |
| Offline (MVP) | Funcionando | Colas de sincronización, SQLite, almacenamiento local con Hive |

## Lo Que Está Roto / Faltante

| Brecha | Impacto en Ingresos | Sprint |
|-----|---------------|--------|
| **Sin entidad Animal** | Bloquea TODAS las funcionalidades | Sprint 1 |
| **Sin gestión de Casa Cuna** | Bloquea subsidios, adopciones, donaciones | Sprint 1 |
| **Auth: conflicto de sistema dual** | Bugs en gestión de sesiones | Sprint 1 |
| **Auth: token refresh no expuesto** | Sesiones móviles expiran silenciosamente | Sprint 1 |
| **Sin PostGIS** | Sin enrutamiento jurisdiccional, sin consultas de proximidad | Sprint 1 |
| **Sin perfil Vet** | Sin receptor de subsidios, sin búsqueda de clínicas | Sprint 1 |
| **Secreto JWT hardcodeado** | **Vulnerabilidad de seguridad crítica** | Sprint 1 (QW-4) |
| **createCaptureRequest sin protección** | Cualquiera puede crear solicitudes | Sprint 1 (QW-1) |
| **Redis no conectado** | Tokens perdidos al reiniciar pod | Sprint 1 (QW-5) |
| **Sin flujo de subsidios** | $3,500/mes en riesgo | Sprint 2 |
| **Sin reportes de abuso** | $1,425/mes en riesgo | Sprint 2 |
| **Sin dashboard municipal** | $1,900/mes en riesgo | Sprint 2 |
| **Sin coordinación de rescate** | Sin actividad en la plataforma | Sprint 3 |
| **Sin flujo de adopción** | Sin resultados positivos | Sprint 3 |
| **Sin notificaciones push** | Sin capacidad de respuesta en tiempo real | Sprint 3 |

---

## Orden de Ejecución Recomendado

### Ruta Crítica (respetando el grafo de dependencias)

```
Semana 1-2: Sprint 1 (Fundación) — 4 tracks paralelos
  ├── Track A: Entidades Animal + Casa Cuna (A1-A4)      [Backend]
  ├── Track B: Endurecimiento de Auth (QW-1..5, 5a-5c, 5f) [Backend + Mobile]
  ├── Track C: Perfil Vet (C1)                             [Backend]
  └── Track D: PostGIS + Jurisdicciones (D1-D2)            [Database]

Semana 3-5: Sprint 2 (Ingresos B2G) — 3 fases paralelas
  ├── Fase A: Flujo de subsidios (S1-S4)                   [Backend + Mobile + Web]
  ├── Fase B: Reportes de abuso (R1-R2)                    [Backend + Mobile]
  └── Fase C: Dashboard Municipal (G1-G2)                  [Web + Backend]

Semana 5-8: Sprint 3 (Entrega de Valor) — 4 fases paralelas
  ├── Fase D: Coordinación de rescate (13-15)               [Backend + Mobile]
  ├── Fase E: Adopciones (AD1-AD3)                          [Backend + Mobile]
  ├── Fase F: Notificaciones push (26)                      [Backend + Mobile]
  └── Fase G: Auth complementario (5d, 5d-b)                [Backend + Mobile]

Semana 8-10: Sprint 4 (Ecosistema Vet + Donaciones) — 5 fases
  ├── Fase H: Gestión de pacientes vet (19-20)              [Backend + Mobile]
  ├── Fase I: Facturación vet (V1)                          [Backend]
  ├── Fase J: Donaciones P2P (23)                           [Backend + Mobile]
  ├── Fase K: Integración de chat (25)                      [Backend + Mobile]
  └── Fase L: Reportes de transparencia (22)                [Backend + Web]

Semana 10-12: Sprint 5 (Retención) — 2 flujos paralelos
  ├── Extensiones de adopción (AD4-AD5)                     [Backend + Mobile]
  └── Compromiso (DON1, VET1, 27-28)                       [Backend + Mobile]

Semana 12-14: Sprint 6 (Endurecimiento) — Secuencial
  └── Seguridad + Offline + Rendimiento (5e, 24, 31, 32)   [Backend + Mobile]

Semana 14-16: Sprint 7 (Cloud) — Mixto
  ├── Suite de pruebas (34)                                 [Todos]
  ├── Despliegue CI/CD a tiendas (36)                       [Infra]
  └── Monitoreo (33, 37)                                    [Infra]

Semana 16-18: Sprint 8 (Release) — Con puertas humanas
  └── Pruebas de seguridad + Endurecimiento de prod (35, 38) [Todos]
```

---

## Esfuerzo Total Estimado

| Sprint | Tamaño | Presupuesto de Tokens | Calendario | Estrategia |
|--------|------|-------------|----------|----------|
| Sprint 1 | L | 200-500K | 2 semanas | Team (3 agentes) |
| Sprint 2 | XL | 500K+ | 3 semanas | Team (3 agentes) |
| Sprint 3 | XL | 500K+ | 3 semanas | Team (3 agentes) |
| Sprint 4 | L | 200-500K | 2.5 semanas | Team (3 agentes) |
| Sprint 5 | L | 200-500K | 2 semanas | Team (2 agentes) |
| Sprint 6 | M | 100-200K | 2 semanas | Solo |
| Sprint 7 | M | 100-200K | 2 semanas | Solo + Subagents |
| Sprint 8 | M | 100-200K | 2 semanas | Human-gated |
| **Total** | — | **~2.5M tokens** | **~18 semanas** | — |

---

## Análisis de Ruta Crítica

```
Entidad Animal (Sprint 1) ──────────────────────────────────────────────────▶
     │
     ├── Casa Cuna (Sprint 1) ──── Subsidios (Sprint 2) ──── Facturación (Sprint 4)
     │                                   │
     │                                   └── Dashboard (Sprint 2) ── Reportes (Sprint 4)
     │
     ├── Adopciones (Sprint 3) ──── Contratos (Sprint 5)
     │                                   │
     │                                   └── Seguimientos (Sprint 5)
     │
     └── Donaciones (Sprint 4) ──── Panel de Impacto (Sprint 5)

PostGIS (Sprint 1) ──── Enrutamiento Jurisdiccional (Sprint 2) ──── Auto-asignación
                                                                      (subsidios + abuso)

Auth (Sprint 1) ──── Todas las funcionalidades móviles
                          │
                          ├── Notificaciones Push (Sprint 3) ──── Todo en tiempo real
                          │
                          └── Reset de Contraseña (Sprint 3) ──── Completación de onboarding
```

**Punto único de fallo:** La **entidad Animal** (Sprint 1, Tarea A1). Hasta que esta exista, $9,372/mes de funcionalidades de ingresos no pueden ser construidas.

---

## Todos los Issues de Linear a Crear (Lote)

### Sprint 1 (5 issues)

| # | Título | Proyecto | Prioridad | Etiquetas |
|---|-------|---------|----------|--------|
| 1 | Corregir 5 quick wins de seguridad (auth guard, secreto JWT, Redis, reportedById, refreshToken) | Backend | Urgent | Bug, S, Solo, Backend, Security, Quick Win |
| 2 | Crear entidad Animal, gestión de Casa Cuna y lista de necesidades | Backend | Urgent | Feature, M, Solo, Backend, Database, Critical Path, Revenue |
| 3 | Unificar sistemas de auth, implementar token refresh, manejo 401/403 y pruebas | Mobile App | High | Improvement, M, Solo, Frontend, Security, Critical Path |
| 4 | Crear entidad VetProfile con registro de clínica | Backend | High | Feature, S, Solo, Backend, Database, Revenue |
| 5 | Habilitar PostGIS, migrar coordenadas, crear tabla de jurisdicciones | Infrastructure & DevOps | High | Feature, M, Solo, Database, Infra, Critical Path |

### Sprint 2 (3 issues)

| # | Título | Proyecto | Prioridad | Etiquetas |
|---|-------|---------|----------|--------|
| 6 | Construir flujo de solicitud de subsidio vet: creación, auto-enrutamiento, revisión, aprobación | Backend | Urgent | Feature, L, Team, Backend, Database, Frontend, Critical Path, Revenue |
| 7 | Construir formulario de reporte de abuso con GPS, código de seguimiento y seguimiento de estado | Backend | Urgent | Feature, M, Team, Backend, Frontend, Critical Path, Revenue |
| 8 | Construir dashboard municipal con KPIs por jurisdicción y gestión de reportes de abuso | Web Quality | High | Feature, M, Team, Backend, Web Quality, Critical Path, Revenue |

### Sprint 3 (4 issues)

| # | Título | Proyecto | Prioridad | Etiquetas |
|---|-------|---------|----------|--------|
| 9 | Construir coordinación de rescate: alertas centinela, emparejamiento de auxiliares, transferencia de rescatista | Backend | High | Feature, L, Team, Backend, Frontend, Critical Path |
| 10 | Construir flujo de adopción: publicar, explorar, solicitar, evaluar, aprobar | Backend | High | Feature, L, Team, Backend, Frontend |
| 11 | Implementar Firebase Cloud Messaging con notificaciones basadas en rol | Backend | High | Feature, M, Solo, Backend, Frontend |
| 12 | Implementar flujos de reset de contraseña y verificación de email | Backend | Medium | Feature, S, Solo, Backend, Frontend, Security |

### Sprint 4 (5 issues)

| # | Título | Proyecto | Prioridad | Etiquetas |
|---|-------|---------|----------|--------|
| 13 | Construir solicitudes de atención vet, registros médicos e historial de tratamientos | Backend | High | Feature, M, Team, Backend, Frontend, Revenue |
| 14 | Construir facturación digital de subsidios: enviar, rastrear, pagar | Backend | High | Feature, M, Solo, Backend, Revenue |
| 15 | Construir sistema de donaciones peer-to-peer (SINPE + en especie, cumplimiento SUGEF) | Backend | High | Feature, M, Team, Backend, Frontend |
| 16 | Auto-crear salas de chat para flujos de rescate/adopción | Backend | Medium | Improvement, S, Solo, Backend, Frontend |
| 17 | Construir reportes de transparencia configurables con exportación PDF/Excel | Backend | Medium | Feature, M, Solo, Backend, Web Quality |

### Sprint 5 (4 issues)

| # | Título | Proyecto | Prioridad | Etiquetas |
|---|-------|---------|----------|--------|
| 18 | Construir contratos de adopción digital con firma electrónica y seguimientos automatizados | Backend | Medium | Feature, M, Team, Backend, Frontend |
| 19 | Construir panel de impacto del donante con puntajes de transparencia | Backend | Medium | Feature, S, Solo, Backend, Frontend |
| 20 | Implementar prompts de upgrade basados en uso para clínicas veterinarias | Backend | Medium | Feature, S, Solo, Backend, Frontend, Revenue |
| 21 | Construir sistema de calificación con detección de fraude y visualización de reputación | Backend | Medium | Feature, M, Solo, Backend, Frontend |

### Sprint 6 (4 issues)

| # | Título | Proyecto | Prioridad | Etiquetas |
|---|-------|---------|----------|--------|
| 22 | Detectar inicios de sesión multi-ubicación, notificación push, revocación de sesión | Backend | Medium | Improvement, S, Solo, Backend, Security |
| 23 | Agregar formulario KYC para donaciones de alto valor (cumplimiento SUGEF) | Backend | Low | Feature, S, Solo, Backend, Frontend, Security |
| 24 | Mejorar soporte offline con resolución de conflictos y auto-sincronización | Mobile App | Medium | Improvement, M, Solo, Frontend, Performance |
| 25 | Conectar caché Redis, compresión de imágenes, carga diferida, optimización de GraphQL | Backend | Medium | Improvement, S, Solo, Backend, Frontend, Performance |

### Sprint 7 (4 issues)

| # | Título | Proyecto | Prioridad | Etiquetas |
|---|-------|---------|----------|--------|
| 26 | Implementar seguimiento de eventos personalizados y métricas de adopción de funcionalidades | Backend | Medium | Feature, S, Solo, Backend, Performance |
| 27 | Alcanzar ≥70% de cobertura de pruebas en backend y móvil | Backend | High | Chore, L, Team, Backend, Frontend, Testing |
| 28 | Automatizar despliegue a tiendas móviles (Google Play, App Store) | Infrastructure & DevOps | High | Chore, M, Solo, Infra |
| 29 | Agregar métricas de Prometheus, dashboards de Grafana y reglas de alerta | Infrastructure & DevOps | Medium | Chore, M, Solo, Infra, Performance |

### Sprint 8 (2 issues)

| # | Título | Proyecto | Prioridad | Etiquetas |
|---|-------|---------|----------|--------|
| 30 | Ejecutar pruebas de penetración, validar encriptación, verificar aislamiento de flujo de fondos | Infrastructure & DevOps | Urgent | Chore, M, Human, Security, Testing, Critical Path |
| 31 | Configurar cert pinning, ofuscación de código, detección de root, protección DDoS | Infrastructure & DevOps | Urgent | Chore, M, Human, Security, Infra, Frontend, Critical Path |

**Total: 31 issues de Linear**

---

## Cronograma de Desbloqueo de Ingresos

```
Semana 0  ░░░░░░░░░░░░░░░░░░░░░  $0/mes (estado actual)
Semana 2  ████░░░░░░░░░░░░░░░░░  Sprint 1 listo → Fundación lista
Semana 5  ████████████░░░░░░░░░  Sprint 2 listo → $6,825/mes desbloqueados (B2G)
Semana 8  ██████████████████░░░  Sprint 3 listo → +$1,135/mes (entrega de valor)
Semana 10 ████████████████████░  Sprint 4 listo → +$672/mes (vet + donaciones)
Semana 12 █████████████████████  Sprint 5 listo → Reducción de deserción activa
Semana 18 █████████████████████  v1.0.0 lanzado → Objetivo de $10K MRR
```

---

## Verificación de Alineamiento con SRD

| Regla SRD | Estado | Cobertura por Sprint |
|----------|--------|----------------|
| #1 Ingresos B2G primero | ✅ | Sprint 2 (subsidios + abuso + dashboard) |
| #2 Los animales deben existir | ✅ | Sprint 1 (entidad Animal) |
| #3 Auth debe ser sólido | ✅ | Sprint 1 (QW + Track B) |
| #4 Clínicas vet son segundo ingreso | ✅ | Sprint 1 (perfil) + Sprint 4 (gestión de pacientes) |
| #5 Nunca intermediar fondos | ✅ | Sprint 4 (donaciones P2P, cumplimiento SUGEF) |
| #6 Rescate != ingresos | ✅ | Sprint 3 (entrega de valor, no Sprint 1-2) |
| #7 Dashboard siempre activo | ✅ | Sprint 2 (mostrar los datos que existan) |
| #8 Rescatistas pagan $0 por siempre | ✅ | Sin precios para funcionalidades de rescate |
| #9 Reportes de abuso requieren auth | ✅ | Sprint 2 (R1 requiere login) |
| #10 Donaciones en especie de primera clase | ✅ | Sprint 4 (Tarea 23 incluye en especie) |

---

## Archivos de Brief por Sprint

| Archivo | Sprint | Contenido |
|------|--------|---------|
| [`sprint-01.md`](sprint-01.md) | Sprint 1 (v0.3.0) | Fundación + Quick Wins |
| [`sprint-02.md`](sprint-02.md) | Sprint 2 (v0.4.0) | Ingresos B2G |
| [`sprint-03.md`](sprint-03.md) | Sprint 3 (v0.5.0) | Entrega de Valor |
| [`sprint-04.md`](sprint-04.md) | Sprint 4 (v0.6.0) | Ecosistema Vet + Donaciones |
| [`sprint-05.md`](sprint-05.md) | Sprint 5 (v0.7.0) | Retención |
| [`sprint-06.md`](sprint-06.md) | Sprint 6 (v0.8.0) | Endurecimiento |
| [`sprint-07.md`](sprint-07.md) | Sprint 7 (v0.9.0) | Infraestructura Cloud |
| [`sprint-08.md`](sprint-08.md) | Sprint 8 (v1.0.0) | Release Producción |

---

**Última actualización:** 3 de marzo de 2026
**Generado por:** Spec Implementation Analyzer (Claude Code)
**Fuente:** `specs/altrupets/tasks.md` + SRD Framework (`srd/`)
