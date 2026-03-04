# Gap Audit Matrix — AltruPets

**Target**: $10K MRR | **Total Revenue at Risk**: $9,372/mo (93.7%)
**Overall Platform Completion**: ~28% (infrastructure mature, revenue paths at 0-8%)

## Layer 1: Persona x Journey Impact Matrix

```
         J1   J2   J3   J4   J5   J6   J7   J8   J9   J10
P01 Gab  X    -    -    $    $    -    $    -    -    -     <- Municipal buyer (75% rev)
P02 Lau  X    -    -    X    X    -    X    -    -    -     <- Municipal operator
P03 Car  X    -    -    $    -    -    -    -    $    -     <- Vet clinic payer (18% rev)
P04 Pri  X    -    -    X    -    -    -    -    X    -     <- Vet employee
P05 Sof  X    $    $    X    -    $    -    X    -    X     <- Rescuer power user
P06 Mig  X    $    $    X    X    $    -    X    -    X     <- NGO leader
P07 And  X    -    -    -    X    -    -    -    -    -     <- Sentinel
P08 Die  X    X    -    -    -    -    -    -    -    X     <- Auxiliary
P09 Mar  X    -    $    -    -    -    -    -    -    -     <- Adopter
P10 Rob  X    -    -    -    -    -    -    $    -    -     <- Donor

Legend: X = Essential | $ = Conversion trigger
```

## Layer 2: Revenue at Risk per Journey

Formula: `Revenue at risk = (Conversion attribution %) x $10K MRR x (1 - Score/100)`

| Rank | Journey | Score | Conv. Attr. % | Revenue at Risk | Personas Blocked |
|------|---------|-------|---------------|-----------------|-----------------|
| 1 | **J4** Vet Subsidy | 0% | 35% | **$3,500/mo** | P01,P02,P03,P04,P05,P06 |
| 2 | **J7** Municipal Dashboard | 5% | 20% | **$1,900/mo** | P01,P02 |
| 3 | **J5** Abuse Reports | 5% | 15% | **$1,425/mo** | P01,P02,P06,P07 |
| 4 | **J9** Vet Onboarding | 0% | 10% | **$1,000/mo** | P03,P04 |
| 5 | **J6** Casa Cuna Mgmt | 10% | 8% | **$720/mo** | P05,P06 |
| 6 | **J2** Rescue Coordination | 15% | 3% | **$255/mo** | P05,P06,P07,P08 |
| 7 | **J1** Signup/Onboarding | 60% | 5% | **$200/mo** | ALL |
| 8 | **J3** Adoption | 0% | 2% | **$200/mo** | P05,P06,P09 |
| 9 | **J8** Donation | 8% | 1% | **$92/mo** | P10,P06 |
| 10 | **J10** Chat | 20% | 1% | **$80/mo** | ALL active |

## Layer 3: Persona Viability Summary

| Persona | Essential Journeys (scores) | Avg Score | Tier | Revenue Impact |
|---------|---------------------------|-----------|------|----------------|
| P01 Gabriela | J1(60%), J4(0%), J5(5%), J7(5%) | **17%** | **BROKEN** | $7,500/mo at risk |
| P02 Laura | J1(60%), J4(0%), J5(5%), J7(5%) | **17%** | **BROKEN** | (in P01) |
| P03 Dr. Carlos | J1(60%), J4(0%), J9(0%) | **20%** | **BROKEN** | $2,000/mo at risk |
| P04 Dr. Priscilla | J1(60%), J4(0%), J9(0%) | **20%** | **BROKEN** | (in P03) |
| P05 Sofia | J1(60%), J2(15%), J3(0%), J4(0%), J6(10%), J8(8%) | **15%** | **BROKEN** | Ecosystem collapse |
| P06 Miguel | J1(60%), J2(15%), J3(0%), J4(0%), J5(5%), J6(10%), J8(8%) | **14%** | **BROKEN** | Ecosystem collapse |
| P07 Andrea | J1(60%), J5(5%) | **32%** | **BROKEN** | Top-of-funnel loss |
| P08 Diego | J1(60%), J2(15%) | **37%** | **BROKEN** | Rescue pipeline loss |
| P09 Maria Elena | J1(60%), J3(0%) | **30%** | **BROKEN** | Adoption pipeline loss |
| P10 Roberto | J1(60%), J8(8%) | **34%** | **BROKEN** | Ecosystem funding loss |

