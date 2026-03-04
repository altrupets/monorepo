# Critical Journeys — AltruPets

**Target**: $10K MRR | **Journeys**: 10 | **Total Revenue at Risk**: $9,372/mo (93.7%)

## Journey Scoring Summary

| ID | Journey | Personas | Tag | Score | Revenue at Risk |
|----|---------|----------|-----|-------|-----------------|
| J1 | Discovery -> Signup -> Onboarding | ALL | Revenue-Critical | **60%** | $200/mo |
| J2 | Rescue Coordination Pipeline | P05,P06,P07,P08 | Value-Delivery | **15%** | $255/mo |
| J3 | Adoption Lifecycle | P05,P06,P09 | Value-Delivery | **0%** | $200/mo |
| J4 | Vet Subsidy Request & Approval | P01-P06 | Revenue-Critical | **0%** | $3,500/mo |
| J5 | Abuse Reporting (Authenticated) | P01,P02,P06,P07 | Revenue-Critical | **5%** | $1,425/mo |
| J6 | Casa Cuna & Animal Management | P05,P06 | Value-Delivery | **10%** | $720/mo |
| J7 | Municipal Dashboard & Reporting | P01,P02 | Revenue-Critical | **5%** | $1,900/mo |
| J8 | Donation & Impact Tracking | P10,P06 | Value-Delivery | **8%** | $92/mo |
| J9 | Vet Clinic Onboarding -> Premium | P03,P04 | Revenue-Critical | **0%** | $1,000/mo |
| J10 | Real-time Chat & Notifications | ALL active | Value-Delivery | **20%** | $80/mo |

## Journey Dependency Graph

```
J1 (Signup/Onboarding) <- ROOT for ALL flows (including abuse reports)
  |
  +-- J6 (Casa Cuna Mgmt) <- depends on J1
  |     +-- J3 (Adoption) <- depends on J1 + J6 (INDEPENDENT from J2)
  |     +-- J4 (Vet Subsidy) <- depends on J1 + J6 + J9 (INDEPENDENT from J2)
  |     +-- J8 (Donation) <- depends on J1 + J6 (needs lists from casa cuna inventory)
  |
  +-- J2 (Rescue Coordination) <- depends on J1 + J6 + J10
  |
  +-- J5 (Abuse Reports) <- depends on J1 (REQUIRES AUTH, independent from J2)
  |
  +-- J7 (Municipal Dashboard) <- depends on J1, STANDALONE (enriched by J4/J5/J2 data)
  |
  +-- J9 (Vet Onboarding) <- depends on J1, feeds J4
  +-- J10 (Chat) <- depends on J1, enhances J2/J3/J4
```

**Two parallel critical paths to B2G revenue:**
- **Path A (subsidies)**: J1 -> J6 + J9 -> J4 (vet subsidy workflow)
- **Path B (abuse reports)**: J1 -> J5 (abuse reports)
- **Path C (dashboard)**: J1 -> J7 (ships immediately with any available data)

All three paths can be built in parallel for fastest time-to-value.

---

## J1: Discovery -> Signup -> Onboarding

**Score: 60%** | **Personas**: ALL | **Revenue tag**: Revenue-Critical

| Step | User Action | Screen/Route | What Must Happen | Data Required |
|------|------------|-------------|------------------|---------------|
| 1 | Downloads app from store | App Store / Play Store | App installs, splash screen loads | None |
| 2 | Taps "Registrarse" | `/register` (`RegisterPage`) | Registration form: name, email, phone, password, role selection | None |
| 3 | Fills form, selects primary role | `/register` | Client-side validation, dual SHA-256 password hash, GraphQL `register` mutation | Valid email, phone, password |
| 4 | Auto-logged in | -> `/home` (`HomeShellPage`) | JWT issued, tokens stored in Secure Storage, redirect to home | Backend user + JWT |
| 5 | Completes extended profile | `/register-individual` | Location picker, avatar upload, role-specific fields | GPS permission |
| 6 | Sees role-appropriate home screen | `/home` (5-tab nav) | Tab bar shows role-relevant sections | User role in JWT claims |

**Current state:**
- Steps 1-4: **Working**. Login/register, JWT, dual SHA-256 hashing functional.
- Step 5: **Working**. `RegisterIndividualOnboardingPage` exists.
- Step 6: **Partial**. Home shell renders but rescue/messages content stubbed.
- **Gaps**: No email verification. Password reset button is no-op. Token refresh not exposed as mutation. Dual auth system (`AuthService` sealed class + `AuthNotifier`/`AuthRepository`).

