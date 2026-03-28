# Propuesta: Flujo de Adopcion

**Change ID:** adoption-flow
**SRD Task:** T1-2
**Linear:** ALT-14
**Sprint:** 3 (v0.5.0)
**Fecha:** 2026-03-28

---

## Que

Construir el flujo completo del Ciclo de Vida de Adopcion (J3): desde que un rescatista publica un animal como "Listo para Adopcion" hasta que un adoptante envia solicitud y el rescatista evalua, agenda visita y aprueba o rechaza la adopcion.

## Por que

- **J3 esta al 0% de completitud.** No existe ninguna entidad de adopcion, UI ni backend.
- **$200/mes en riesgo** directamente atribuidos a este journey (gap-audit, Capa 2).
- **Personas bloqueadas:**
  - P05 Sofia (rescatista power user) y P06 Miguel (lider de ONG) no pueden publicar animales listos para adopcion.
  - P09 Maria Elena (adoptante) no tiene forma de descubrir ni solicitar adopcion de animales.
- **Dependencias satisfechas:** T0-1 (Entidad Animal) y T0-2 (Gestion Casa Cuna) estan marcadas como Done.
- **Valor estrategico:** El pipeline de adopcion es el proposito final del ecosistema de rescate. Sin adopcion funcional, los animales se acumulan en casas cuna sin salida, erosionando la propuesta de valor para rescatistas y donantes.

## Alcance

### Incluido (Sprint 3)

1. **Backend — Entidades y logica:**
   - Entidad `AdoptionListing` con estado, fotos, temperamento, requisitos, historial medico vinculado
   - Entidad `AdoptionApplication` con cuestionario del hogar, detalles familiares, maquina de estados
   - Maquina de estados: READY -> LISTED -> APPLIED -> REVIEW -> VISIT -> APPROVED / REJECTED
   - Mutaciones GraphQL: publicar listado, enviar solicitud, revisar, agendar visita, aprobar/rechazar
   - Queries con filtros: especie, tamano, edad, compatible con ninos, ubicacion (PostGIS)

2. **Mobile — Pantallas Flutter:**
   - Galeria de listados navegable con filtros
   - Detalle de animal con fotos, historial, temperamento
   - Formulario de solicitud de adopcion (cuestionario del hogar)
   - Pantalla de revision de solicitudes para rescatista
   - Pantalla de detalle de solicitud con acciones (agendar visita, aprobar, rechazar)

3. **Integracion:**
   - Notificacion push (REQ-NOT-005) cuando un animal coincide con preferencias del adoptante
   - Notificacion al rescatista cuando llega nueva solicitud

### Excluido (Sprints posteriores)

- Contrato digital de adopcion con firma electronica (T2-1, Sprint 5)
- Seguimiento post-adopcion automatizado 30/60/90 dias (T2-2, Sprint 5)
- Sistema de reputacion/calificacion post-adopcion (T2-5, Sprint 5)

## Etiquetas

| Etiqueta | Valor |
|----------|-------|
| Journey | J3 (Ciclo de Vida de Adopcion) |
| Prioridad SRD | Value-Delivery |
| Tamano | L (semanas) |
| Dependencias | T0-1 (Done), T0-2 (Done) |
| Desbloquea | T2-1, T2-2, T2-5 |
| Personas impactadas | P05, P06, P09 |
| Ingresos en riesgo | $200/mes |
| Version objetivo | v0.5.0 |

## Criterios de Aceptacion (del SRD)

- [ ] El rescatista publica animal con fotos e historial medico
- [ ] El adoptante navega y filtra listados
- [ ] El adoptante envia solicitud con cuestionario
- [ ] El rescatista revisa, agenda visita, aprueba/rechaza
