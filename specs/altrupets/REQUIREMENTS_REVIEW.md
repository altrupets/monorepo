# Revisión de Requisitos - AltruPets (ACTUALIZADO)

## ✅ Cambios Aplicados

Los requisitos han sido actualizados según la nueva lógica de negocio solicitada.

### 🔄 Cambios Principales

1. **Centinelas** ahora crean → **"Solicitudes de Captura"** (antes "Solicitudes de Auxilio")
2. **Auxiliares** procesan → **"Solicitudes de Captura"** y pueden crear **"Solicitudes de Rescate"** si no tienen casa cuna
3. **Rescatistas** marcan animales como → **"Listo para Adoptar"** (antes creaban "Solicitudes de Adopción")
4. **Adoptantes** envían → **"Solicitudes de Adopción"** que los rescatistas aprueban/rechazan

## 📋 Tipos de Solicitudes del Sistema (ACTUALIZADO)

### 1. Solicitudes de Captura (Centinelas)
**Código:** REQ-CEN-002  
**Quién:** Centinelas  
**Propósito:** Reportar animales vulnerables que necesitan captura inmediata

**Estados del workflow:**
```
CREADA → EN_REVISION → ASIGNADA → EN_PROGRESO → COMPLETADA/RECHAZADA
```

**Atributos obligatorios:**
- Ubicación GPS (precisión ≥10m)
- Descripción del estado del animal
- Fotografías (opcional pero recomendado)
- Nivel de urgencia

### 2. Solicitudes de Rescate (Auxiliares sin casa cuna)
**Código:** REQ-AUX-004  
**Quién:** Auxiliares que capturaron un animal pero no tienen casa cuna propia  
**Propósito:** Buscar rescatista con casa cuna disponible para dar acogida al animal

**Estados del workflow:**
```
CREADA → PENDIENTE_AUTORIZACION → AUTORIZADA → ASIGNADA → 
EN_PROGRESO → RESCATADO → COMPLETADA/RECHAZADA
```

**Regla de negocio crítica:**
> "CUANDO un auxiliar capture un animal Y no tenga casa cuna propia ENTONCES el sistema DEBERÁ permitir crear una solicitud de rescate"

### 3. Animales Listos para Adopción (Rescatistas)
**Código:** REQ-RES-005  
**Quién:** Rescatistas  
**Propósito:** Marcar animales que cumplen requisitos de adoptabilidad

**Proceso:**
1. Rescatista evalúa que el animal cumple todos los requisitos
2. Marca el animal como "Listo para Adoptar" (Ready for Adoption)
3. Sistema publica automáticamente el perfil en catálogo de adopción
4. Adoptantes pueden ver el animal y enviar solicitudes

**Requisitos de adoptabilidad (REQ-BR-050 a REQ-BR-070):**
- ✅ Castrado = TRUE
- ✅ Vacunado = TRUE  
- ✅ Desparasitado = TRUE
- ✅ Socializado = TRUE
- ✅ Edad ≥ 3 meses
- ❌ Enfermo = FALSE
- ❌ Agresivo = FALSE

### 4. Solicitudes de Adopción (Adoptantes)
**Código:** REQ-ADO-003, REQ-RES-005A  
**Quién:** Adoptantes  
**Propósito:** Solicitar adopción de un animal marcado como "Listo para Adoptar"

**Proceso:**
1. Adoptante busca animales en catálogo
2. Selecciona un animal "Listo para Adoptar"
3. Envía solicitud con información personal y motivación
4. **Rescatista** revisa y aprueba/rechaza la solicitud
5. Si aprobada: coordinación de entrega y contrato digital

**Estados:**
```
ENVIADA → EN_REVISION → APROBADA/RECHAZADA → COORDINANDO_ENTREGA → COMPLETADA
```

### 5. Solicitudes de Subvención Municipal Veterinaria
**Código:** REQ-BR-040  
**Quién:** Veterinarios o Rescatistas  
**Propósito:** Solicitar subsidio municipal para gastos veterinarios

**Estados del workflow:**
```
CREADA → EN_REVISION → APROBADA/RECHAZADA/EXPIRADA
```

## 🔄 Flujo Completo del Sistema