**Acceptance Criteria:**
- [x] PASS: Register with name/email/phone/password and role
- [x] PASS: JWT issued and stored securely
- [ ] FAIL: Email verification link sent (fix: T1-6)
- [ ] FAIL: "Forgot password" sends reset email (fix: T1-6)
- [ ] FAIL: Token auto-refreshes before expiration (fix: T0-3)
- [x] PASS: Role-appropriate home screen renders

---

## J2: Rescue Coordination Pipeline

**Score: 15%** | **Personas**: P07 (Sentinel), P08 (Auxiliary), P05/P06 (Rescuer) | **Revenue tag**: Value-Delivery

| Step | User Action | Screen/Route | What Must Happen | Data Required |
|------|------------|-------------|------------------|---------------|
| 1 | Sentinel opens "Crear Alerta de Auxilio" | `/rescues/new-alert` [TBD] | Form: GPS auto-capture, photo upload, urgency level, description | GPS, camera |
| 2 | Sentinel submits auxilio request | GraphQL `createCaptureRequest` | Saved with location, photos, urgency. Status -> `CREATED` | Authenticated sentinel |
| 3 | System finds nearby auxiliaries | Geolocation Service | Query within 10km radius, sort by proximity + rating | PostGIS, availability data |
| 4 | Auxiliary receives push notification | Push -> `/rescues/alert/{id}` [TBD] | Push with details, photos, distance. Tap opens detail. | Firebase token |
| 5 | Auxiliary accepts and navigates | `/rescues/alert/{id}/navigate` [TBD] | Status -> `ACCEPTED`. GPS navigation to location. | Maps integration |
| 6 | Auxiliary documents animal | `/rescues/alert/{id}/update` [TBD] | Photo upload, condition assessment. Status -> `IN_PROGRESS` | Camera |
| 7 | System finds nearby rescuers with space | Geolocation Service | Query rescuers within 15km with available capacity | PostGIS, casa cuna data |
| 8 | Rescuer accepts transfer | `/rescues/alert/{id}` [TBD] | See details + assessment. Accept. Status -> `TRANSFERRED` | Rescuer availability |
| 9 | Animal registered in casa cuna | `/casa-cuna/animals/new` [TBD] | Animal entity created with initial assessment, photos, tracking code | Animal entity |
| 10 | All participants see status | `/rescues/alert/{id}/status` [TBD] | Real-time status updates. Tracking code shared. | WebSocket |

**Current state:**
- Step 2: **Partial** — `createCaptureRequest` exists but missing auth guard (security gap), no status workflow, no `userId` FK.
- Steps 1, 4-10: **Missing** — No alert creation UI, no PostGIS, no push notifications, no assignment logic, no Animal entity.
- Mobile `rescues_page.dart`: Service card grid, all `onTap: () {}` no-ops.

**Acceptance Criteria:**
- [ ] FAIL: Sentinel creates alert with GPS + photos in <3 minutes (fix: T0-1, T1-1)
- [ ] FAIL: Nearby auxiliaries receive push within 30 seconds (fix: T1-1, T1-3)
- [ ] FAIL: Auxiliary navigates to exact GPS location (fix: T1-1)
- [ ] FAIL: System shows rescuers with available space within 15km (fix: T0-9, T1-1)
- [ ] FAIL: Animal registered with tracking code on foster placement (fix: T0-1, T0-2)
- [ ] FAIL: All participants track case in real-time (fix: T1-4)

---

## J3: Adoption Lifecycle

**Score: 0%** | **Personas**: P05/P06 (publish), P09 (apply) | **Revenue tag**: Value-Delivery

