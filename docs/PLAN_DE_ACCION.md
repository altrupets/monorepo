# Plan de Acción - Proyecto AltruPets
**Fecha de creación:** 17 de febrero de 2026  
**Versión actual:** Backend 0.2.0 | Mobile 0.2.0  
**Próxima versión objetivo:** 0.3.0 (Sprint 1)

---

## 📋 Índice

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Roadmap General](#roadmap-general)
3. [Sprint 1 (v0.3.0) - Coordinación Básica de Rescate](#sprint-1-v030---coordinación-básica-de-rescate)
4. [Sprint 2 (v0.4.0) - Sistema de Adopciones](#sprint-2-v040---sistema-de-adopciones)
5. [Sprint 3 (v0.5.0) - Sistema Financiero y Donaciones](#sprint-3-v050---sistema-financiero-y-donaciones)
6. [Sprint 4 (v0.6.0) - Red Veterinaria](#sprint-4-v060---red-veterinaria)
7. [Sprint 5 (v0.7.0) - Administración Gubernamental](#sprint-5-v070---administración-gubernamental)
8. [Sprint 6 (v0.8.0) - Sistema de Continuidad](#sprint-6-v080---sistema-de-continuidad)
9. [Sprint 7 (v0.9.0) - Infraestructura Cloud](#sprint-7-v090---infraestructura-cloud)
10. [Sprint 8 (v1.0.0) - Release Producción](#sprint-8-v100---release-producción)
11. [Dependencias y Riesgos](#dependencias-y-riesgos)
12. [Métricas de Éxito](#métricas-de-éxito)

---

## 📊 Resumen Ejecutivo

### Estado Actual (v0.2.0)

**Completado:**
- ✅ Infraestructura local DEV con Minikube (PostgreSQL, ArgoCD, Gateway API)
- ✅ Backend GraphQL con autenticación JWT y RBAC
- ✅ Mobile Flutter con Clean Architecture y offline-first
- ✅ Login, perfil de usuario y arquitectura base

**Pendiente:**
- ❌ Features de negocio (95% sin implementar)
- ❌ Testing automatizado (0% cobertura)
- ❌ Infraestructura cloud (QA, STAGING, PROD)
- ❌ CI/CD automatizado

### Objetivo General

Completar el MVP funcional de AltruPets en 8 sprints (6 meses), priorizando la coordinación de rescate animal y cumplimiento de requisitos críticos de la ERS.


---

## 🗺️ Roadmap General

### Visión de 6 Meses (8 Sprints)

```
Sprint 1 (v0.3.0) ─┬─ Coordinación Básica de Rescate [PRIORIDAD 1]
                   │  └─ Centinelas, Auxiliares, Rescatistas
                   │
Sprint 2 (v0.4.0) ─┼─ Sistema de Adopciones
                   │  └─ Adoptantes, Proceso completo
                   │
Sprint 3 (v0.5.0) ─┼─ Sistema Financiero y Donaciones
                   │  └─ Donantes, ONVOPay, KYC
                   │
Sprint 4 (v0.6.0) ─┼─ Red Veterinaria
                   │  └─ Veterinarios, Historial médico
                   │
Sprint 5 (v0.7.0) ─┼─ Administración Gubernamental
                   │  └─ Multi-tenant, Reportes
                   │
Sprint 6 (v0.8.0) ─┼─ Sistema de Continuidad
                   │  └─ Emergencias, Fallecimientos
                   │
Sprint 7 (v0.9.0) ─┼─ Infraestructura Cloud
                   │  └─ QA, STAGING, PROD
                   │
Sprint 8 (v1.0.0) ─┴─ Release Producción
                      └─ Testing, Seguridad, Lanzamiento
```

### Priorización de Requisitos

**Prioridad 1 (Crítico - Sprint 1):**
- REQ-COORD-001 a REQ-COORD-004: Flujo básico de captura y rescate
- REQ-CEN-001 a REQ-CEN-004: Funciones de centinelas
- REQ-AUX-001 a REQ-AUX-006D: Funciones de auxiliares (incluye crowdfunding)
- REQ-RES-001 a REQ-RES-007D: Funciones de rescatistas

**Prioridad 2 (Alta - Sprints 2-3):**
- REQ-ADO-001 a REQ-ADO-005: Sistema de adopciones
- REQ-DON-001 a REQ-DON-005: Sistema de donaciones
- REQ-FLT-001 a REQ-FLT-058: Requisitos Flutter

**Prioridad 3 (Media - Sprints 4-5):**
- REQ-VET-001 a REQ-VET-005: Red veterinaria
- REQ-ADM-001 a REQ-ADM-008: Administración gubernamental

**Prioridad 4 (Baja - Sprint 6):**
- REQ-CONT-001 a REQ-CONT-015: Sistema de continuidad
- REQ-DEATH-001 a REQ-DEATH-015: Proceso de fallecimiento

---

## 🚀 Sprint 1 (v0.3.0) - Coordinación Básica de Rescate

**Duración:** 3 semanas  
**Objetivo:** Implementar el flujo completo de coordinación entre centinelas, auxiliares y rescatistas

### 📦 Entregables

#### Backend (NestJS + GraphQL)

**1. Módulo Captures (Completar)**
- [ ] Refactorizar `CaptureRequest` entity con campos completos
- [ ] Implementar estados: PENDING, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED
- [ ] Agregar campos: urgencyLevel, centinelaId, auxiliarId, rescatistaId
- [ ] Query `getCaptureRequests` con filtros por estado, ubicación, urgencia
- [ ] Mutation `acceptCaptureRequest` (auxiliar acepta solicitud)
- [ ] Mutation `completeCaptureRequest` (auxiliar completa captura)
- [ ] Mutation `cancelCaptureRequest` (con justificación)

**2. Módulo Rescues (Nuevo)**
- [ ] Entity `RescueRequest` con campos: animalId, auxiliarId, rescatistaId, status, description
- [ ] Estados: PENDING, ACCEPTED, IN_TRANSIT, COMPLETED, CANCELLED
- [ ] Mutation `createRescueRequest` (auxiliar sin casa cuna)
- [ ] Query `getRescueRequests` con filtros
- [ ] Mutation `acceptRescueRequest` (rescatista acepta)
- [ ] Mutation `completeRescueRequest` (transferencia completada)

**3. Módulo Notifications (Nuevo)**
- [ ] Entity `Notification` con campos: userId, type, title, message, read, createdAt
- [ ] Mutation `sendNotification` (interno)
- [ ] Query `getNotifications` (por usuario)
- [ ] Mutation `markNotificationAsRead`
- [ ] Integración con Firebase Cloud Messaging (push notifications)

**4. Módulo Chat (Nuevo)**
- [ ] Entity `ChatMessage` con campos: senderId, receiverId, caseId, message, timestamp
- [ ] Mutation `sendMessage`
- [ ] Query `getChatMessages` (por caso)
- [ ] Subscription `onNewMessage` (WebSocket)

**5. Geolocalización**
- [ ] Implementar PostGIS en PostgreSQL
- [ ] Query `getNearbyAuxiliares` (radio 5km)
- [ ] Query `getNearbyRescatistas` (radio 15km)
- [ ] Cálculo de distancias con ST_Distance

