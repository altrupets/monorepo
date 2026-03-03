# Plan de Implementación - AltruPets (8 Sprints)

**Versión:** 0.3.0 (Sprint 1) → 1.0.0 (Sprint 8)
**Duración Total:** 6 meses | **Objetivo:** MVP funcional con coordinación de rescate animal

> **Nota:** Las tareas 1-10 originales (configuración base, modelos, servicios core, auth básica, organizaciones, roles) fueron completadas y removidas de este documento. La numeración continúa desde la tarea 11.

---

## 📋 Índice de Sprints

1. [Sprint 1 (v0.3.0) - Coordinación Básica de Rescate](#sprint-1-v030---coordinación-básica-de-rescate)
2. [Sprint 2 (v0.4.0) - Sistema de Adopciones](#sprint-2-v040---sistema-de-adopciones)
3. [Sprint 3 (v0.5.0) - Sistema Financiero y Donaciones](#sprint-3-v050---sistema-financiero-y-donaciones)
4. [Sprint 4 (v0.6.0) - Red Veterinaria](#sprint-4-v060---red-veterinaria)
5. [Sprint 5 (v0.7.0) - Administración Gubernamental](#sprint-5-v070---administración-gubernamental)
6. [Sprint 6 (v0.8.0) - Sistema de Continuidad](#sprint-6-v080---sistema-de-continuidad)
7. [Sprint 7 (v0.9.0) - Infraestructura Cloud](#sprint-7-v090---infraestructura-cloud)
8. [Sprint 8 (v1.0.0) - Release Producción](#sprint-8-v100---release-producción)

---

# 🚀 SPRINT 1 (v0.3.0) - Coordinación Básica de Rescate

**Duración:** 3 semanas | **Prioridad:** 🔴 CRÍTICA
**Objetivo:** Implementar flujo completo de coordinación entre centinelas, auxiliares y rescatistas

## Fase 3b: Endurecimiento del Servicio de Autenticación

> Origen: `specs/auth-service/` — El auth básico (login/logout, JWT, secure storage, roles) funciona, pero faltan funcionalidades críticas de seguridad y robustez.

- [ ] 5a. Implementar renovación automática de tokens JWT
  - Crear método público `refreshToken()` en AuthService (actualmente falta)
  - Implementar timer proactivo que renueve 5 min antes de expiración (hoy solo detecta expiración al leer)
  - POST a `/auth/refresh` con refresh_token
  - Actualizar tokens en Secure Storage sin interrumpir operación
  - Implementar reintentos con backoff exponencial (1s, 2s, 4s) hasta 3 veces
  - Si renovación falla: redirigir a login
  - _Requisitos: REQ-AUTH-006, REQ-AUTH-007, REQ-AUTH-REL-002, REQ-AUTH-PERF-002_

- [ ] 5b. Implementar manejo de 401/403 en AuthInterceptor
  - En `onError()` para 401: intentar renovar token, reintentar request original con nuevo token
  - En `onError()` para 403: mostrar "Acceso denegado", NO intentar renovar
  - Reemplazar el actual `// TODO` en auth_interceptor.dart
  - _Requisitos: REQ-AUTH-009, REQ-AUTH-010_

- [ ] 5c. Unificar sistemas de autenticación duplicados
  - Actualmente coexisten `AuthService` (sealed class) y `AuthNotifier`/`AuthRepository` (Freezed) con lógica duplicada
  - Dos claves de token diferentes en secure storage (`auth_access_token` vs `auth_token`)
  - Consolidar en un solo flujo coherente
  - Crear `authServiceProvider` de Riverpod (actualmente AuthService no tiene provider)
  - Mover `currentUserProvider` de profile feature a auth feature
  - _Requisitos: REQ-AUTH-013, REQ-AUTH-014_

- [ ] 5d. Implementar flujo de password reset
  - El botón "¿Olvidaste tu contraseña?" actualmente es no-op (`onPressed: () {}`)
  - Crear `ForgotPasswordPage` con envío de email
  - Crear mutation GraphQL para reset de contraseña
  - Implementar ruta en route_names.dart
  - _Requisitos: REQ-AUTH-UX-003_

- [ ] 5e. Implementar detección de actividad sospechosa
  - Detectar múltiples logins desde ubicaciones diferentes
  - Notificar al usuario mediante push
  - Permitir revocación de sesiones activas
  - _Requisitos: REQ-AUTH-012, REQ-SEC-003_

- [ ] 5f. Implementar tests de autenticación
  - Unit tests para AuthService (login, logout, refreshToken, lockout, session restore)
  - Unit tests para AuthInterceptor (401 retry, 403 handling)
  - Unit tests para GraphQLClientService (JWT expiry, session expired stream)
  - Integration test: flujo completo login → uso → token refresh → logout
  - Property tests: Login Success Invariant, Token Expiration Invariant, Logout Cleanup Invariant, Session Restoration Round-Trip, Failed Login Tracking, Token Injection Consistency
  - Cobertura mínima 90% en AuthService
  - _Requisitos: REQ-AUTH-001 a REQ-AUTH-014_

## Fase 4: Sistema de Denuncias Anónimas

- [ ] 11. Implementar formulario de denuncia anónima
  - Crear interfaz sin autenticación para denuncias
  - Implementar captura automática de ubicación GPS
  - Añadir formulario de descripción del incidente
  - Crear funcionalidad de captura de evidencia fotográfica
  - _Requerimientos: 3.1, 3.2_

- [ ] 12. Crear sistema de seguimiento de denuncias
  - Implementar generación de código de seguimiento único
  - Crear interfaz de consulta de estado usando solo código
  - Añadir notificaciones de cambios de estado
  - _Requerimientos: 3.3_

## Fase 5: Gestión de Sentinelas y Solicitudes de Rescate

- [ ] 13. Implementar funcionalidades de sentinela
  - Crear formulario de solicitud de rescate con geolocalización
  - Implementar captura de fotos del animal y descripción
  - Añadir selector de nivel de urgencia
  - Crear interfaz de seguimiento de solicitudes enviadas
  - _Requerimientos: 4.2, 4.3_

- [ ] 14. Crear sistema de matching y notificaciones para rescatistas
  - Implementar algoritmo de búsqueda de rescatistas por proximidad
  - Crear sistema de notificaciones push para solicitudes
  - Añadir interfaz de aceptación/rechazo de solicitudes
  - Implementar escalación automática si no hay respuesta
  - _Requerimientos: 4.1, 4.2, 4.3_

## Fase 6: Red de Rescatistas y Gestión de Casas Cuna

- [ ] 15. Implementar funcionalidades de rescatista
  - Crear interfaz de gestión de solicitudes recibidas
  - Implementar navegación GPS a ubicación del rescate
  - Añadir formularios de actualización de estado del animal
  - Crear sistema de comunicación directa con sentinelas
  - _Requerimientos: 5.2, 5.3, 5.4, 5.5_

- [ ] 16. Crear sistema de gestión de casas cuna
  - Implementar registro de animales con datos médicos
  - Crear interfaz de gestión de inventario de animales
  - Añadir marcado de disponibilidad para adopción
  - Implementar gestión de capacidad máxima
  - _Requerimientos: 7.1, 7.2, 7.3, 7.4_

- [ ] 17. Implementar gestión de inventario y necesidades
  - Crear registro de donaciones recibidas en inventario
  - Implementar publicación de lista de necesidades
  - Añadir estimación de costos para donantes
  - Crear sistema de utilización de insumos
  - _Requerimientos: 7.5, 7.6_

---

# 📱 SPRINT 2 (v0.4.0) - Sistema de Adopciones

**Duración:** 2 semanas | **Prioridad:** 🟠 ALTA
**Objetivo:** Implementar proceso completo de adopción de animales

## Fase 7: Red de Veterinarios Colaboradores

- [ ] 18. Implementar registro de veterinarios individuales y clínicas
  - Crear formularios de registro con credenciales profesionales
  - Implementar carga de licencias sanitarias para clínicas
  - Añadir configuración de especialidades y tarifas preferenciales
  - Crear gestión de horarios de atención
  - _Requerimientos: 8.1, 8.2_

- [ ] 19. Crear sistema de solicitudes de atención veterinaria
  - Implementar búsqueda de veterinarios por proximidad y especialidad
  - Crear interfaz de solicitud de atención urgente
  - Añadir sistema de aceptación/rechazo con justificación
  - Implementar derivación entre veterinarios especializados
  - _Requerimientos: 8.3, 8.4, 8.7_

- [ ] 20. Implementar registro de atención médica
  - Crear formularios para diagnóstico y tratamiento
  - Implementar registro de medicamentos recetados
  - Añadir cálculo de costos del servicio
  - Crear historial médico completo por animal
  - _Requerimientos: 8.5, 8.6_

---

# 💰 SPRINT 3 (v0.5.0) - Sistema Financiero y Donaciones

**Duración:** 2.5 semanas | **Prioridad:** 🟠 ALTA
**Objetivo:** Implementar sistema de donaciones, pagos y gestión financiera

## Fase 8: Sistema Financiero y Gestión Contable

- [ ] 21. Implementar registro de gastos e ingresos para rescatistas
  - Crear formularios de registro de gastos por categoría
  - Implementar registro de donaciones recibidas
  - Añadir captura de comprobantes fotográficos
  - Crear categorización automática de transacciones
  - _Requerimientos: 6.1, 6.2, 6.3_

- [ ] 22. Crear sistema de reportes financieros
  - Implementar configurador de reportes por período
  - Crear generación de informes individuales y organizacionales
  - Añadir exportación en formatos PDF y Excel
  - Implementar métricas de impacto y balance general
  - _Requerimientos: 6.4, 6.5_

- [ ] 23. Implementar sistema de donaciones
  - Crear selector de tipos de donación (insumos/dinero)
  - Implementar múltiples métodos de pago (transferencia, SINPE, tarjetas)
  - Añadir configuración de suscripciones mensuales
  - Crear sistema de crowdfunding con metas y progreso
  - _Requerimientos: 9.1, 9.2, 9.3, 9.4_

- [ ] 24. Implementar cumplimiento KYC y controles regulatorios
  - Crear formularios de debida diligencia para donantes
  - Implementar validación de documentación adicional para montos altos
  - Añadir controles específicos para organizaciones donantes
  - Crear sistema de verificación y referencias bancarias
  - _Requerimientos: 13.1, 13.2, 13.3, 13.4_

---

# 🏥 SPRINT 4 (v0.6.0) - Red Veterinaria

**Duración:** 2 semanas | **Prioridad:** 🟡 MEDIA
**Objetivo:** Completar integración con red de veterinarios colaboradores

---

# 🏛️ SPRINT 5 (v0.7.0) - Administración Gubernamental

**Duración:** 2 semanas | **Prioridad:** 🟡 MEDIA
**Objetivo:** Implementar funcionalidades de administración gubernamental y multi-tenant

## Fase 11: Funcionalidades Gubernamentales

- [ ] 29. Implementar dashboards gubernamentales
  - Crear interfaces para Administrador Gubernamental
  - Implementar supervisión de actividad jurisdiccional
  - Añadir sistema de mediación de conflictos
  - Crear generación de reportes oficiales
  - _Requerimientos: 2.4_

- [ ] 30. Implementar gestión de denuncias gubernamentales
  - Crear escalación automática de denuncias formales
  - Implementar notificaciones a autoridades competentes
  - Añadir seguimiento de casos por jurisdicción
  - Crear reportes de transparencia
  - _Requerimientos: 2.4_

---

# 🔄 SPRINT 6 (v0.8.0) - Sistema de Continuidad

**Duración:** 2 semanas | **Prioridad:** 🟡 MEDIA
**Objetivo:** Implementar sistema de continuidad y gestión de emergencias

---

# ☁️ SPRINT 7 (v0.9.0) - Infraestructura Cloud

**Duración:** 2 semanas | **Prioridad:** 🟡 MEDIA
**Objetivo:** Desplegar infraestructura cloud (QA, STAGING, PROD)

---

# 🎯 SPRINT 8 (v1.0.0) - Release Producción

**Duración:** 2 semanas | **Prioridad:** 🔴 CRÍTICA
**Objetivo:** Testing final, seguridad y lanzamiento a producción

## Fase 9: Sistema de Comunicación y Notificaciones

- [ ] 25. Implementar sistema de chat interno
  - Crear interfaz de chat en tiempo real con WebSockets
  - Implementar envío de mensajes, fotos y ubicación
  - Añadir confirmaciones de lectura y entrega
  - Crear archivado automático al completar casos
  - _Requerimientos: 11.3, 11.4, 11.5, 11.6_

- [ ] 26. Crear sistema de notificaciones push
  - Implementar configuración de preferencias de notificación
  - Crear notificaciones diferenciadas por tipo de usuario
  - Añadir sonidos y vibraciones distintivos para urgencias
  - Implementar centro de notificaciones interno como fallback
  - _Requerimientos: 12.1, 12.2, 12.3, 12.4_

## Fase 10: Sistema de Reputación y Calificaciones

- [ ] 27. Implementar sistema de calificaciones
  - Crear interfaz de calificación post-rescate
  - Implementar validación de calificaciones auténticas
  - Añadir sistema de expiración automática (3 meses)
  - Crear detección de patrones sospechosos
  - _Requerimientos: Implícito en múltiples requerimientos de reputación_

- [ ] 28. Crear visualización de reputación
  - Implementar cálculo y visualización de puntuación de reputación
  - Crear historial de calificaciones recibidas
  - Añadir sistema de reportes de abuso
  - Implementar priorización por reputación en matching
  - _Requerimientos: Implícito en sistema de matching por reputación_

## Fase 12: Optimización y Funcionalidades Avanzadas

- [ ] 31. Implementar funcionalidades offline-first
  - Crear sincronización automática al recuperar conectividad
  - Implementar caché local para datos críticos
  - Añadir almacenamiento local de mensajes y ubicaciones
  - Crear indicadores de estado de conectividad
  - _Requerimientos: 11.8, 10.3_

- [ ] 32. Implementar optimizaciones de performance
  - Crear lazy loading para listas grandes
  - Implementar compresión automática de imágenes
  - Añadir caché de imágenes y datos frecuentes
  - Optimizar consultas y reducir llamadas a API
  - _Requerimientos: Implícito en todos los requerimientos de performance_

- [ ] 33. Crear sistema de analytics y métricas
  - Implementar tracking de eventos de usuario
  - Crear métricas de adopción y uso de funcionalidades
  - Añadir reportes de impacto del sistema
  - Implementar detección de anomalías en uso
  - _Requerimientos: Implícito en requerimientos de analytics_

## Fase 13: Testing y Calidad

- [ ] 34. Implementar suite de testing completa
  - Crear unit tests para todos los servicios y modelos
  - Implementar widget tests para componentes de UI críticos
  - Añadir integration tests para flujos completos de usuario
  - Crear golden tests para consistencia visual
  - _Requerimientos: Todos los requerimientos requieren testing_

- [ ] 35. Implementar testing de seguridad y cumplimiento
  - Crear tests de validación de encriptación de datos sensibles
  - Implementar tests de cumplimiento PCI DSS para pagos
  - Añadir tests de validación KYC y controles regulatorios
  - Crear tests de penetración básicos
  - _Requerimientos: 13.5, 13.6, 13.7_

## Fase 14: Despliegue y Configuración de Producción

- [ ] 36. Configurar CI/CD y despliegue automatizado
  - Implementar pipeline de build automatizado
  - Crear configuración de diferentes entornos
  - Añadir tests automatizados en pipeline
  - Configurar despliegue a stores (Google Play, App Store)
  - _Requerimientos: Principios 12-factor app y cloud-native_

- [ ] 37. Implementar monitoreo y observabilidad
  - Crear logging estructurado y centralizado
  - Implementar métricas de aplicación y performance
  - Añadir crash reporting y error tracking
  - Crear dashboards de monitoreo en tiempo real
  - _Requerimientos: Principios de observabilidad cloud-native_

- [ ] 38. Configurar seguridad de producción
  - Implementar certificate pinning para APIs
  - Crear ofuscación de código para release
  - Añadir detección de root/jailbreak
  - Configurar rate limiting y protección DDoS
  - _Requerimientos: 13.5, 13.6, 13.7_

---

## 📊 Resumen de Tareas por Sprint

| Sprint | Versión | Tareas | Duración | Prioridad |
|--------|---------|--------|----------|-----------|
| 1 | v0.3.0 | 5a-5f, 11-17 | 3 sem | 🔴 CRÍTICA |
| 2 | v0.4.0 | 18-20 | 2 sem | 🟠 ALTA |
| 3 | v0.5.0 | 21-24 | 2.5 sem | 🟠 ALTA |
| 4 | v0.6.0 | - | 2 sem | 🟡 MEDIA |
| 5 | v0.7.0 | 29-30 | 2 sem | 🟡 MEDIA |
| 6 | v0.8.0 | - | 2 sem | 🟡 MEDIA |
| 7 | v0.9.0 | - | 2 sem | 🟡 MEDIA |
| 8 | v1.0.0 | 25-38 | 2 sem | 🔴 CRÍTICA |

---

**Última actualización:** 3 de marzo de 2026
**Estado:** Sprint 1 en progreso (Tareas 1-10 completadas, auth hardening pendiente)
