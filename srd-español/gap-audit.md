# Matriz de Auditoría de Brechas — AltruPets

**Objetivo**: $10K MRR | **Ingresos Totales en Riesgo**: $9,372/mes (93.7%)
**Completitud General de la Plataforma**: ~28% (infraestructura madura, caminos de ingresos al 0-8%)

## Capa 1: Matriz de Impacto Persona x Recorrido

```
         J1   J2   J3   J4   J5   J6   J7   J8   J9   J10
P01 Gab  X    -    -    $    $    -    $    -    -    -     <- Compradora municipal (75% ingresos)
P02 Lau  X    -    -    X    X    -    X    -    -    -     <- Operadora municipal
P03 Car  X    -    -    $    -    -    -    -    $    -     <- Clínica vet pagadora (18% ingresos)
P04 Pri  X    -    -    X    -    -    -    -    X    -     <- Empleada veterinaria
P05 Sof  X    $    $    X    -    $    -    X    -    X     <- Rescatista usuaria avanzada
P06 Mig  X    $    $    X    X    $    -    X    -    X     <- Líder de ONG
P07 And  X    -    -    -    X    -    -    -    -    -     <- Centinela
P08 Die  X    X    -    -    -    -    -    -    -    X     <- Auxiliar
P09 Mar  X    -    $    -    -    -    -    -    -    -     <- Adoptante
P10 Rob  X    -    -    -    -    -    -    $    -    -     <- Donante

Leyenda: X = Esencial | $ = Disparador de conversión
```

## Capa 2: Ingresos en Riesgo por Recorrido

Fórmula: `Ingresos en riesgo = (% de atribución de conversión) x $10K MRR x (1 - Puntuación/100)`

| Rango | Recorrido | Puntuación | % Atrib. Conv. | Ingresos en Riesgo | Personas Bloqueadas |
|------|---------|-------|---------------|-----------------|-----------------|
| 1 | **J4** Subsidio Veterinario | 0% | 35% | **$3,500/mes** | P01,P02,P03,P04,P05,P06 |
| 2 | **J7** Panel Municipal | 5% | 20% | **$1,900/mes** | P01,P02 |
| 3 | **J5** Reportes de Maltrato | 5% | 15% | **$1,425/mes** | P01,P02,P06,P07 |
| 4 | **J9** Incorporación Veterinaria | 0% | 10% | **$1,000/mes** | P03,P04 |
| 5 | **J6** Gestión Casa Cuna | 10% | 8% | **$720/mes** | P05,P06 |
| 6 | **J2** Coordinación de Rescate | 15% | 3% | **$255/mes** | P05,P06,P07,P08 |
| 7 | **J1** Registro/Incorporación | 60% | 5% | **$200/mes** | TODOS |
| 8 | **J3** Adopción | 0% | 2% | **$200/mes** | P05,P06,P09 |
| 9 | **J8** Donación | 8% | 1% | **$92/mes** | P10,P06 |
| 10 | **J10** Chat | 20% | 1% | **$80/mes** | TODOS activos |

## Capa 3: Resumen de Viabilidad por Persona

| Persona | Recorridos Esenciales (puntuaciones) | Puntaje Prom. | Nivel | Impacto en Ingresos |
|---------|---------------------------|-----------|------|----------------|
| P01 Gabriela | J1(60%), J4(0%), J5(5%), J7(5%) | **17%** | **ROTO** | $7,500/mes en riesgo |
| P02 Laura | J1(60%), J4(0%), J5(5%), J7(5%) | **17%** | **ROTO** | (en P01) |
| P03 Dr. Carlos | J1(60%), J4(0%), J9(0%) | **20%** | **ROTO** | $2,000/mes en riesgo |
| P04 Dra. Priscilla | J1(60%), J4(0%), J9(0%) | **20%** | **ROTO** | (en P03) |
| P05 Sofía | J1(60%), J2(15%), J3(0%), J4(0%), J6(10%), J8(8%) | **15%** | **ROTO** | Colapso del ecosistema |
| P06 Miguel | J1(60%), J2(15%), J3(0%), J4(0%), J5(5%), J6(10%), J8(8%) | **14%** | **ROTO** | Colapso del ecosistema |
| P07 Andrea | J1(60%), J5(5%) | **32%** | **ROTO** | Pérdida del embudo superior |
| P08 Diego | J1(60%), J2(15%) | **37%** | **ROTO** | Pérdida del pipeline de rescate |
| P09 María Elena | J1(60%), J3(0%) | **30%** | **ROTO** | Pérdida del pipeline de adopción |
| P10 Roberto | J1(60%), J8(8%) | **34%** | **ROTO** | Pérdida de financiamiento del ecosistema |