```
1. CENTINELA identifica animal vulnerable
   ↓
2. CENTINELA crea "Solicitud de Captura"
   ↓
3. Sistema notifica AUXILIARES cercanos (radio 10km)
   ↓
4. AUXILIAR acepta y procesa la captura
   ↓
5a. Si AUXILIAR tiene casa cuna → Acoge al animal directamente
5b. Si AUXILIAR NO tiene casa cuna → Crea "Solicitud de Rescate"
   ↓
6. RESCATISTA acepta solicitud de rescate y recibe al animal
   ↓
7. RESCATISTA cuida al animal (vacunas, castración, socialización)
   ↓
8. RESCATISTA marca animal como "Listo para Adoptar"
   ↓
9. Sistema publica animal en catálogo de adopción
   ↓
10. ADOPTANTE busca y envía "Solicitud de Adopción"
   ↓
11. RESCATISTA revisa y aprueba/rechaza solicitud
   ↓
12. Si aprobada: Coordinación de entrega y adopción completada
```

## ✅ Alineación UI con Requisitos

La UI actual en `rescues_page.dart` ahora está **CORRECTA** según los requisitos actualizados:

```dart
// ✅ CORRECTO - Alineado con requisitos actualizados
AppServiceCard(
  title: 'Captar a un\nanimal vulnerable',  // ← Ahora CORRECTO
  icon: Icons.directions_car_rounded,
  gradientColors: const [Color(0xFFDC2626), Color(0xFFDC2626)],
  onTap: () => _procesarSolicitudCaptura(context),
),
```

## 📊 Requisitos Actualizados

### Requisitos de Centinelas (Actualizados)
- ✅ REQ-CEN-002: Creación de **Solicitudes de Captura** (antes "Alertas")
- ✅ REQ-CEN-003: Seguimiento de **Solicitudes de Captura**
- ✅ REQ-CEN-004: Comunicación con Auxiliares

### Requisitos de Auxiliares (Actualizados)
- ✅ REQ-AUX-002: Recepción de **Solicitudes de Captura**
- ✅ REQ-AUX-003: Procesamiento de **Solicitudes de Captura**
- ✅ REQ-AUX-004: **Creación de Solicitudes de Rescate** (NUEVO)
- ✅ REQ-AUX-005: Documentación de Captura

### Requisitos de Rescatistas (Actualizados)
- ✅ REQ-RES-005: **Marcado de Animal Listo para Adopción** (NUEVO)
- ✅ REQ-RES-005A: **Gestión de Solicitudes de Adopción Recibidas** (NUEVO)
- ✅ REQ-RES-005B: **Coordinación de Entrega Post-Aprobación** (NUEVO)

### Requisitos de Adoptantes (Actualizados)
- ✅ REQ-ADO-003: **Envío de Solicitud de Adopción** (actualizado)
- ✅ REQ-ADO-004: **Aprobación/Rechazo por Rescatista** (actualizado)

## 📝 Resumen de Cambios

| Concepto Anterior | Concepto Nuevo | Responsable |
|-------------------|----------------|-------------|
| Alertas / Solicitudes de Auxilio | Solicitudes de Captura | Centinelas |
| Auxilio inmediato | Procesamiento de Captura | Auxiliares |
| N/A | Solicitudes de Rescate | Auxiliares (sin casa cuna) |
| Solicitudes de Adopción (creadas por rescatistas) | Animales "Listos para Adoptar" | Rescatistas |
| N/A | Solicitudes de Adopción (enviadas por adoptantes) | Adoptantes |
| N/A | Aprobación/Rechazo de Adopción | Rescatistas |

## 🚀 Próximos Pasos

### Prioridad 1: Implementar Pantalla de Evidencias
1. Usar skill `stitch_to_flutter` con screen ID: `7b75934a54b2464fbe09d07aa7e980b5`
2. Aplicar Atomic Design y Clean Architecture
3. Implementar casos de uso para adjuntar evidencias de captura

### Prioridad 2: Implementar Animal Rescue Service
1. Crear microservicio con estados de workflow actualizados
2. Implementar lógica de "Solicitudes de Captura"
3. Implementar lógica de "Solicitudes de Rescate" por auxiliares
4. Implementar marcado de "Listo para Adoptar" por rescatistas
5. Implementar gestión de "Solicitudes de Adopción" por adoptantes

---

**Última actualización:** Diciembre 2024  
**Revisado por:** Kiro AI Assistant  
**Estado:** ✅ Requisitos actualizados según nueva lógica de negocio