**All 10 personas are in BROKEN tier.** Only J1 (Signup) partially works.

## Layer 4: Prioritized Fix List

### T0: Revenue Blockers

| ID | Description | Journey | Personas | Revenue at Risk | Effort | Dependencies |
|----|-------------|---------|----------|-----------------|--------|--------------|
| **T0-1** | Create Animal entity + DB migration (PostGIS-ready coordinates) | J6,J2,J3,J4 | P05,P06 | $3,500/mo | M (days) | None |
| **T0-2** | Build Casa Cuna management: register foster home, add/remove animals, capacity, needs list for donors | J6,J8 | P05,P06,P10 | $720/mo | M (days) | T0-1 |
| **T0-3** | Fix auth: expose `refreshToken` as GraphQL mutation, wire mobile interceptor, unify dual auth system | J1 | ALL | $200/mo | M (days) | None |
| **T0-4** | Build Vet Subsidy Request workflow: create request, auto-assign jurisdiction by GPS, state machine (CREATED->IN_REVIEW->APPROVED->REJECTED->EXPIRED) | J4 | P01-P06 | $3,500/mo | L (weeks) | T0-1, T0-2, T0-9 |
| **T0-5** | Build Municipal Subsidy Review dashboard (web): pending queue, approve/reject, auto-expire | J4,J7 | P01,P02 | $1,900/mo | L (weeks) | T0-4 |
| **T0-6** | Build Abuse Report flow: authenticated report form with GPS + photos, tracking code, status tracking | J5 | P01,P02,P07 | $1,425/mo | M (days) | T0-3 |
| **T0-7** | Build Municipal Dashboard (web): KPI overview, jurisdiction-scoped, pending items queue, standalone | J7 | P01,P02 | $1,900/mo | L (weeks) | T0-5, T0-6 |
| **T0-8** | Build Vet profile + clinic registration: credentials, specialties, location, hours, pricing | J9 | P03,P04 | $1,000/mo | M (days) | None |
| **T0-9** | Implement PostGIS for proximity queries: jurisdiction mapping, nearest vet/rescuer/auxiliary | J2,J4,J5 | ALL | $2,000/mo | M (days) | None |

### T1: Value Delivery

| ID | Description | Journey | Personas | Revenue at Risk | Effort | Dependencies |
|----|-------------|---------|----------|-----------------|--------|--------------|
| **T1-1** | Build Rescue Coordination pipeline: sentinel alert, auxiliary notification + acceptance, navigation, transfer to rescuer | J2 | P05-P08 | $255/mo | L (weeks) | T0-1,T0-2,T0-9 |
| **T1-2** | Build Adoption flow: publish animal, browsable listings with filters, adoption request + screening | J3 | P05,P06,P09 | $200/mo | L (weeks) | T0-1,T0-2 |
| **T1-3** | Implement push notifications (Firebase): rescue alerts, subsidy status, messages, abuse updates | J2,J4,J5,J10 | ALL | $500/mo | M (days) | Firebase config exists |
| **T1-4** | Integrate chat with workflows: auto-create rooms, link to case, archive on completion | J10 | ALL active | $80/mo | M (days) | Chat partially exists |
| **T1-5** | Build Vet patient management: medical records, treatment history, medication tracking | J4,J9 | P03,P04 | $300/mo | M (days) | T0-8 |
| **T1-6** | Build email verification + password reset flows | J1 | ALL | $100/mo | S (hours) | T0-3 |
| **T1-7** | Build Vet billing: digital invoice submission, subsidy payment tracking | J4 | P03,P04 | $200/mo | M (days) | T0-4,T0-5 |
| **T1-8** | Build Donation flow: peer-to-peer SINPE/bank, donation recording (no intermediation), recurring, in-kind donations | J8 | P10,P06 | $92/mo | M (days) | T0-2 |
| **T1-9** | Build transparency reports: PDF/Excel export, configurable date ranges, impact metrics | J7 | P01,P02 | $300/mo | M (days) | T0-7 |

