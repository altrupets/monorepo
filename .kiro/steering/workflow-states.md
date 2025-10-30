# Estados y Flujos de Trabajo - AltruPets

Este documento define los estados y transiciones de los flujos de trabajo principales del sistema.

## Estados de Solicitudes

### Solicitud de Auxilio (Centinelas)
```
CREADA → EN_REVISION → ASIGNADA → EN_PROGRESO → COMPLETADA
                    ↓
                 RECHAZADA
```

**Estados:**
- **CREADA**: Solicitud recién enviada por centinela
- **EN_REVISION**: Siendo evaluada por el sistema/moderadores
- **ASIGNADA**: Asignada a auxiliares en la zona
- **EN_PROGRESO**: Auxiliar ha aceptado y está en camino
- **COMPLETADA**: Auxiliar confirmó la situación
- **RECHAZADA**: Solicitud determinada como falsa o duplicada

### Solicitud de Rescate (Auxiliares)
```
CREADA → AUTORIZADA → ASIGNADA → EN_PROGRESO → RESCATADO → COMPLETADA
       ↓           ↓
   RECHAZADA   PENDIENTE_AUTORIZACION
```

**Estados:**
- **CREADA**: Solicitud enviada por auxiliar
- **PENDIENTE_AUTORIZACION**: Esperando autorización veterinaria gubernamental
- **AUTORIZADA**: Autorización veterinaria aprobada (si aplica)
- **ASIGNADA**: Asignada a rescatista disponible
- **EN_PROGRESO**: Rescatista en camino al lugar
- **RESCATADO**: Animal rescatado exitosamente
- **COMPLETADA**: Animal en casa cuna o cuidado temporal
- **RECHAZADA**: Solicitud rechazada por autoridades o falta de recursos

### Solicitud de Adopción (Rescatistas)
```
CREADA → VALIDADA → PUBLICADA → EN_PROCESO → ADOPTADO
       ↓         ↓
   RECHAZADA  PENDIENTE_REQUISITOS
```

**Estados:**
- **CREADA**: Solicitud enviada por rescatista
- **PENDIENTE_REQUISITOS**: Animal no cumple requisitos de adoptabilidad
- **VALIDADA**: Animal cumple todos los requisitos
- **PUBLICADA**: Disponible para adopción pública
- **EN_PROCESO**: Adoptante potencial en proceso de evaluación
- **ADOPTADO**: Adopción completada exitosamente
- **RECHAZADA**: Animal no apto para adopción

## Estados de Animales

### Ciclo de Vida del Animal en el Sistema
```
REPORTADO → EVALUADO → EN_RESCATE → EN_CUIDADO → ADOPTABLE → ADOPTADO
         ↓          ↓           ↓           ↓
      FALSA_ALARMA  INALCANZABLE  FALLECIDO   NO_ADOPTABLE
```

**Estados:**
- **REPORTADO**: Animal reportado por centinela
- **EVALUADO**: Situación confirmada por auxiliar
- **EN_RESCATE**: Rescate en progreso
- **EN_CUIDADO**: En casa cuna o cuidado temporal
- **ADOPTABLE**: Cumple requisitos para adopción
- **ADOPTADO**: Adoptado exitosamente
- **NO_ADOPTABLE**: No cumple requisitos (permanente)
- **FALLECIDO**: Animal falleció durante el proceso
- **INALCANZABLE**: No se pudo acceder al animal
- **FALSA_ALARMA**: Reporte determinado como falso

## Transiciones Automáticas

### Reglas de Transición Automática

#### Solicitud de Auxilio → Solicitud de Rescate
- **TRIGGER**: Auxiliar confirma situación real
- **CONDICIÓN**: Estado = "COMPLETADA" Y situación confirmada
- **ACCIÓN**: Crear automáticamente solicitud de rescate

#### Solicitud de Rescate → Autorización Veterinaria
- **TRIGGER**: Creación de solicitud de rescate
- **CONDICIÓN**: Animal tiene condiciones: Callejero OR Herido OR Enfermo
- **ACCIÓN**: Crear automáticamente solicitud de autorización veterinaria

#### Animal → Estado Adoptable
- **TRIGGER**: Actualización de atributos del animal
- **CONDICIÓN**: Cumple TODOS los requisitos Y NO tiene restricciones
- **ACCIÓN**: Cambiar estado a "ADOPTABLE" automáticamente

#### Animal → Estado No Adoptable
- **TRIGGER**: Actualización de atributos del animal
- **CONDICIÓN**: Tiene CUALQUIER restricción
- **ACCIÓN**: Cambiar estado a "NO_ADOPTABLE" automáticamente

## Validaciones de Transición

### Validaciones Obligatorias

#### Antes de Cambiar a "ADOPTABLE"
```typescript
function validateAdoptable(animal: Animal): boolean {
  // Verificar requisitos (TODOS deben ser TRUE)
  const requirements = animal.usaArenero && animal.comePorSiMismo;
  
  // Verificar restricciones (NINGUNA debe ser TRUE)
  const restrictions = !animal.arizcoConHumanos && 
                      !animal.arizcoConAnimales && 
                      !animal.lactante && 
                      !animal.nodriza && 
                      !animal.enfermo && 
                      !animal.herido && 
                      !animal.recienParida && 
                      !animal.recienNacido;
  
  return requirements && restrictions;
}
```

#### Antes de Autorizar Atención Veterinaria
```typescript
function validateVeterinaryAuthorization(
  solicitud: SolicitudRescate, 
  encargado: EncargadoBienestar
): boolean {
  // Verificar jurisdicción
  const enJurisdiccion = isWithinJurisdiction(
    solicitud.ubicacion, 
    encargado.jurisdiccion
  );
  
  // Verificar condición callejero
  const esCallejero = solicitud.animal.callejero === true;
  
  return enJurisdiccion && esCallejero;
}
```

## Notificaciones Automáticas

### Eventos que Disparan Notificaciones

#### Solicitud de Auxilio Creada
- **DESTINATARIOS**: Auxiliares en radio de 10km
- **ESCALAMIENTO**: Si no hay respuesta en 30 min, expandir a 25km
- **CONTENIDO**: Ubicación, descripción, fotos

#### Solicitud de Rescate Creada
- **DESTINATARIOS**: Rescatistas disponibles en la zona
- **PRIORIDAD**: Basada en urgencia y condiciones del animal
- **CONTENIDO**: Detalles del animal, ubicación, contacto auxiliar

#### Autorización Veterinaria Requerida
- **DESTINATARIOS**: Encargado de bienestar animal jurisdiccional
- **URGENCIA**: Alta si animal herido o enfermo
- **CONTENIDO**: Detalles del caso, ubicación, justificación

#### Animal Disponible para Adopción
- **DESTINATARIOS**: Adoptantes registrados con preferencias coincidentes
- **FILTROS**: Basado en perfil de adoptante y características del animal
- **CONTENIDO**: Fotos, descripción, requisitos especiales

## Métricas y KPIs

### Métricas de Flujo
- **Tiempo promedio**: Auxilio → Rescate → Adopción
- **Tasa de conversión**: Auxilios confirmados / Auxilios reportados
- **Tasa de éxito**: Rescates exitosos / Solicitudes de rescate
- **Tiempo de respuesta**: Promedio de respuesta a solicitudes de auxilio

### Alertas del Sistema
- **Solicitudes sin respuesta**: > 2 horas
- **Animales en cuidado prolongado**: > 90 días
- **Capacidad de casas cuna**: > 80% ocupación
- **Autorizaciones veterinarias pendientes**: > 24 horas