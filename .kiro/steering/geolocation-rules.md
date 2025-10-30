# Reglas de Geolocalización y Jurisdicciones - AltruPets

Este documento define las reglas específicas para manejo de ubicaciones, proximidad y jurisdicciones gubernamentales.

## Reglas de Proximidad

### Búsqueda de Auxiliares
- **REGLA GEO-001**: Radio inicial de búsqueda: 10 km desde el punto de auxilio
- **REGLA GEO-002**: Si no hay respuesta en 30 minutos, expandir automáticamente a 25 km
- **REGLA GEO-003**: Si no hay respuesta en 60 minutos, expandir a 50 km y alertar supervisores
- **REGLA GEO-004**: Máximo radio de búsqueda: 100 km (nivel nacional)

### Búsqueda de Rescatistas
- **REGLA GEO-010**: Radio inicial de búsqueda: 15 km desde el punto de rescate
- **REGLA GEO-011**: Priorizar rescatistas con casas cuna disponibles en radio de 25 km
- **REGLA GEO-012**: Considerar capacidad de transporte del rescatista para distancias > 30 km

### Búsqueda de Veterinarios
- **REGLA GEO-020**: Radio de búsqueda para emergencias: 20 km
- **REGLA GEO-021**: Radio de búsqueda para consultas rutinarias: 50 km
- **REGLA GEO-022**: Priorizar veterinarios con tarifas preferenciales para rescate

## Jurisdicciones Gubernamentales

### Definición de Jurisdicciones
- **REGLA JUR-001**: Cada gobierno local define su jurisdicción mediante polígonos geográficos
- **REGLA JUR-002**: Las jurisdicciones pueden solaparse para casos fronterizos
- **REGLA JUR-003**: En caso de solapamiento, se notifica a ambas jurisdicciones

### Autorización Veterinaria por Jurisdicción
- **REGLA JUR-010**: Solo encargados de la jurisdicción correspondiente pueden autorizar atención veterinaria
- **REGLA JUR-011**: La jurisdicción se determina por la ubicación exacta del animal reportado
- **REGLA JUR-012**: Si el animal está en zona fronteriza, se requiere autorización de ambas jurisdicciones

### Casos Especiales de Jurisdicción
- **REGLA JUR-020**: Animales en carreteras nacionales: jurisdicción del cantón más cercano
- **REGLA JUR-021**: Animales en propiedades privadas: requiere autorización adicional del propietario
- **REGLA JUR-022**: Animales en zonas protegidas: requiere autorización de SINAC además de gobierno local

## Validación de Ubicaciones

### Precisión Requerida
- **REGLA VAL-001**: Precisión mínima GPS: 10 metros para solicitudes de auxilio
- **REGLA VAL-002**: Precisión mínima GPS: 5 metros para confirmación de rescate
- **REGLA VAL-003**: Si no hay GPS disponible, permitir ubicación manual con confirmación posterior

### Validación de Coordenadas
- **REGLA VAL-010**: Coordenadas deben estar dentro del territorio de Costa Rica
- **REGLA VAL-011**: Rechazar coordenadas en océano (excepto islas habitadas)
- **REGLA VAL-012**: Validar que las coordenadas correspondan a la dirección proporcionada

## Algoritmos de Asignación

### Priorización de Auxiliares
```typescript
interface AuxiliarScore {
  distancia: number;        // Peso: 40%
  reputacion: number;       // Peso: 30%
  disponibilidad: number;   // Peso: 20%
  experiencia: number;      // Peso: 10%
}

function calcularPrioridadAuxiliar(auxiliar: Auxiliar, solicitud: SolicitudAuxilio): number {
  const distancia = calcularDistancia(auxiliar.ubicacion, solicitud.ubicacion);
  const scoreDistancia = Math.max(0, 100 - (distancia / 1000)); // 1km = 1 punto menos
  
  const scoreReputacion = auxiliar.reputacion * 20; // 0-5 estrellas * 20
  const scoreDisponibilidad = auxiliar.disponible ? 100 : 0;
  const scoreExperiencia = Math.min(100, auxiliar.rescatesCompletados * 2);
  
  return (scoreDistancia * 0.4) + 
         (scoreReputacion * 0.3) + 
         (scoreDisponibilidad * 0.2) + 
         (scoreExperiencia * 0.1);
}
```

