# Reglas de Negocio - AltruPets

Este documento define las reglas de negocio fundamentales que deben implementarse en todos los módulos del sistema AltruPets.

## Reglas de Asociación

### Rescatistas y Casas Cuna
- **REGLA BR-001**: Un rescatista PUEDE tener asociadas múltiples casas cuna
- **REGLA BR-002**: Una casa cuna PUEDE estar asociada a múltiples rescatistas
- **REGLA BR-003**: La asociación rescatista-casa cuna debe ser explícitamente autorizada por ambas partes

## Principio de Responsabilidad Única para Solicitudes

### Tipos de Solicitudes por Rol de Usuario

#### Centinelas Ciudadanos
- **REGLA BR-010**: Los centinelas ciudadanos ÚNICAMENTE pueden enviar "solicitudes de auxilio"
- **REGLA BR-011**: Los centinelas ciudadanos NO pueden enviar informes de ningún tipo
- **REGLA BR-012**: Las solicitudes de auxilio deben incluir geolocalización obligatoria

#### Auxiliares
- **REGLA BR-020**: Los auxiliares ÚNICAMENTE pueden enviar "solicitudes de rescate"
- **REGLA BR-021**: Los auxiliares NO pueden enviar informes de ningún tipo
- **REGLA BR-022**: Las solicitudes de rescate deben referenciar una solicitud de auxilio previa

#### Rescatistas
- **REGLA BR-030**: Los rescatistas ÚNICAMENTE pueden enviar "solicitudes de adopción"
- **REGLA BR-031**: Los rescatistas NO pueden enviar informes de ningún tipo
- **REGLA BR-032**: Las solicitudes de adopción requieren que el animal cumpla todos los requisitos de adoptabilidad

## Autorización Veterinaria Automática

### Generación Automática de Solicitudes
- **REGLA BR-040**: El sistema AUTOMÁTICAMENTE genera una "solicitud de autorización para atención veterinaria" cuando se cumplen los disparadores
- **REGLA BR-041**: Esta solicitud se envía al departamento de bienestar animal del gobierno local correspondiente
- **REGLA BR-042**: El departamento debe asignar un encargado específico para gestionar estas solicitudes

## Atributos de Animales

### Condiciones del Animal (Checkboxes)
- **Discapacitado**: Animal con limitaciones físicas permanentes
- **Paciente Crónico**: Animal que requiere medicación o cuidados continuos
- **Zeropositivo**: Animal con SIDA felino o Leucemia felina
- **Callejero**: Animal sin hogar identificado

### Requisitos para Adoptabilidad (Checkboxes - TODOS deben ser TRUE)
- **REGLA BR-050**: Para que un animal sea adoptable DEBE cumplir TODOS los siguientes requisitos:
  - **Usa arenero**: El animal debe estar entrenado para usar arenero
  - **Come por sí mismo**: El animal debe ser capaz de alimentarse independientemente

### Restricciones de Adoptabilidad (Checkboxes - CUALQUIERA impide adopción)
- **REGLA BR-051**: Un animal NO puede ser adoptable si tiene CUALQUIERA de las siguientes restricciones:
  - **Arizco con humanos**: Comportamiento agresivo o temeroso hacia personas
  - **Arizco con otros animales**: Comportamiento agresivo hacia otros animales
  - **Lactante**: Animal que aún requiere leche materna
  - **Nodriza**: Hembra que está amamantando crías
  - **Enfermo**: Animal con condición médica activa que requiere tratamiento
  - **Herido**: Animal con lesiones físicas que requieren atención
  - **Recién Parida**: Hembra que ha dado a luz recientemente (menos de 8 semanas)
  - **Recién Nacido**: Animal menor a 8 semanas de edad

## Disparadores de Autorización Veterinaria

### Condiciones que Activan Solicitud Automática
- **REGLA BR-060**: Cuando un auxiliar genera una solicitud de rescate, el sistema AUTOMÁTICAMENTE crea una "solicitud de autorización para atención veterinaria" SI el animal tiene CUALQUIERA de las siguientes condiciones:
  - **Callejero**: TRUE
  - **Herido**: TRUE  
  - **Enfermo**: TRUE

### Autorización Gubernamental
- **REGLA BR-070**: El encargado del departamento de bienestar animal del gobierno local SOLAMENTE PODRÁ autorizar una "solicitud de autorización para atención veterinaria" CUANDO se cumplan AMBAS condiciones:
  - **Jurisdicción**: La ubicación de la solicitud de auxilio esté dentro del rango de su jurisdicción territorial
  - **Condición Callejero**: El animal tenga la condición "callejero" = TRUE

## Validaciones del Sistema

### Validaciones de Integridad
- **REGLA BR-080**: El sistema debe validar que no existan conflictos entre requisitos y restricciones
- **REGLA BR-081**: Un animal no puede tener simultáneamente "Come por sí mismo" = TRUE y "Lactante" = TRUE
- **REGLA BR-082**: Un animal "Recién Nacido" automáticamente tiene "Lactante" = TRUE

### Validaciones de Flujo
- **REGLA BR-090**: Una solicitud de rescate no puede proceder si no existe una solicitud de auxilio previa válida
- **REGLA BR-091**: Una solicitud de adopción no puede proceder si el animal no cumple todos los requisitos de adoptabilidad
- **REGLA BR-092**: Una autorización veterinaria no puede otorgarse fuera de la jurisdicción territorial correspondiente

## Implementación Técnica

### Campos de Base de Datos
```typescript
// Condiciones del Animal
interface AnimalConditions {
  discapacitado: boolean;
  pacienteCronico: boolean;
  zeropositivo: boolean;
  callejero: boolean;
}

// Requisitos de Adoptabilidad
interface AdoptabilityRequirements {
  usaArenero: boolean;
  comePorSiMismo: boolean;
}

// Restricciones de Adoptabilidad
interface AdoptabilityRestrictions {
  arizcoConHumanos: boolean;
  arizcoConAnimales: boolean;
  lactante: boolean;
  nodriza: boolean;
  enfermo: boolean;
  herido: boolean;
  recienParida: boolean;
  recienNacido: boolean;
}
```

### Reglas de Negocio como Código
- Todas las reglas deben implementarse como validadores en el backend
- Las reglas deben ser auditables y trazables
- Los cambios en reglas de negocio requieren migración de base de datos
- Las validaciones deben ejecutarse tanto en frontend como backend