# ALT-64 Architecture Blueprint: Desembolsos Veterinarios + Auto-Aprobacion

> Generated: 2026-04-08 by feature-dev:code-architect agent

## Decision

Extend existing `subsidies` module (not new module). Same pattern as RescueStateMachine.

## Database

### subsidy_requests — add 7 columns
- vetProfileId, reviewedById, reviewedAt, autoApproved (bool), rejectionReason, procedureType, trackingCode (unique VBS-XXXXXXXX)

### auto_approval_rules — new table
- id, municipalityId (FK), ruleType (enum), isEnabled, parameters (jsonb), timestamps

### approval_audit_log — new table
- id, subsidyRequestId (FK), actorId, action (enum), ruleResults (jsonb), previousStatus, newStatus, notes, createdAt

## Auto-Approval Engine

5 rules evaluated sequentially:
1. VERIFIED_RESCUER — user.isVerified
2. REGISTERED_ANIMAL — animal has microchipId or casaCunaId
3. WITHIN_BUDGET — rolling window aggregate query
4. AUTHORIZED_VET — vetProfile.isVerified
5. NO_DUPLICATE — no same animal+requester in window

Engine never throws — wraps in try/catch, defaults to manual review.

## State Machine

```
CREATED → [all rules pass] → APPROVED (auto)
CREATED → [any rule fails] → IN_REVIEW → APPROVED/REJECTED (manual)
CREATED → [72h timeout] → EXPIRED
```

## GraphQL API

Mutations: createVetSubsidyRequest, approveSubsidyRequest, rejectSubsidyRequest, upsertAutoApprovalRule, toggleApprovalRule
Queries: pendingSubsidyRequests, approvedSubsidyRequests, subsidyBudgetStatus, subsidyAuditLog, approvalRules

## Flutter Web Screens

- DisbursementsPage: KPI bar (4 cards) + filter tabs + request list + modal
- SubsidyDetailModal: 3-step stepper (Solicitud → Revision → Resolucion)
- ApprovalRulesPage: 5 rule cards with toggles

## Visual Reference

Mockups: `.superpowers/brainstorm/3003331-1775635693/content/all-panels-v2.html`

## Build Sequence

Phase 1: Backend entities + migration
Phase 2: DTOs + engine
Phase 3: Service + resolver + module wiring
Phase 4: Flutter models + widgets (uses altrupets_ui package)
Phase 5: Flutter pages with mock data
Phase 6: GraphQL wiring (separate ticket)