**Las 10 personas están en nivel ROTO.** Solo J1 (Registro) funciona parcialmente.

## Capa 4: Lista de Correcciones Priorizadas

### T0: Bloqueadores de Ingresos

| ID | Descripción | Recorrido | Personas | Ingresos en Riesgo | Esfuerzo | Dependencias |
|----|-------------|---------|----------|-----------------|--------|--------------|
| **T0-1** | Crear entidad Animal + migración de BD (coordenadas listas para PostGIS) | J6,J2,J3,J4 | P05,P06 | $3,500/mes | M (días) | Ninguna |
| **T0-2** | Construir gestión de Casa Cuna: registrar hogar temporal, agregar/eliminar animales, capacidad, lista de necesidades para donantes | J6,J8 | P05,P06,P10 | $720/mes | M (días) | T0-1 |
| **T0-3** | Corregir auth: exponer `refreshToken` como mutación GraphQL, conectar interceptor móvil, unificar sistema dual de auth | J1 | TODOS | $200/mes | M (días) | Ninguna |
| **T0-4** | Construir flujo de Solicitud de Subsidio Veterinario: crear solicitud, asignación automática de jurisdicción por GPS, máquina de estados (CREATED->IN_REVIEW->APPROVED->REJECTED->EXPIRED) | J4 | P01-P06 | $3,500/mes | L (semanas) | T0-1, T0-2, T0-9 |
| **T0-5** | Construir panel de Revisión de Subsidios Municipal (web): cola de pendientes, aprobar/rechazar, expiración automática | J4,J7 | P01,P02 | $1,900/mes | L (semanas) | T0-4 |
| **T0-6** | Construir flujo de Reporte de Maltrato: formulario de reporte autenticado con GPS + fotos, código de seguimiento, rastreo de estado | J5 | P01,P02,P07 | $1,425/mes | M (días) | T0-3 |
| **T0-7** | Construir Panel Municipal (web): resumen de KPIs, alcance por jurisdicción, cola de elementos pendientes, independiente | J7 | P01,P02 | $1,900/mes | L (semanas) | T0-5, T0-6 |
| **T0-8** | Construir perfil veterinario + registro de clínica: credenciales, especialidades, ubicación, horario, precios | J9 | P03,P04 | $1,000/mes | M (días) | Ninguna |
| **T0-9** | Implementar PostGIS para consultas de proximidad: mapeo de jurisdicciones, veterinario/rescatista/auxiliar más cercano | J2,J4,J5 | TODOS | $2,000/mes | M (días) | Ninguna |

### T1: Entrega de Valor

| ID | Descripción | Recorrido | Personas | Ingresos en Riesgo | Esfuerzo | Dependencias |
|----|-------------|---------|----------|-----------------|--------|--------------|
| **T1-1** | Construir pipeline de Coordinación de Rescate: alerta del centinela, notificación + aceptación del auxiliar, navegación, transferencia al rescatista | J2 | P05-P08 | $255/mes | L (semanas) | T0-1,T0-2,T0-9 |
| **T1-2** | Construir flujo de Adopción: publicar animal, listados navegables con filtros, solicitud de adopción + evaluación | J3 | P05,P06,P09 | $200/mes | L (semanas) | T0-1,T0-2 |
| **T1-3** | Implementar notificaciones push (Firebase): alertas de rescate, estado de subsidio, mensajes, actualizaciones de maltrato | J2,J4,J5,J10 | TODOS | $500/mes | M (días) | Configuración de Firebase existe |
| **T1-4** | Integrar chat con flujos de trabajo: crear salas automáticamente, vincular al caso, archivar al completar | J10 | TODOS activos | $80/mes | M (días) | Chat parcialmente existe |
| **T1-5** | Construir gestión de pacientes veterinarios: expedientes médicos, historial de tratamientos, seguimiento de medicamentos | J4,J9 | P03,P04 | $300/mes | M (días) | T0-8 |
| **T1-6** | Construir verificación de correo + flujos de restablecimiento de contraseña | J1 | TODOS | $100/mes | S (horas) | T0-3 |
| **T1-7** | Construir facturación veterinaria: envío de factura digital, seguimiento de pago de subsidio | J4 | P03,P04 | $200/mes | M (días) | T0-4,T0-5 |
| **T1-8** | Construir flujo de Donación: persona a persona SINPE/banco, registro de donación (sin intermediación), recurrente, donaciones en especie | J8 | P10,P06 | $92/mes | M (días) | T0-2 |
| **T1-9** | Construir reportes de transparencia: exportación PDF/Excel, rangos de fechas configurables, métricas de impacto | J7 | P01,P02 | $300/mes | M (días) | T0-7 |