### T2: Retention & Growth

| ID | Description | Journey | Personas | Effort | Dependencies |
|----|-------------|---------|----------|--------|--------------|
| **T2-1** | Digital adoption contracts with e-signature | J3 | P05,P06,P09 | M | T1-2 |
| **T2-2** | Automated follow-up notifications (30/60/90 days post-adoption) | J3 | P05,P06,P09 | S | T1-2,T1-3 |
| **T2-3** | Donor impact dashboard: animals helped, stories, transparency score | J8 | P10 | M | T1-8 |
| **T2-4** | Vet clinic usage-based upgrade prompts (free -> paid) | J9 | P03 | S | T0-8,T1-5 |
| **T2-5** | Reputation/rating system for rescuers, auxiliaries, vets | J2,J3,J4 | ALL | L | T1-1,T1-2 |
| **T2-6** | Offline-first mode for rescue coordination in low-connectivity areas | J2 | P08 | L | T1-1 |

### Quick Wins (existing code/config)

| ID | What to Do | Impact | Effort |
|----|-----------|--------|--------|
| **QW-1** | Add `@UseGuards(JwtAuthGuard)` to `createCaptureRequest` mutation | Security: unauthenticated mutation fix | Minutes |
| **QW-2** | Add `userId` FK to `capture_requests` table | Data integrity: track who reported | Hours |
| **QW-3** | Expose existing `refreshToken()` as GraphQL mutation in `auth.resolver.ts` | Unlocks token refresh on mobile | Hours |
| **QW-4** | Remove hardcoded JWT secret fallback (`'super-secret-altrupets-key-2026'`) | Security: remove default secret | Minutes |
| **QW-5** | Wire Redis adapter for cache (URL configured, adapter not connected) | Token persistence across pod restarts | Hours |

## Implementation Sequence

```
PHASE 1 -- Foundation (Weeks 1-2): Parallel tracks
  Track A: T0-1 -> T0-2 (Animal entity + Casa Cuna + needs list)
  Track B: T0-3 + QW-1..QW-5 (Auth hardening + security quick wins)
  Track C: T0-8 (Vet profile/clinic registration)
  Track D: T0-9 (PostGIS setup)

PHASE 2 -- Revenue Path A: Subsidies (Weeks 3-5)
  T0-4 (Subsidy workflow) -> T0-5 (Municipal review dashboard)

PHASE 3 -- Revenue Path B: Abuse Reports (Weeks 3-4, parallel with Phase 2)
  T0-6 (Abuse report flow)

PHASE 4 -- Municipal Dashboard (Weeks 5-6)
  T0-7 (Dashboard combining subsidy + abuse data, standalone)

PHASE 5 -- Value Delivery (Weeks 5-8)
  T1-1 (Rescue coordination) | T1-2 (Adoption)
  T1-3 (Push notifications) | T1-4 (Chat integration)
  T1-5 (Vet patient mgmt) | T1-6 (Email/password flows)

PHASE 6 -- Revenue Optimization (Weeks 8-10)
  T1-7 (Vet billing) | T1-8 (Donation + in-kind flow) | T1-9 (Reports)
  T2-4 (Vet upgrade prompts) | T2-1 (Adoption contracts)

PHASE 7 -- Retention (Weeks 10-12)
  T2-2, T2-3, T2-5, T2-6
```

### Phase Dependencies Visual

```
Phase 1 (Foundation)
  |--- Track A: T0-1 -> T0-2 ---|
  |--- Track B: T0-3 + QW-*  ---|---> Phase 2 + Phase 3 (parallel)
  |--- Track C: T0-8         ---|       |
  |--- Track D: T0-9         ---|       v
                                   Phase 4 (Dashboard)
                                        |
                                        v
                                   Phase 5 (Value Delivery)
                                        |
                                        v
                                   Phase 6 (Revenue Optimization)
                                        |
                                        v
                                   Phase 7 (Retention)
```
