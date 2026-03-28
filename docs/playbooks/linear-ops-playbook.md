---
marp: true
theme: uncover
paginate: true
style: |
  @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap');

  :root {
    --color-primary: #094F72;
    --color-secondary: #EA840B;
    --color-accent: #1370A6;
    --color-warning: #F4AE22;
    --color-error: #E54C12;
    --color-success: #2E7D32;
    --color-primary-90: #C9E6FF;
    --color-primary-20: #00344E;
    --color-secondary-90: #FFDCC2;
    --color-neutral-10: #191C1E;
    --color-neutral-90: #E2E2E5;
    --color-neutral-95: #F0F0F3;
  }

  section {
    font-family: 'Poppins', sans-serif;
    background: var(--color-neutral-95);
    color: var(--color-neutral-10);
  }

  section.lead {
    background: var(--color-primary);
    color: white;
    text-align: center;
  }

  section.lead h1 {
    color: var(--color-secondary);
    font-size: 2.5em;
    font-weight: 700;
  }

  section.lead h2 {
    color: var(--color-primary-90);
    font-weight: 300;
    font-size: 1.2em;
  }

  section.chapter {
    background: var(--color-primary-20);
    color: white;
    text-align: center;
    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  section.chapter h1 {
    color: var(--color-secondary);
    font-size: 3em;
    margin-bottom: 0;
  }

  section.chapter h2 {
    color: var(--color-primary-90);
    font-weight: 300;
    font-size: 1.1em;
  }

  h1 {
    color: var(--color-primary);
    font-weight: 700;
  }

  h2 {
    color: var(--color-accent);
    font-weight: 600;
    font-size: 1.1em;
  }

  strong {
    color: var(--color-secondary);
  }

  table {
    font-size: 0.7em;
    font-family: 'Inter', sans-serif;
  }

  th {
    background: var(--color-primary);
    color: white;
  }

  code {
    background: var(--color-primary-90);
    color: var(--color-primary-20);
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 0.85em;
  }

  .columns {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1.5em;
  }

  .highlight {
    background: var(--color-secondary);
    color: white;
    padding: 4px 12px;
    border-radius: 6px;
    font-weight: 600;
  }

  blockquote {
    border-left: 4px solid var(--color-secondary);
    padding-left: 1em;
    font-style: italic;
    color: var(--color-accent);
  }

  footer {
    font-family: 'Inter', sans-serif;
    color: var(--color-accent);
    font-size: 0.6em;
  }
---

<!-- _class: lead -->

# Linear Ops Playbook

## Como AltruPets organiza su workspace
Para Ingenieria -- Operaciones -- Todos los equipos
Marzo 2026 -- v2.0

---

# Que vamos a cubrir

| # | Tema | Detalle |
|---|------|---------|
| 01 | **Arquitectura del Workspace** | Team ALT, 8 proyectos, y como se conecta todo |
| 02 | **Sistema de Labels** | La taxonomia de 31 labels y como usarla |
| 03 | **Guia de Creacion de Issues** | El template bilingue para humanos + agentes IA |
| 04 | **OpenSpec Workflow** | Spec library, changes, y el flujo proposal-to-code |
| 05 | **Desarrollo AI-First** | Estrategias de agentes, context budgets, paralelizacion |
| 06 | **Gobernanza y Rituales** | Triage, auditorias semanales, y reglas del juego |

---

<!-- _class: chapter -->

# 01

## Arquitectura del Workspace
1 team -- 8 proyectos -- Un workspace unificado

---

# Team AltruPets (ALT)

Un solo team con 8 proyectos que cubren todo el stack:

| Proyecto | Key | Foco |
|----------|-----|------|
| **Backend API** | ALT | NestJS, GraphQL, TypeORM, PostgreSQL |
| **Mobile App** | ALT | Flutter, Riverpod, Clean Architecture |
| **Agent AI** | ALT | agentic-core sidecar, LangGraph, FalkorDB |
| **Infrastructure & DevOps** | ALT | K8s, Terraform, ArgoCD, CI/CD |
| **Web -- B2G** | ALT | Vue 3 panel gubernamental |
| **Web -- CRUD Superusers** | ALT | Vue 3 panel admin |
| **Diseno y Control Calidad** | ALT | UX/UI, QA |
| **Operaciones** | ALT | Admin, legal, partnerships |

---

# Ciclo de Vida de un Issue

Cada issue fluye por estos estados. Linear los trackea nativamente -- no se necesitan labels.

**Backlog** --> **Todo** --> **In Progress** --> **In Review** --> **Done**

Y tambien: **Canceled** (documentar por que) + **Duplicate** (linkear original)

## Niveles de Prioridad (built-in)

| Nivel | Cuando usarlo |
|-------|--------------|
| **Urgent** | Produccion caida, breach de SLA. Max 5-7 en todo el workspace. |
| **High** | Importante para el ciclo actual. Impacto en revenue o estrategia. |
| **Medium** | Debe hacerse pero no rompe nada si se atrasa un ciclo. |
| **Low** | Nice to have. Llenar gaps de sprint. |

---

<!-- _class: chapter -->

# 02

## El Sistema de Labels
31 labels organizados en grupos y categorias

---

# Principios de Diseno de Labels

- **Labels agregan lo que Linear no tiene** -- Linear ya tiene Priority, Status, Estimates, Projects, Cycles. Labels agregan: Type, Component, Business Impact, y AI Strategy.

- **Grupos = mutuamente exclusivos** -- Label Groups fuerzan UN label por grupo por issue. Un issue es UN tipo, UN tamano, UNA estrategia.

- **Sin grupo = combinables** -- Labels de Component pueden superponerse (Frontend + Security + Testing).

- **Cada label tiene descripcion** -- Las descripciones definen CUANDO y CUANDO NO usar cada label.

- **A nivel de workspace** -- Los 31 labels son visibles para todos los proyectos.

- **El color codifica la categoria** -- Cada grupo tiene una familia de colores.

---

# GROUP: Type

**Que tipo de trabajo es?** -- Exclusivo: uno por issue -- Requerido en todo issue

| Label | Descripcion |
|-------|-------------|
| **Bug** | Algo esta roto. Crashes, errores, violaciones de spec. |
| **Feature** | Nueva capacidad que no existe. Nuevo endpoint, pagina, evento. |
| **Improvement** | Mejora a funcionalidad existente. UX, performance, refactor. |
| **Chore** | Mantenimiento. Sin cambio visible al usuario. Deps, CI/CD, docs. |
| **Spike** | Investigacion con tiempo acotado. Output = conocimiento. ADR, PoC. |
| **Design** | Trabajo UI/UX o creativo. Mockups, design system, branding. |

---

# GROUP: Size

**Que tan grande es?** -- Mapea a budgets de tokens de IA -- Exclusivo: uno por issue

| Label | Tokens | Tiempo | Ejemplo |
|-------|--------|--------|---------|
| **XS** | <50K | ~30 min | Un archivo, cambio obvio. Typo, config. |
| **S** | 50-100K | ~2-4 hrs | 2-3 archivos. Un componente, hook, migracion. |
| **M** | 100-200K | ~1-2 dias | Cross-module. Frontend + backend + migration + tests. |
| **L** | 200-500K | ~3-5 dias | Cross-layer, afecta arquitectura. Posible descomposicion. |
| **XL** | 500K+ | Descomponer | Scope de Epic. Necesita descomposicion en issues menores. |

---

# GROUP: Strategy

**Como debe un agente IA abordar esto?** -- Exclusivo: uno por issue

| Label | Cuando usarlo |
|-------|--------------|
| **Solo** | Un agente, end-to-end. Requerimientos claros, solo ejecutar. |
| **Team** | Multiples agentes en paralelo. Frontend + backend + tests concurrentemente. |
| **Worktree** | Aislamiento en git worktree. Cambios riesgosos, experimentales. |
| **Explore** | Scope desconocido -- investigar codebase ANTES de proponer solucion. |
| **Human** | Requiere decision humana. UX, logica de negocio, arquitectura. |
| **Review** | Solo auditoria -- sin cambios de codigo. Output es un reporte. |

---

# Labels Sin Grupo -- Combinables

Issues pueden tener multiples labels de estas categorias.

## Component (8 labels)

Frontend -- Backend -- Database -- Security -- Performance -- Infra -- Testing -- Web Quality

## Impact (3 labels)

| Label | Cuando |
|-------|--------|
| **Critical Path** | Bloquea otro trabajo o un lanzamiento |
| **Revenue** | Ligado a cliente pagador o deal |
| **Grant** | Financiado por grants, deadlines externos |

## Flags (3 labels)

**Blocked** -- Esperando dependencia | **Quick Win** -- <2 horas, alto impacto | **Epic** -- Contenedor padre con sub-issues

---

# Labeling en Practica -- 3 Ejemplos

**"Agregar verificacion de email al onboarding"**
ALT-16 -- Feature -- S -- Solo -- Backend + Security

**"Fix webhook de subsidio retornando 500 en aprobacion"**
ALT-XX -- Bug -- M -- Explore -- Backend -- Critical Path -- Revenue

**"Asegurar contrato municipal de San Jose para Quantathon Vet"**
ALT-XX -- Feature -- Human -- Revenue

---

<!-- _class: chapter -->

# 03

## Escribiendo Buenos Issues
El Template Bilingue -- disenado para humanos Y agentes IA

---

# El Template Bilingue

Cada issue debe ser legible y valioso para humanos que orquestan Y agentes que ejecutan.

<div class="columns">
<div>

## Capa Humana

- **User Story** -- Como [rol], quiero [X] para que [Y]
- **Background / Por que** -- 2-3 parrafos, lenguaje llano
- **Analogia** -- Comparar con algo familiar
- **UX / Referencia Visual** -- Screenshots, links Figma
- **Pitfalls Conocidos** -- Edge cases, data legacy

</div>
<div>

## Capa Agente

- **Objetivo** -- 1-2 oraciones, outcome tecnico
- **Context Files** -- Paths exactos con descripcion
- **Acceptance Criteria** -- Checkboxes, testeables
- **Technical Constraints** -- Patrones a seguir
- **Verification Commands** -- Comandos bash exactos
- **Context Budget + Agent Strategy**

</div>
</div>

---

# Por Que Issues Ricos Ganan

> La economia de specs ricos vs. alucinaciones de agentes

**Issue rico de 50 lineas:**
~500 tokens extra (0.25% de ventana de 200K) + 10 min humano = agente ejecuta correctamente al primer intento

**Issue vago de 2 lineas:**
Agente alucina paths + inventa reglas de negocio = rework completo, ~50K tokens quemados, multiples ciclos de review

> El enriquecimiento de issues es la actividad humana de mayor apalancamiento. 10 minutos agregando contexto ahorran 30+ minutos de debugging.

---

<!-- _class: chapter -->

# 04

## OpenSpec Workflow
Spec library, changes, y el flujo de proposal a codigo

---

# Que es OpenSpec?

OpenSpec agrega una **capa de especificacion** al monorepo que los agentes IA consultan antes de escribir codigo.

```
openspec/
  specs/          <-- "Spec Library": como funciona el sistema HOY
    platform-overview/spec.md
    rescue-pipeline/spec.md
    vet-subsidy/spec.md
    adoption/spec.md
    financial/spec.md
    abuse-reports/spec.md
    architecture/spec.md

  changes/        <-- "Changes": que queremos CONSTRUIR
    rescue-coordination/
      proposal.md   <-- Que y por que
      design.md     <-- Como (arquitectura, state machines, APIs)
      tasks.md      <-- Tareas con checkboxes para implementar
```

---

# El Flujo OpenSpec

```
1. /opsx:propose "descripcion"
   --> Crea proposal.md + design.md + tasks.md

2. /opsx:apply nombre-del-change
   --> Lee artefactos, implementa task por task

3. /opsx:archive nombre-del-change
   --> Fusiona deltas de vuelta en spec library
```

## Integracion con Linear

Cada change se vincula a un issue de Linear (ALT-XX).
El issue contiene la referencia: `openspec/changes/nombre-del-change/`
Para implementar: `/opsx:apply` o `/make-no-mistakes ALT-XX`

---

# Spec Library -- 7 Specs por Workflow

| Spec | Lineas | Contenido clave |
|------|--------|----------------|
| **platform-overview** | 320 | Roles, revenue model, roadmap, glosario |
| **rescue-pipeline** | 823 | 3 state machines, 40+ business rules, PostGIS matching |
| **vet-subsidy** | 639 | Saga workflow, 44 rules, dual invoicing, gov auth |
| **adoption** | 473 | Lifecycle state machine, contratos digitales, follow-up |
| **financial** | 766 | P2P donations, PCI DSS, KYC/SUGEF, ONVOPay |
| **abuse-reports** | 583 | Reportes autenticados, auto-routing jurisdiccional |
| **architecture** | 1,319 | 10 microservicios, security, resilience, observability |

**Total: 4,923 lineas de documentacion viva**

---

<!-- _class: chapter -->

# 05

## Desarrollo AI-First
Estrategias de agentes, paralelizacion, y la regla de 200K

---

# La Regla de 200K

Ningun issue deberia requerir mas contexto que una ventana de Claude (200K tokens).

## Cuando Dividir

- Toca mas de 5 archivos
- Cruza 2+ capas (frontend + backend + DB)
- Abarca 2+ dominios (rescue + payments)
- Etiquetado como XL (500K+ tokens)

## Como Dividir

- Dividir por capa (frontend / backend / DB)
- Dividir por boundary de dominio
- Research spike + Implementation + Review
- Usar issue padre (Epic) para trackear el set

---

# 3 Mecanismos de Paralelizacion

| Mecanismo | Mejor para | Costo |
|-----------|-----------|-------|
| **Subagents** | Research rapido, tareas focalizadas. Como "enviar un asistente a buscar algo". | 1x tokens |
| **Git Worktrees** | Sesiones paralelas en diferentes branches. Como "escritorios separados en la misma oficina". | 1x por sesion |
| **Agent Teams** | Trabajo multi-parte complejo. Como "firma consultora auto-organizada". | 3-4x tokens |

## Mapeo Size --> Mecanismo

- **XS/S** --> Solo (sin paralelizacion)
- **M con un componente** --> Solo o Subagents para research
- **M con multiples componentes** --> Agent Teams (2 teammates)
- **L** --> Agent Teams (2-3 teammates) o Worktree si riesgoso
- **XL** --> Descomponer primero, luego Agent Teams por sub-issue

---

# El Flujo de Ingenieria

1. **Issue creado** -- Usar template bilingue. Setear Type + Size + Strategy.
2. **Humano enriquece** -- Agregar pitfalls, context files, acceptance criteria. 10 min = actividad de mayor ROI.
3. **Agente lee** -- Lee issue COMPLETO + OpenSpec change si existe.
4. **Agente implementa** -- Sigue Technical Constraints. Ejecuta Verification Commands.
5. **Agente crea PR** -- Mueve issue a In Review. Spawns review subagent.
6. **Humano revisa PR** -- Calidad, logica de negocio, edge cases. Aprobar o pedir cambios.
7. **Merge --> Done** -- PR merged a main. Issue auto-moves a Done. Post-merge monitoring.

**3 Checkpoints Humanos:** Issue enrichment (#2) -- PR review (#6) -- Post-merge monitoring (#7)

---

<!-- _class: chapter -->

# 06

## Gobernanza y Rituales
Triage semanal, gobernanza de labels, y reglas del camino

---

# Triage y Rituales de Gobernanza

## Triage Semanal (Viernes)

Revisar top 10 issues sin asignar. Aplicar template bilingue a issues de alta prioridad. Asignar a ciclo de sprint. Re-verificar conteo de Urgent -- max 5-7 en todo el workspace.

## Auditoria de Labels (Mensual)

Ejecutar `/linear-projects-setup audit`. Verificar que no se crearon labels no autorizados. Confirmar que todos los issues abiertos tienen label Type. Archivar labels en desuso.

## Poda de Backlog (Trimestral)

Cancelar issues stale >90 dias sin actividad. Re-priorizar issues Urgent (matar inflacion). Descomponer cualquier issue XL restante.

---

# Reglas del Camino

- Solo workspace admins pueden crear nuevos labels

- Todo issue necesita un **Type** -- sin excepciones

- Usar `blockedBy`/`blocks` para dependencias

- Todo issue pertenece a un **proyecto**

- **Conventional commits** obligatorios: `feat:`, `fix:`, `docs:`, `chore:`

- **No emojis** ni diagramas ASCII en el repo -- usar Mermaid

- **PR reviewers automaticos**: Greptile + CodeRabbit + Graphite

- **`linear-setup.json`** es la fuente de verdad para configuracion del proyecto

---

<!-- _class: chapter -->

# Quick Reference

## Cheat Sheet

---

# Cheat Sheet

| Dimension | Labels | Regla |
|-----------|--------|-------|
| Type | Bug, Feature, Improvement, Chore, Spike, Design | Uno por issue, requerido |
| Size | XS, S, M, L, XL | Uno por issue, mapea a tokens |
| Strategy | Solo, Team, Worktree, Explore, Human, Review | Uno por issue, guia al agente |
| Component | Frontend, Backend, DB, Security, Perf, Infra, Testing, Web Quality | Combinables |
| Impact | Critical Path, Revenue, Grant | Combinables |
| Flags | Blocked, Quick Win, Epic | Combinables |

## Comandos Clave

`/opsx:propose` -- Crear change | `/opsx:apply` -- Implementar | `/make-no-mistakes ALT-XX` -- Ejecutar con disciplina | `/spec-recommend T0-4` -- Analizar y generar change

---

<!-- _class: lead -->

# A Construir.

## Un workspace. 8 proyectos. 31 labels.
Issues ricos. Ejecucion AI-first. Calidad human-in-the-loop.

Todo issue tiene Type. Sin excepciones.
Issues bilingues -- 10 min de enriquecimiento ahorra 30 min de rework.
Size + Strategy guian la ejecucion del agente IA.
Triage de viernes mantiene el backlog saludable.
