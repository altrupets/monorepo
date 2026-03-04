# Sprint 5 (v0.7.0): Retención

> **Tipo:** `Feature`
> **Tamaño:** `L`
> **Estrategia:** `Team`
> **Componentes:** `Backend`, `Frontend`
> **Impacto:** `—`
> **Banderas:** `🚫 Bloqueado`
> **Rama:** `feat/sprint-5-retention`
> **Fuente de Spec:** `specs/altrupets/tasks.md` (sección Sprint 5)
> **Estado:** `Bloqueado`
> **Dependencias:** `Sprint 3 (Adopciones) + Sprint 4 (Donaciones, Gestión Vet)`
> **Proyecto Linear:** `Backend` + `Mobile App`

---

## ⚠️ BLOQUEADORES

| Bloqueador | Requerido Para | Sprint |
|---------|-------------|--------|
| T1-2 Flujo de adopción | AD4, AD5 (contratos de adopción, seguimiento) | Sprint 3 |
| T1-8 Flujo de donación | DON1 (panel de impacto del donante) | Sprint 4 |
| T0-8 + T1-5 Perfil vet + gestión de pacientes | VET1 (prompts de upgrade) | Sprint 1 + 4 |
| T1-1 Coordinación de rescate | Tarea 27 (calificaciones post-rescate) | Sprint 3 |

---

## 👤 CAPA HUMANA

### Historia de Usuario

Como **operador de plataforma**, quiero **funcionalidades de retención (contratos, seguimientos, paneles de impacto, calificaciones, prompts de upgrade)** para que **los usuarios se mantengan comprometidos después de su primera interacción y las clínicas veterinarias se conviertan a planes de pago**.

### Contexto / Por Qué

El Sprint 5 se enfoca en reducir la deserción y aumentar el compromiso. Los contratos de adopción digitales (AD4) agregan validez legal. Los seguimientos automatizados (AD5) mantienen conectados a los adoptantes. Los paneles de impacto del donante (DON1) muestran resultados tangibles. Los prompts de upgrade veterinario (VET1) convierten clínicas gratuitas a suscripciones de pago ($80/mes promedio). Las calificaciones (27-28) crean señales de confianza y calidad.

Estas funcionalidades no generan nuevos ingresos directamente pero previenen la pérdida de usuarios e ingresos existentes. El SRD clasifica estas como Fase 7 (Retención).

### Riesgos y Consideraciones Conocidas

1. **Validez legal de la firma electrónica:** Costa Rica reconoce las firmas digitales bajo la Ley 8454. Sin embargo, el enfoque más simple para el MVP es una confirmación de "tocar para firmar" con registro de IP/timestamp, no PKI completa.
2. **Fraude en calificaciones:** Con una base de usuarios pequeña, un solo actor malicioso puede sesgar significativamente las calificaciones. La expiración a 3 meses y la detección de patrones mitigan esto.
3. **Conversión de upgrade veterinario:** El disparador de >5 subsidios/mes necesita lógica de conteo precisa. Caso borde: subsidios que abarcan límites de mes.

---

## 🤖 CAPA DE AGENTE

### Objetivo

Construir funcionalidades de retención: contratos de adopción digital con firma electrónica, seguimientos post-adopción automatizados, panel de impacto del donante, prompts de upgrade para clínicas veterinarias, y sistema de calificación/reputación.

### Auditoría del Estado Actual

Todas las tareas del Sprint 5 están en **NO_INICIADAS**. No existen entidades, servicios o componentes de UI para ninguna de estas funcionalidades.

### Criterios de Aceptación

- [ ] AD4: Contrato de adopción digital generado como PDF con confirmación de tocar para firmar
- [ ] AD5: Notificaciones push automatizadas a los 30/60/90 días post-adopción
- [ ] DON1: Panel del donante muestra total donado, animales ayudados, puntaje de transparencia de la organización
- [ ] VET1: Prompt mostrado cuando la clínica procesa >5 subsidios/mes
- [ ] 27: Calificación post-rescate/adopción/vet con expiración a 3 meses y detección de fraude
- [ ] 28: Puntaje de reputación visible en el perfil, influye en la prioridad de emparejamiento

### Estrategia del Agente

**Modo:** `Team`

**Compañeros de equipo:**
- Compañero 1: **Extensiones de Adopción** → AD4 (contratos), AD5 (seguimientos)
- Compañero 2: **Ingresos + Compromiso** → DON1 (panel de impacto), VET1 (prompts de upgrade), 27-28 (calificaciones)

---

## 🔀 Recomendación de Paralelización

**Mecanismo recomendado:** `Agent Teams` (2 compañeros)

**Estimación de costo:** ~2x costo base de tokens

---

## Recomendaciones de Issues en Linear

### Issue 1: Contratos de Adopción Digital + Seguimiento
**Título:** Construir contratos de adopción digital con firma electrónica y seguimientos automatizados 30/60/90
**Proyecto:** Backend + Mobile App
**Prioridad:** Medium
**Etiquetas:** Feature, M, Team, Backend, Frontend

### Issue 2: Panel de Impacto del Donante
**Título:** Construir panel de impacto del donante con puntajes de transparencia
**Proyecto:** Backend + Mobile App
**Prioridad:** Medium
**Etiquetas:** Feature, S, Solo, Backend, Frontend

### Issue 3: Prompts de Upgrade Veterinario
**Título:** Implementar prompts de upgrade basados en uso para clínicas veterinarias
**Proyecto:** Backend + Mobile App
**Prioridad:** Medium
**Etiquetas:** Feature, S, Solo, Backend, Frontend, 💰 Revenue

### Issue 4: Sistema de Calificación y Reputación
**Título:** Construir sistema de calificación con detección de fraude y visualización de reputación
**Proyecto:** Backend + Mobile App
**Prioridad:** Medium
**Etiquetas:** Feature, M, Solo, Backend, Frontend

---

## Resumen de Archivos Afectados

| Acción | Ruta | Líneas Cambiadas (est.) |
|--------|------|---------------------|
| Crear | `apps/backend/src/contracts/` (4 archivos) | ~250 |
| Crear | `apps/backend/src/follow-ups/` (3 archivos) | ~150 |
| Crear | `apps/backend/src/donor-impact/` (3 archivos) | ~200 |
| Crear | `apps/backend/src/ratings/` (5 archivos) | ~350 |
| Crear | `apps/backend/src/migrations/` (3 archivos) | ~100 |
| Crear | `apps/mobile/lib/features/donations/` extensiones | ~200 |
| Crear | `apps/mobile/lib/features/ratings/` (4 archivos) | ~300 |

---

### Comentarios Adicionales de Síntesis

#### Pareto 80/20
* VET1 (prompts de upgrade) es el ítem de mayor ROI — un simple contador + modal que convierte clínicas gratuitas a $80/mes.
* El sistema de calificación (27-28) es el más complejo pero proporciona valor compuesto ya que mejora la calidad del emparejamiento con el tiempo.

#### Pensamiento de Segundo Orden
* La firma electrónica introduce responsabilidad legal. Asegurar que la plantilla del contrato sea revisada por un abogado costarricense antes del despliegue.
* Los puntajes de reputación afectan la prioridad de emparejamiento — un puntaje sesgado o manipulado podría llevar a problemas de bienestar animal. Considerar supervisión humana para rescatistas con baja calificación.