### T2: Retención y Crecimiento

| ID | Descripción | Recorrido | Personas | Esfuerzo | Dependencias |
|----|-------------|---------|----------|--------|--------------|
| **T2-1** | Contratos digitales de adopción con firma electrónica | J3 | P05,P06,P09 | M | T1-2 |
| **T2-2** | Notificaciones de seguimiento automatizadas (30/60/90 días post-adopción) | J3 | P05,P06,P09 | S | T1-2,T1-3 |
| **T2-3** | Panel de impacto del donante: animales ayudados, historias, puntaje de transparencia | J8 | P10 | M | T1-8 |
| **T2-4** | Propuestas de mejora basadas en uso para clínicas veterinarias (gratis -> de pago) | J9 | P03 | S | T0-8,T1-5 |
| **T2-5** | Sistema de reputación/calificación para rescatistas, auxiliares, veterinarios | J2,J3,J4 | TODOS | L | T1-1,T1-2 |
| **T2-6** | Modo offline-first para coordinación de rescate en áreas de baja conectividad | J2 | P08 | L | T1-1 |

### Victorias Rápidas (código/configuración existente)

| ID | Qué Hacer | Impacto | Esfuerzo |
|----|-----------|--------|--------|
| **QW-1** | Agregar `@UseGuards(JwtAuthGuard)` a la mutación `createCaptureRequest` | Seguridad: corrección de mutación sin autenticación | Minutos |
| **QW-2** | Agregar FK `userId` a la tabla `capture_requests` | Integridad de datos: rastrear quién reportó | Horas |
| **QW-3** | Exponer el `refreshToken()` existente como mutación GraphQL en `auth.resolver.ts` | Desbloquea renovación de token en móvil | Horas |
| **QW-4** | Eliminar secreto JWT codificado en duro (`'super-secret-altrupets-key-2026'`) | Seguridad: eliminar secreto por defecto | Minutos |
| **QW-5** | Conectar adaptador Redis para caché (URL configurada, adaptador no conectado) | Persistencia de tokens entre reinicios de pods | Horas |

## Secuencia de Implementación

```
FASE 1 -- Fundación (Semanas 1-2): Pistas paralelas
  Pista A: T0-1 -> T0-2 (Entidad Animal + Casa Cuna + lista de necesidades)
  Pista B: T0-3 + QW-1..QW-5 (Reforzamiento de auth + victorias rápidas de seguridad)
  Pista C: T0-8 (Perfil veterinario/registro de clínica)
  Pista D: T0-9 (Configuración de PostGIS)

FASE 2 -- Camino de Ingresos A: Subsidios (Semanas 3-5)
  T0-4 (Flujo de subsidio) -> T0-5 (Panel de revisión municipal)

FASE 3 -- Camino de Ingresos B: Reportes de Maltrato (Semanas 3-4, paralelo con Fase 2)
  T0-6 (Flujo de reporte de maltrato)

FASE 4 -- Panel Municipal (Semanas 5-6)
  T0-7 (Panel combinando datos de subsidios + maltrato, independiente)

FASE 5 -- Entrega de Valor (Semanas 5-8)
  T1-1 (Coordinación de rescate) | T1-2 (Adopción)
  T1-3 (Notificaciones push) | T1-4 (Integración de chat)
  T1-5 (Gestión de pacientes vet.) | T1-6 (Flujos de correo/contraseña)

FASE 6 -- Optimización de Ingresos (Semanas 8-10)
  T1-7 (Facturación vet.) | T1-8 (Donación + flujo en especie) | T1-9 (Reportes)
  T2-4 (Propuestas de mejora vet.) | T2-1 (Contratos de adopción)

FASE 7 -- Retención (Semanas 10-12)
  T2-2, T2-3, T2-5, T2-6
```

### Visual de Dependencias de Fases

```
Fase 1 (Fundación)
  |--- Pista A: T0-1 -> T0-2 ---|
  |--- Pista B: T0-3 + QW-*  ---|---> Fase 2 + Fase 3 (paralelo)
  |--- Pista C: T0-8         ---|       |
  |--- Pista D: T0-9         ---|       v
                                   Fase 4 (Panel)
                                        |
                                        v
                                   Fase 5 (Entrega de Valor)
                                        |
                                        v
                                   Fase 6 (Optimización de Ingresos)
                                        |
                                        v
                                   Fase 7 (Retención)
```