| Step | User Action | Screen/Route | What Must Happen | Data Required |
|------|------------|-------------|------------------|---------------|
| 1 | Rescuer marks animal "Ready for Adoption" | `/casa-cuna/animals/{id}/publish` [TBD] | Listing with photos, medical history, temperament, requirements | Animal entity |
| 2 | Adopter browses listings | `/adoptions` [TBD] | Filterable gallery: species, size, age, kid-friendly, location | Adoption listings |
| 3 | Adopter submits request | `/adoptions/{id}/apply` [TBD] | Home questionnaire, family details. Status -> `PENDING_REVIEW` | Adopter profile |
| 4 | Rescuer reviews application | `/casa-cuna/adoptions/{id}/review` [TBD] | See applicant profile, answers. Schedule video call. | Request + profile |
| 5 | Visit/video call | External or in-app | Evaluate fit. Status -> `VISIT_COMPLETED` | Scheduling |
| 6 | Rescuer approves | `/casa-cuna/adoptions/{id}/approve` [TBD] | Digital contract generated and signed. Status -> `APPROVED` | Contract template |
| 7 | Follow-up (30/60/90 days) | Push -> `/adoptions/{id}/followup` [TBD] | Photo + status update from adopter. Rescuer confirms wellbeing. | Notification |

**Current state**: Nothing built. No adoption entity, UI, or backend.

**Acceptance Criteria:**
- [ ] FAIL: Rescuer publishes animal with photos and medical history (fix: T1-2)
- [ ] FAIL: Adopter browses and filters listings (fix: T1-2)
- [ ] FAIL: Adopter submits request with questionnaire (fix: T1-2)
- [ ] FAIL: Rescuer reviews, schedules visit, approves/rejects (fix: T1-2)
- [ ] FAIL: Digital adoption contract generated and signed (fix: T2-1)
- [ ] FAIL: Automated follow-up at 30/60/90 days (fix: T2-2)

---

## J4: Vet Subsidy Request & Approval

**Score: 0%** | **Personas**: P05/P06 (request), P03/P04 (treat), P01/P02 (approve) | **Revenue tag**: Revenue-Critical

| Step | User Action | Screen/Route | What Must Happen | Data Required |
|------|------------|-------------|------------------|---------------|
| 1 | Rescuer creates subsidy request | `/vet-subsidy/new` [TBD] | Form: animal, procedure, estimated cost, urgency. Auto-detect municipality by GPS. | Animal entity, GPS, jurisdiction map |
| 2 | System assigns to municipality | Background | GPS -> jurisdiction mapping. Routed to correct tenant. Status -> `CREATED` | PostGIS jurisdiction boundaries |
| 3 | Coordinator receives request | Push -> `/subsidy/review/{id}` [TBD] | Request with animal details, vet estimate, rescuer history. | Municipal dashboard |
| 4 | Coordinator approves/rejects | `/subsidy/review/{id}` [TBD] | Approve with budget or reject with reason. Auto-expire if no response. Status -> `APPROVED`/`REJECTED` | Budget, authority |
| 5 | Vet receives authorization | Push -> `/vet/subsidy/{id}` [TBD] | Approved subsidy with authorized amount, procedure details. | Vet profile |
| 6 | Vet performs and records treatment | `/vet/patients/{animalId}/treatment` [TBD] | Medical record: diagnosis, treatment, medications, photos. Invoice generated. | Medical record entity |
| 7 | Vet submits invoice | `/vet/subsidy/{id}/invoice` [TBD] | Digital invoice submitted to municipality. | Invoice entity |
| 8 | Municipality processes payment | `/subsidy/{id}/payment` [TBD] | Payment confirmation. Status -> `PAID`. Audit trail complete. | Municipal payment |

**Current state**: Nothing built. Extensively specified in `design.md` (TypeScript interfaces, workflow states, engine class) but zero implementation.

**Acceptance Criteria:**
- [ ] FAIL: Rescuer creates subsidy request in <5 minutes (fix: T0-4)
- [ ] FAIL: System auto-assigns to correct municipality by GPS (fix: T0-9, T0-4)
- [ ] FAIL: Coordinator approves/rejects within the app (fix: T0-5)
- [ ] FAIL: Auto-expires if no response within configured hours (fix: T0-4)
- [ ] FAIL: Vet receives authorization and records treatment (fix: T0-8, T1-5)
- [ ] FAIL: Digital invoice submitted and tracked to payment (fix: T1-7)
- [ ] FAIL: Complete audit trail from request to payment (fix: T0-4)

---

## J5: Abuse Reporting (Authenticated)

**Score: 5%** | **Personas**: P07, P01, P02, P06 | **Revenue tag**: Revenue-Critical

