# ALT-62 Spike Synthesis: Day in the Life — Marcela Alvarado

> **Source:** ALT-62 (Done) — Spike: Day in the Life, Bienestar Animal Heredia
> **Generated:** 2026-04-08
> **Issues created:** ALT-63, ALT-64, ALT-65, ALT-66

## Executive Summary (Minto Pyramid)

**Answer:** AltruPets' SRD covers 75% of what a municipal animal welfare officer needs, but misses the single most visible program (spay/neuter campaigns = 25% of daily work) and lacks automation features (auto-approval, after-hours routing) that would make the platform viable for a one-person office.

**Supporting Arguments:**
1. **Operational Gap:** J11 (Campaigns) is completely absent — the most public-facing program has zero digital support
2. **Automation Gap:** J4 (Subsidies) exists but manual-only — auto-approval rules would eliminate the biggest daily bottleneck
3. **Work-Life Gap:** No after-hours system means the officer IS the system 17 hours/day

**Evidence:** 8-page field interview, 6-phase experience map, cross-referenced with SRD (10 personas, 10 journeys, gap-audit).

## Issues Created

| ID | Title | Type | Size | Priority | Strategy |
|----|-------|------|------|----------|----------|
| **ALT-63** | J11 — Campanas de Castracion (nuevo journey) | Feature | L | High | Team |
| **ALT-64** | Auto-aprobacion VB Veterinario (J4 Enhancement) | Improvement | M | Urgent | Solo |
| **ALT-65** | Template Informe SENASA (T1-9 Enhancement) | Feature | S | Normal | Solo |
| **ALT-66** | Sistema Guardia Nocturna (J2 Enhancement) | Feature | M | High | Explore |

## Tech Stack Decision

All issues target **Flutter Web** at `apps/web/b2g/` (replacing existing Vue/Inertia stubs), using `style-dictionary/tokens.json` for the design system. Backend remains NestJS + GraphQL.

## Dependency Graph

```
ALT-64 (VB Auto-approval)
  └── depends on T0-4, T0-5 (subsidy workflow)

ALT-63 (J11 Campaigns)
  └── depends on Flutter Web B2G scaffold
  └── depends on T0-9 (PostGIS)
  └── enriches T0-7 (J7 Dashboard)

ALT-65 (SENASA Reports)
  └── depends on T1-9 (report system)
  └── depends on T0-7 (dashboard data)

ALT-66 (Night Guard)
  └── depends on T1-1 (rescue coordination)
  └── depends on T1-3 (push notifications)
```

## MECE Validation

- **Mutually Exclusive:** Each issue addresses a distinct gap — no overlap between campaigns (ALT-63), auto-approval (ALT-64), SENASA reports (ALT-65), and after-hours (ALT-66).
- **Collectively Exhaustive:** The 4 issues + existing SRD tasks (T0-4 through T1-9) cover all 8 needs identified in ALT-62's gap table. No unaddressed gap remains.

## Pareto 80/20

**80% of value from 20% of work:**
1. **ALT-64 (VB Auto-approval)** — Eliminates 2 hours/day of bottleneck. Highest ROI single feature.
2. **ALT-63 sub-issues 1+2+6 (Campaign entity + planning + metrics)** — Covers 25% of unaddressed daily work.

The remaining issues (SENASA template, night guard) are important but lower-urgency.

## Second-Order Thinking

- **If we build J4+J7 without J11:** Dashboard metrics will be incomplete — spay/neuter data (the highest-volume activity) will be missing, undermining the ROI story for the concejo.
- **If we build auto-approval without audit trail:** Municipalities may face compliance questions. Every auto-approved request needs logged reasoning.
- **If the night guard system is too noisy:** Auxiliary volunteers will burn out and churn. Triage accuracy is critical — start with manual classification, not ML.
- **Flutter Web migration risk:** Starting `apps/web/b2g/` from scratch is the right call (existing Vue stubs are empty) but the scaffold must be solid before feature work begins.
