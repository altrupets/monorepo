# Marco SRD — AltruPets

**Producto**: AltruPets — Plataforma Nativa en la Nube para la Coordinación del Bienestar Animal en LATAM
**Objetivo**: $10,000 MRR (~$120,000 ARR)
**Generado**: 2026-03-03
**Método**: SRD Assess (Diálogo Guiado)

---

## Tabla de Contenidos

1. [Realidad del Éxito](#1-realidad-del-éxito)
2. [Personas Sintéticas](#2-personas-sintéticas)
3. [Recorridos Críticos](#3-recorridos-críticos)
4. [Matriz de Auditoría de Brechas](#4-matriz-de-auditoría-de-brechas)
5. [Directiva Claude](#5-directiva-claude)

---

## 1. Realidad del Éxito

**Cronograma**: 6 meses desde el lanzamiento del MVP | **Geografía**: Costa Rica + 1-2 países de LATAM

### KPIs de la Plataforma

| Métrica | Objetivo |
|--------|--------|
| MRR | $10,000 |
| ARR | $120,000 |
| Usuarios registrados | ~5,000 |
| MAU | ~2,500 (50%) |
| Municipalidades de pago | 10 |
| Clínicas veterinarias de pago | 25 |
| Volumen mensual de donaciones (P2P) | $25,000 |
| Volumen mensual de subsidios | $50,000 |
| Abandono municipal | ~2% (contratos anuales) |
| Abandono de clínicas veterinarias | ~8%/mes |
| NPS | 40+ |

### Desglose de Ingresos

| Fuente | MRR | % | Economía Unitaria |
|--------|-----|---|----------------|
| Contratos Municipales B2G | $7,500 | 75% | 10 municipalidades x $750/mes prom. |
| Suscripciones de Clínicas Veterinarias | $2,000 | 20% | 25 clínicas x $80/mes prom. |
| Funciones Premium | $500 | 5% | Analítica, acceso API, soporte prioritario |

### Niveles de Contratos Municipales

- **Pequeño** (<50K hab.): $500/mes — flujo de subsidios + reportes básicos
- **Mediano** (50-200K hab.): $800/mes — panel completo + reportes de maltrato + analítica
- **Grande** (>200K hab.): $1,500/mes — multi-departamento + API + soporte prioritario

### Niveles de Clínicas Veterinarias

- **Gratis**: Listado en directorio, recibir solicitudes de subsidio
- **Estándar** ($50/mes): Gestión de pacientes, facturación de subsidios, analítica
- **Premium** ($100/mes): Posicionamiento preferente, múltiples ubicaciones, procesamiento prioritario

### Decisión Regulatoria

AltruPets es una **plataforma de coordinación**, NO un intermediario financiero. Las donaciones fluyen de persona a persona (donante -> organización). Los pagos de subsidios veterinarios fluyen de gobierno -> clínica. AltruPets facilita y registra pero NUNCA retiene fondos. Esto evita la supervisión de SUGEF (Ley 7786, Arts. 15/15 bis).

### Atribución de Conversión

| Disparador | % |
|---------|---|
| Demo municipal (subsidios + flujo de maltrato) | 45% |
| Boca a boca / efectos de red | 25% |
| Umbral de volumen de clínica veterinaria | 15% |
| Presión de cumplimiento regulatorio | 15% |

### Volumen de Actividad en el Objetivo

| Métrica | Mensual |
|--------|---------|
| Casos activos de rescate | ~200 |
| Animales en casa cuna | ~500 |
| Reportes de maltrato (autenticados) | ~300 |
| Solicitudes de subsidio veterinario | ~150 |
| Listados de adopción | ~100 |
| Adopciones exitosas | ~60 |
| Entregas de donaciones en especie | ~100 |

---

## 2. Personas Sintéticas

### Tabla Resumen

| ID | Nombre | Arquetipo | % Usuarios | % Ingresos | Compromiso | Ingresos | Viralidad |
|----|------|-----------|--------|-----------|------------|---------|----------|
| P01 | Gabriela | Tomadora de Decisiones B2G | 1% | 75% | 6 | 10 | 8 |
| P02 | Laura | Operadora Diaria B2G | 2% | 0% | 9 | 1 | 3 |
| P03 | Dr. Carlos | Clínica Veterinaria (Pagador) | 3% | 18% | 7 | 8 | 5 |
| P04 | Dra. Priscilla | Colaboradora Veterinaria | 3% | 2% | 8 | 2 | 4 |
| P05 | Sofía | Usuaria Avanzada / Rescatista | 5% | 0% | 10 | 1 | 9 |
| P06 | Miguel | Líder de ONG | 3% | 3% | 9 | 2 | 10 |
| P07 | Andrea | Centinela Casual | 40% | 0% | 3 | 0 | 6 |
| P08 | Diego | Auxiliar Activo | 8% | 0% | 7 | 0 | 5 |
| P09 | María Elena | Buscadora de Adopción | 20% | 0% | 4 | 0 | 7 |
| P10 | Roberto | Donante Mensual | 15% | 0% | 4 | 1 | 6 |
| | | **Totales** | **100%** | **100%** | | | |

### Dinámicas del Ecosistema

**Anclas de ingresos**: P01 (Gabriela) + P03 (Dr. Carlos) = 93% de los ingresos

**Cadena de vulnerabilidad**: Si P05 (Sofía) y P06 (Miguel) abandonan -> no hay casas cuna -> no hay animales -> no hay adopciones -> no hay solicitudes de subsidio -> P01 y P03 no ven valor -> los ingresos colapsan. **Los rescatistas son el oxígeno de la plataforma aunque paguen $0.**

**Detalles completos de personas**: Ver `srd/personas.yml`

---

## 3. Recorridos Críticos

### Resumen de Puntuación

| ID | Recorrido | Puntuación | Ingresos en Riesgo |
|----|---------|-------|-----------------|
| J1 | Registro/Incorporación | **60%** | $200/mes |
| J2 | Coordinación de Rescate | **15%** | $255/mes |
| J3 | Ciclo de Vida de Adopción | **0%** | $200/mes |
| J4 | Solicitud y Aprobación de Subsidio Veterinario | **0%** | $3,500/mes |
| J5 | Reporte de Maltrato (Autenticado) | **5%** | $1,425/mes |
| J6 | Casa Cuna y Gestión Animal | **10%** | $720/mes |
| J7 | Panel Municipal | **5%** | $1,900/mes |
| J8 | Donación e Impacto | **8%** | $92/mes |
| J9 | Incorporación Veterinaria -> Premium | **0%** | $1,000/mes |
| J10 | Chat y Notificaciones | **20%** | $80/mes |

### Grafo de Dependencias

```
J1 (Registro) <- RAÍZ
  +-- J6 (Casa Cuna) <- J1
  |     +-- J3 (Adopción) <- J1 + J6
  |     +-- J4 (Subsidio) <- J1 + J6 + J9
  |     +-- J8 (Donación) <- J1 + J6
  +-- J2 (Rescate) <- J1 + J6 + J10
  +-- J5 (Maltrato) <- J1 (autenticación requerida, INDEPENDIENTE de J2)
  +-- J7 (Panel) <- J1, INDEPENDIENTE
  +-- J9 (Veterinario) <- J1, alimenta J4
  +-- J10 (Chat) <- J1, mejora J2/J3/J4
```

**Caminos paralelos hacia ingresos B2G:**
- Camino A: J1 -> J6 + J9 -> J4 (subsidios)
- Camino B: J1 -> J5 (reportes de maltrato)
- Camino C: J1 -> J7 (panel, siempre activo)

**Detalles completos de recorridos**: Ver `srd/journeys.md`

---

## 4. Matriz de Auditoría de Brechas

### Impacto Persona x Recorrido

```
         J1   J2   J3   J4   J5   J6   J7   J8   J9   J10
P01 Gab  X    -    -    $    $    -    $    -    -    -
P02 Lau  X    -    -    X    X    -    X    -    -    -
P03 Car  X    -    -    $    -    -    -    -    $    -
P04 Pri  X    -    -    X    -    -    -    -    X    -
P05 Sof  X    $    $    X    -    $    -    X    -    X
P06 Mig  X    $    $    X    X    $    -    X    -    X
P07 And  X    -    -    -    X    -    -    -    -    -
P08 Die  X    X    -    -    -    -    -    -    -    X
P09 Mar  X    -    $    -    -    -    -    -    -    -
P10 Rob  X    -    -    -    -    -    -    $    -    -
```

### Ingresos en Riesgo (ordenados)

| Recorrido | Ingresos en Riesgo |
|---------|-----------------|
| J4 Subsidio Veterinario | $3,500/mes |
| J7 Panel | $1,900/mes |
| J5 Reportes de Maltrato | $1,425/mes |
| J9 Incorporación Veterinaria | $1,000/mes |
| J6 Casa Cuna | $720/mes |
| J2 Rescate | $255/mes |
| J1 Registro | $200/mes |
| J3 Adopción | $200/mes |
| J8 Donación | $92/mes |
| J10 Chat | $80/mes |
| **Total** | **$9,372/mes (93.7%)** |

### Todas las Personas: Nivel ROTO

Las 10 personas tienen puntuaciones de viabilidad por debajo del 40%. Solo J1 (Registro) funciona parcialmente.

### Secuencia de Implementación

```
Fase 1 (Semanas 1-2): Fundación — pistas paralelas
  A: Entidad Animal + Casa Cuna (T0-1, T0-2)
  B: Reforzamiento de auth + victorias rápidas (T0-3, QW-1..5)
  C: Perfil/clínica veterinaria (T0-8)
  D: PostGIS (T0-9)

Fase 2 (Semanas 3-5): Camino de Ingresos A — Subsidios
  T0-4 -> T0-5 -> T0-7

Fase 3 (Semanas 3-4): Camino de Ingresos B — Reportes de Maltrato (paralelo)
  T0-6

Fase 4 (Semanas 5-6): Panel Municipal
  T0-7 (combina datos de subsidios + maltrato)

Fase 5 (Semanas 5-8): Entrega de Valor
  T1-1 hasta T1-6

Fase 6 (Semanas 8-10): Optimización de Ingresos
  T1-7 hasta T1-9, T2-1, T2-4

Fase 7 (Semanas 10-12): Retención
  T2-2, T2-3, T2-5, T2-6
```

**Detalles completos de la auditoría de brechas**: Ver `srd/gap-audit.md`

---

## 5. Directiva Claude

### Estrella Polar

> ¿Puede un rescatista enviar una solicitud de subsidio veterinario, que se enrute automáticamente a la municipalidad correcta, sea aprobada, Y la municipalidad pueda verla en su panel?

### Reglas de Prioridad (ordenadas)

1. **Caminos de ingresos B2G primero** — subsidios (J4) y reportes de maltrato (J5) antes que todo lo demás
2. **Los animales deben existir** — La entidad Animal + Casa Cuna (J6) es la fundación
3. **La autenticación debe ser sólida** — renovación de tokens, correcciones de seguridad son bloqueadores silenciosos
4. **Las clínicas veterinarias son el segundo ingreso** — la UX veterinaria habilita el 20% de los ingresos
5. **Nunca intermediar fondos** — Cumplimiento SUGEF, solo persona a persona
6. **Coordinación de rescate != ingresos** — J2 es entrega de valor, no bloquear ingresos por ello
7. **El panel siempre está activo** — mostrar los datos que existan, nunca vacío
8. **Los rescatistas pagan $0 por siempre** — son creadores de valor, no ingresos
9. **Los reportes de maltrato requieren autenticación** — responsabilidad sobre anonimato
10. **Las donaciones en especie son de primera clase** — comida, medicina, juguetes junto con efectivo

### Anti-Patrones

1. No construir el pipeline de rescate antes de los subsidios
2. No enrutar donaciones a través de AltruPets (SUGEF)
3. No priorizar funciones de rescatistas sobre funciones municipales
4. No descomponer en microservicios antes de que el monolito MVP funcione
5. No sobre-diseñar RBAC antes de que existan los flujos de trabajo
6. No construir chat antes de notificaciones push
7. No permitir reportes de maltrato anónimos
8. No cobrar a organizaciones de rescate

### Top 5 Prioridades

| # | Tarea | Ingresos en Riesgo | Esfuerzo |
|---|------|-----------------|--------|
| 1 | Entidad Animal + gestión de Casa Cuna | $3,500/mes | M (días) |
| 2 | Flujo de subsidio veterinario + revisión municipal | $5,400/mes | L (semanas) |
| 3 | Flujo de reporte de maltrato | $1,425/mes | M (días) |
| 4 | Reforzamiento de auth + victorias rápidas de seguridad | $200/mes + indirecto | M (días) |
| 5 | Perfil/clínica veterinaria + PostGIS | $1,000/mes | M (días) |

**Directiva completa**: Ver `srd/claude-directive.yml`