| Step | User Action | Screen/Route | What Must Happen | Data Required |
|------|------------|-------------|------------------|---------------|
| 1 | User opens abuse report form (login required) | `/report-abuse` [TBD] | Form: GPS, photos, description, type of abuse. Must be authenticated. | Auth, GPS, camera |
| 2 | Submits and receives tracking code | `/report-abuse/confirmation` [TBD] | Unique tracking code generated. Report saved. Status -> `FILED` | Authenticated user |
| 3 | System routes to jurisdiction | Background | GPS -> municipal jurisdiction. Report appears in dashboard. | Jurisdiction boundaries |
| 4 | Municipal official reviews/classifies | `/b2g/reports/{id}` [TBD] | Categorize (neglect, abuse, abandonment), assign priority, assign investigator. | Municipal dashboard |
| 5 | Status visible via tracking code | `/report-abuse/track/{code}` [TBD] | Check status: Filed -> Under Review -> Investigated -> Resolved. | Tracking code |
| 6 | Case resolution and metrics | Municipal dashboard | Case closed with outcome. Metrics aggregated. | Resolution data |

**Current state**: `CaptureRequest` entity (8 cols) not designed for abuse reports. B2G controller has 3 Inertia stubs with no data. No mobile abuse report form.

**Acceptance Criteria:**
- [ ] FAIL: Authenticated user files abuse report with GPS + photos in <3 minutes (fix: T0-6)
- [ ] FAIL: Tracking code issued immediately (fix: T0-6)
- [ ] FAIL: Report auto-routes to correct municipality by GPS (fix: T0-9)
- [ ] FAIL: Municipal official reviews, classifies, and tracks reports (fix: T0-7)
- [ ] FAIL: User checks status using tracking code (fix: T0-6)

---

## J6: Casa Cuna & Animal Management

**Score: 10%** | **Personas**: P05, P06 | **Revenue tag**: Value-Delivery

| Step | User Action | Screen/Route | What Must Happen | Data Required |
|------|------------|-------------|------------------|---------------|
| 1 | Register casa cuna | `/profile/foster-homes` (stub exists) | Location, capacity, species accepted, photos | GPS, entity |
| 2 | Add animal | `/casa-cuna/animals/new` [TBD] | Profile: species, breed, age, photos, initial medical assessment | Animal entity |
| 3 | Update animal status | `/casa-cuna/animals/{id}` [TBD] | Medical notes, weight, behavior, adoptability score | Animal entity |
| 4 | Manage capacity | `/profile/foster-homes` | Current inventory, available spots, needs list for donors | Casa cuna + animals |
| 5 | Publish needs list | `/casa-cuna/needs` [TBD] | Food, medicine, supplies, toys needed. Visible to donors (P10). | Needs list entity |

**Current state**: `foster_homes_management_page.dart` exists as UI shell with buttons but no backend calls. No Animal entity in DB.

**Acceptance Criteria:**
- [ ] FAIL: Register foster home with location and capacity (fix: T0-2)
- [ ] FAIL: Add/remove animals with photos and medical notes (fix: T0-1, T0-2)
- [ ] FAIL: Inventory view shows current animals and available spots (fix: T0-2)
- [ ] FAIL: Needs list published and visible to donors (fix: T0-2)

---

## J7: Municipal Dashboard & Reporting

**Score: 5%** | **Personas**: P01, P02 | **Revenue tag**: Revenue-Critical

| Step | User Action | Screen/Route | What Must Happen | Data Required |
|------|------------|-------------|------------------|---------------|
| 1 | Log into web dashboard | `/b2g` (Inertia stub exists) | Secure login, multi-tenant isolation, jurisdiction-scoped | JWT + tenant |
| 2 | View activity overview | `/b2g/dashboard` [TBD] | KPIs: rescue count, subsidy spend, abuse reports, adoption rate | Aggregated metrics |
| 3 | Review pending items | `/b2g/captures` (stub exists) | Pending subsidies + abuse reports with urgency and amounts | Entity data |
| 4 | Generate transparency report | `/b2g/reports` [TBD] | Configurable by date range, metric selection, export PDF/Excel | Report engine |

**Current state**: 3 Inertia route stubs (`/b2g`, `/b2g/captures`, `/b2g/captures/:id`) render empty shells.

**Acceptance Criteria:**
- [ ] FAIL: Dashboard shows jurisdiction-scoped KPIs from available data (fix: T0-7)
- [ ] FAIL: Pending items queue is actionable (approve/reject inline) (fix: T0-5)
- [ ] FAIL: Transparency report exportable as PDF (fix: T1-9)