### Priorización de Rescatistas
```typescript
interface RescatistaScore {
  distancia: number;           // Peso: 30%
  capacidadCasaCuna: number;   // Peso: 25%
  reputacion: number;          // Peso: 25%
  especializacion: number;     // Peso: 20%
}

function calcularPrioridadRescatista(rescatista: Rescatista, solicitud: SolicitudRescate): number {
  const distancia = calcularDistancia(rescatista.ubicacion, solicitud.ubicacion);
  const scoreDistancia = Math.max(0, 100 - (distancia / 1000));
  
  const capacidadDisponible = rescatista.casasCuna.reduce((total, casa) => 
    total + (casa.capacidadMaxima - casa.animalesActuales), 0);
  const scoreCapacidad = Math.min(100, capacidadDisponible * 10);
  
  const scoreReputacion = rescatista.reputacion * 20;
  
  const tieneEspecializacion = rescatista.especializaciones.some(esp => 
    solicitud.animal.condiciones.includes(esp));
  const scoreEspecializacion = tieneEspecializacion ? 100 : 50;
  
  return (scoreDistancia * 0.3) + 
         (scoreCapacidad * 0.25) + 
         (scoreReputacion * 0.25) + 
         (scoreEspecializacion * 0.2);
}
```

## Funcionalidad Offline

### Almacenamiento Local de Ubicaciones
- **REGLA OFF-001**: Cachear ubicaciones de auxiliares/rescatistas activos en radio de 50km
- **REGLA OFF-002**: Sincronizar ubicaciones cada 5 minutos cuando hay conexión
- **REGLA OFF-003**: Permitir reportes offline con sincronización posterior

### Geofencing
- **REGLA GEO-030**: Crear geofences automáticos alrededor de:
  - Casas cuna registradas (radio 1km)
  - Clínicas veterinarias (radio 2km)
  - Oficinas gubernamentales (radio 5km)
- **REGLA GEO-031**: Notificar cuando auxiliares/rescatistas entren en geofences relevantes
- **REGLA GEO-032**: Activar modo "disponible automáticamente" en geofences de casa cuna

## Integración con Mapas

### Proveedores de Mapas
- **Primario**: Google Maps (para precisión en Costa Rica)
- **Secundario**: OpenStreetMap (para funcionalidad offline)
- **Terciario**: Mapbox (para visualizaciones personalizadas)

### Capas de Información
- **Capa Base**: Mapa estándar con calles y puntos de referencia
- **Capa Jurisdicciones**: Polígonos de jurisdicciones gubernamentales
- **Capa Recursos**: Ubicación de casas cuna, veterinarias, refugios
- **Capa Actividad**: Solicitudes activas, rescates en progreso
- **Capa Heatmap**: Densidad de reportes por zona (análisis)

## Privacidad y Seguridad

### Protección de Ubicaciones
- **REGLA PRIV-001**: Ubicaciones exactas solo visibles para usuarios involucrados en el caso
- **REGLA PRIV-002**: Mostrar ubicaciones aproximadas (radio 500m) para otros usuarios
- **REGLA PRIV-003**: Histórico de ubicaciones se elimina después de 90 días
- **REGLA PRIV-004**: Ubicaciones de casas cuna privadas requieren autorización para mostrar

### Anonimización
- **REGLA PRIV-010**: Reportes anónimos no almacenan ubicación del reportante
- **REGLA PRIV-011**: Solo almacenar ubicación del incidente reportado
- **REGLA PRIV-012**: Permitir reportes con ubicación aproximada para casos sensibles