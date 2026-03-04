# SRD Framework — AltruPets

**Product**: AltruPets — Cloud-Native Animal Welfare Coordination Platform for LATAM
**Target**: $10,000 MRR (~$120,000 ARR)
**Generated**: 2026-03-03
**Method**: SRD Assess (Guided Dialogue)

---

## Table of Contents

1. [Success Reality](#1-success-reality)
2. [Synthetic Personas](#2-synthetic-personas)
3. [Critical Journeys](#3-critical-journeys)
4. [Gap Audit Matrix](#4-gap-audit-matrix)
5. [Claude Directive](#5-claude-directive)

---

## 1. Success Reality

**Timeline**: 6 months from MVP launch | **Geography**: Costa Rica + 1-2 LATAM countries

### Platform KPIs

| Metric | Target |
|--------|--------|
| MRR | $10,000 |
| ARR | $120,000 |
| Registered users | ~5,000 |
| MAU | ~2,500 (50%) |
| Paying municipalities | 10 |
| Paying vet clinics | 25 |
| Monthly donation volume (P2P) | $25,000 |
| Monthly subsidy volume | $50,000 |
| Municipal churn | ~2% (annual contracts) |
| Vet clinic churn | ~8%/mo |
| NPS | 40+ |

### Revenue Breakdown

| Stream | MRR | % | Unit Economics |
|--------|-----|---|----------------|
| B2G Municipal Contracts | $7,500 | 75% | 10 municipalities x $750/mo avg |
| Vet Clinic Subscriptions | $2,000 | 20% | 25 clinics x $80/mo avg |
| Premium Features | $500 | 5% | Analytics, API access, priority support |

### Municipal Contract Tiers

- **Small** (<50K pop): $500/mo — subsidy workflow + basic reporting
- **Medium** (50-200K pop): $800/mo — full dashboard + abuse reports + analytics
- **Large** (>200K pop): $1,500/mo — multi-department + API + priority support

### Vet Clinic Tiers

- **Free**: Directory listing, receive subsidy requests
- **Standard** ($50/mo): Patient management, subsidy billing, analytics
- **Premium** ($100/mo): Preferred placement, multi-location, priority processing

### Regulatory Decision

AltruPets is a **coordination platform**, NOT a financial intermediary. Donations flow peer-to-peer (donor -> org). Vet subsidy payments flow government -> clinic. AltruPets facilitates and records but NEVER holds funds. This avoids SUGEF oversight (Ley 7786, Arts. 15/15 bis).

### Conversion Attribution

| Trigger | % |
|---------|---|
| Municipal demo (subsidy + abuse workflow) | 45% |
| Word-of-mouth / network effects | 25% |
| Vet clinic volume threshold | 15% |
| Regulatory compliance pressure | 15% |

### Activity Volume at Target

| Metric | Monthly |
|--------|---------|
| Active rescue cases | ~200 |
| Animals in foster care | ~500 |
| Abuse reports (authenticated) | ~300 |
| Vet subsidy requests | ~150 |
| Adoption listings | ~100 |
| Successful adoptions | ~60 |
| In-kind donation fulfillments | ~100 |

---

## 2. Synthetic Personas

### Summary Table

| ID | Name | Archetype | User % | Revenue % | Engagement | Revenue | Virality |
|----|------|-----------|--------|-----------|------------|---------|----------|
| P01 | Gabriela | B2G Decision Maker | 1% | 75% | 6 | 10 | 8 |
| P02 | Laura | B2G Daily Operator | 2% | 0% | 9 | 1 | 3 |
| P03 | Dr. Carlos | Vet Clinic Payer | 3% | 18% | 7 | 8 | 5 |
| P04 | Dr. Priscilla | Vet Collaborator | 3% | 2% | 8 | 2 | 4 |
| P05 | Sofia | Power User / Rescuer | 5% | 0% | 10 | 1 | 9 |
| P06 | Miguel | NGO Org Leader | 3% | 3% | 9 | 2 | 10 |
| P07 | Andrea | Casual Sentinel | 40% | 0% | 3 | 0 | 6 |
| P08 | Diego | Active Auxiliary | 8% | 0% | 7 | 0 | 5 |
| P09 | Maria Elena | Adoption Seeker | 20% | 0% | 4 | 0 | 7 |
| P10 | Roberto | Monthly Donor | 15% | 0% | 4 | 1 | 6 |
| | | **Totals** | **100%** | **100%** | | | |

### Ecosystem Dynamics

**Revenue anchors**: P01 (Gabriela) + P03 (Dr. Carlos) = 93% of revenue

**Vulnerability chain**: If P05 (Sofia) and P06 (Miguel) churn -> no foster homes -> no animals -> no adoptions -> no subsidy requests -> P01 and P03 see no value -> revenue collapses. **Rescuers are the oxygen of the platform even though they pay $0.**

**Full persona details**: See `srd/personas.yml`

---

## 3. Critical Journeys

### Scoring Summary

| ID | Journey | Score | Revenue at Risk |
|----|---------|-------|-----------------|
| J1 | Signup/Onboarding | **60%** | $200/mo |
| J2 | Rescue Coordination | **15%** | $255/mo |
| J3 | Adoption Lifecycle | **0%** | $200/mo |
| J4 | Vet Subsidy Request & Approval | **0%** | $3,500/mo |
| J5 | Abuse Reporting (Auth) | **5%** | $1,425/mo |
| J6 | Casa Cuna & Animal Mgmt | **10%** | $720/mo |
| J7 | Municipal Dashboard | **5%** | $1,900/mo |
| J8 | Donation & Impact | **8%** | $92/mo |
| J9 | Vet Onboarding -> Premium | **0%** | $1,000/mo |
| J10 | Chat & Notifications | **20%** | $80/mo |

### Dependency Graph

```
J1 (Signup) <- ROOT
  +-- J6 (Casa Cuna) <- J1
  |     +-- J3 (Adoption) <- J1 + J6
  |     +-- J4 (Subsidy) <- J1 + J6 + J9
  |     +-- J8 (Donation) <- J1 + J6
  +-- J2 (Rescue) <- J1 + J6 + J10
  +-- J5 (Abuse) <- J1 (auth required, INDEPENDENT from J2)
  +-- J7 (Dashboard) <- J1, STANDALONE
  +-- J9 (Vet) <- J1, feeds J4
  +-- J10 (Chat) <- J1, enhances J2/J3/J4
```

**Parallel paths to B2G revenue:**
- Path A: J1 -> J6 + J9 -> J4 (subsidies)
- Path B: J1 -> J5 (abuse reports)
- Path C: J1 -> J7 (dashboard, always-on)

**Full journey details**: See `srd/journeys.md`

---

## 4. Gap Audit Matrix

### Persona x Journey Impact

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

### Revenue at Risk (sorted)

| Journey | Revenue at Risk |
|---------|-----------------|
| J4 Vet Subsidy | $3,500/mo |
| J7 Dashboard | $1,900/mo |
| J5 Abuse Reports | $1,425/mo |
| J9 Vet Onboarding | $1,000/mo |
| J6 Casa Cuna | $720/mo |
| J2 Rescue | $255/mo |
| J1 Signup | $200/mo |
| J3 Adoption | $200/mo |
| J8 Donation | $92/mo |
| J10 Chat | $80/mo |
| **Total** | **$9,372/mo (93.7%)** |

### All Personas: BROKEN Tier

All 10 personas have viability scores below 40%. Only J1 (Signup) partially works.

### Implementation Sequence

```
Phase 1 (Weeks 1-2): Foundation — parallel tracks
  A: Animal entity + Casa Cuna (T0-1, T0-2)
  B: Auth hardening + quick wins (T0-3, QW-1..5)
  C: Vet profile/clinic (T0-8)
  D: PostGIS (T0-9)

Phase 2 (Weeks 3-5): Revenue Path A — Subsidies
  T0-4 -> T0-5 -> T0-7

Phase 3 (Weeks 3-4): Revenue Path B — Abuse Reports (parallel)
  T0-6

Phase 4 (Weeks 5-6): Municipal Dashboard
  T0-7 (combines subsidy + abuse data)

Phase 5 (Weeks 5-8): Value Delivery
  T1-1 through T1-6

Phase 6 (Weeks 8-10): Revenue Optimization
  T1-7 through T1-9, T2-1, T2-4

Phase 7 (Weeks 10-12): Retention
  T2-2, T2-3, T2-5, T2-6
```

**Full gap audit details**: See `srd/gap-audit.md`

---

## 5. Claude Directive

### North Star

> Can a rescuer submit a vet subsidy request, have it auto-route to the correct municipality, get approved, AND can the municipality view it on their dashboard?

### Priority Rules (ordered)

1. **B2G revenue paths first** — subsidies (J4) and abuse reports (J5) before all else
2. **Animals must exist** — Animal entity + Casa Cuna (J6) is the foundation
3. **Auth must be solid** — token refresh, security fixes are silent blockers
4. **Vet clinics are second revenue** — vet UX enables 20% of revenue
5. **Never intermediate funds** — SUGEF compliance, peer-to-peer only
6. **Rescue coordination != revenue** — J2 is value-delivery, don't block revenue on it
7. **Dashboard is always-on** — show whatever data exists, never empty
8. **Rescuers pay $0 forever** — they are value creators, not revenue
9. **Abuse reports require auth** — accountability over anonymity
10. **In-kind donations are first-class** — food, medicine, toys alongside cash

### Anti-Patterns

1. Don't build rescue pipeline before subsidies
2. Don't route donations through AltruPets (SUGEF)
3. Don't prioritize rescuer features over municipality features
4. Don't decompose to microservices before monolith MVP works
5. Don't over-engineer RBAC before workflows exist
6. Don't build chat before push notifications
7. Don't allow anonymous abuse reports
8. Don't charge rescue organizations

### Top 5 Priorities

| # | Task | Revenue at Risk | Effort |
|---|------|-----------------|--------|
| 1 | Animal entity + Casa Cuna management | $3,500/mo | M (days) |
| 2 | Vet subsidy workflow + municipal review | $5,400/mo | L (weeks) |
| 3 | Abuse report flow | $1,425/mo | M (days) |
| 4 | Auth hardening + security quick wins | $200/mo + indirect | M (days) |
| 5 | Vet profile/clinic + PostGIS | $1,000/mo | M (days) |

**Full directive**: See `srd/claude-directive.yml`