---

## J8: Donation & Impact Tracking

**Score: 8%** | **Personas**: P10, P06 | **Revenue tag**: Value-Delivery

| Step | User Action | Screen/Route | What Must Happen | Data Required |
|------|------------|-------------|------------------|---------------|
| 1 | Find rescue org profile | `/organizations/{id}` (exists) | Org profile with mission, animals, needs list, transparency score | Org entity (exists) |
| 2 | View needs list | `/organizations/{id}/needs` [TBD] | Rescue org's current needs: food, medicine, supplies, cash amounts | Needs list from J6 |
| 3 | Initiate donation | `/donate/{orgId}` [TBD] | Select type (cash/in-kind), amount/items. Redirect to SINPE/bank (peer-to-peer). | Org bank details |
| 4 | Confirm donation in app | `/donate/{orgId}/confirm` [TBD] | Mark as sent. Org confirms receipt. Recorded in platform. | Donation record |
| 5 | See impact report | `/donor/impact` [TBD] | Dashboard: total donated, animals helped, specific stories | Impact data |

**Current state**: Payment gateway infrastructure exists (4 implementations). Organization profiles exist. No donation UI, entity, or impact tracking.

**Acceptance Criteria:**
- [ ] FAIL: Donor sees org's needs list (cash + in-kind) (fix: T0-2 needs list)
- [ ] FAIL: Peer-to-peer donation without AltruPets touching funds (fix: T1-8)
- [ ] FAIL: Donation recorded in platform (fix: T1-8)
- [ ] FAIL: Impact report shows animals helped per donation (fix: T2-3)

---

## J9: Vet Clinic Onboarding -> Premium Conversion

**Score: 0%** | **Personas**: P03, P04 | **Revenue tag**: Revenue-Critical

| Step | User Action | Screen/Route | What Must Happen | Data Required |
|------|------------|-------------|------------------|---------------|
| 1 | Register with credentials | `/register` (exists, role selection) | Extended: license, specialties, clinic info, location | Vet profile entity |
| 2 | Complete clinic profile | `/vet/clinic/setup` [TBD] | Name, hours, services, pricing, photos, map pin | Vet clinic entity |
| 3 | Receive first subsidy request | Push -> `/vet/subsidy/{id}` [TBD] | Subsidy with animal details, authorized amount, rescuer info | J4 working |
| 4 | Shown upgrade prompt | In-app prompt | "5+ subsidized cases this month. Upgrade for preferred placement." | Usage tracking |
| 5 | Subscribe to paid plan | `/vet/clinic/subscription` [TBD] | Payment via SINPE/card. Subscription activated. Premium unlocked. | Payment |

**Current state**: Registration has Veterinarian role. Nothing else built.

**Acceptance Criteria:**
- [ ] FAIL: Register with professional credentials and clinic info (fix: T0-8)
- [ ] FAIL: Appears in proximity searches for rescuers (fix: T0-8, T0-9)
- [ ] FAIL: Usage-based upgrade prompt at threshold (fix: T2-4)
- [ ] FAIL: Subscribe to paid plan via SINPE/card (fix: T1-16)

---

## J10: Real-time Chat & Notifications

**Score: 20%** | **Personas**: ALL active | **Revenue tag**: Value-Delivery

| Step | User Action | Screen/Route | What Must Happen | Data Required |
|------|------------|-------------|------------------|---------------|
| 1 | Event triggers chat room | Automatic | Rescue/subsidy/adoption event creates chat with participants | Firebase entity |
| 2 | Exchange messages | `/messages/{chatId}` (partially exists) | Real-time text, photos, GPS sharing. Read receipts. | Firebase |
| 3 | Push notifications | System push | Preview notification, tap opens conversation | Firebase Messaging |
| 4 | Archive on completion | Automatic | Case closes -> chat archived and linked to case history | Case status |

**Current state**: Firebase Firestore messaging partially implemented. Deep links exist. Not integrated with workflows. No push notifications.

**Acceptance Criteria:**
- [x] PASS: Users send/receive messages in real-time
- [ ] FAIL: Chat rooms auto-created for rescue/subsidy events (fix: T1-4)
- [ ] FAIL: Push notifications for new messages (fix: T1-3)
- [ ] FAIL: Chat archived and linked to case on completion (fix: T2-4)
