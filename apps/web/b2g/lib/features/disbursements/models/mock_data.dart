import 'subsidy_request_model.dart';

/// Mock budget status matching the HTML mockup.
const mockBudgetStatus = BudgetStatusModel(
  monthlyBudget: 500000,
  disbursed: 115000,
  available: 385000,
  usagePercent: 23,
  totalRequests: 12,
  approvedCount: 9,
  inReviewCount: 2,
  rejectedCount: 1,
  daysRemainingInMonth: 23,
);

/// 5 rule results all passing — for the auto-eligible requests.
const _allRulesPassed = [
  RuleResultModel(
    ruleType: 'VERIFIED_RESCUER',
    passed: true,
    reason: 'Rescatista verificada',
    detail: 'Sofia Mora - 12 rescates - Activa hace 8 meses',
  ),
  RuleResultModel(
    ruleType: 'REGISTERED_ANIMAL',
    passed: true,
    reason: 'Animal registrado',
    detail: 'Michi - Gato - 2 anos - ALT-A-0847 - Fractura pata trasera',
  ),
  RuleResultModel(
    ruleType: 'AUTHORIZED_VET',
    passed: true,
    reason: 'Veterinaria autorizada',
    detail: 'Clinica Dr. Carlos - Heredia centro - 4.8 estrellas',
  ),
  RuleResultModel(
    ruleType: 'WITHIN_BUDGET',
    passed: true,
    reason: 'Dentro de presupuesto',
    detail: '\u20A145,000 solicitados - \u20A1385,000 disponibles de \u20A1500,000 mensuales',
  ),
  RuleResultModel(
    ruleType: 'NO_DUPLICATE',
    passed: true,
    reason: 'Sin solicitudes duplicadas',
    detail: 'Ultima solicitud para este animal: hace 45 dias',
  ),
];

/// Rule results with one failure (vet not verified).
const _someRulesFailed = [
  RuleResultModel(
    ruleType: 'VERIFIED_RESCUER',
    passed: true,
    reason: 'Rescatista verificado',
    detail: 'Miguel Ramirez - 5 rescates',
  ),
  RuleResultModel(
    ruleType: 'REGISTERED_ANIMAL',
    passed: true,
    reason: 'Animal registrado',
    detail: 'Rocky - Perro - Microchip: 900118000123456',
  ),
  RuleResultModel(
    ruleType: 'AUTHORIZED_VET',
    passed: false,
    reason: 'Veterinaria no verificada',
    detail: 'Vet. Santa Rosa - Pendiente verificacion SENASA',
  ),
  RuleResultModel(
    ruleType: 'WITHIN_BUDGET',
    passed: true,
    reason: 'Dentro de presupuesto',
    detail: '\u20A1120,000 solicitados - \u20A1385,000 disponibles',
  ),
  RuleResultModel(
    ruleType: 'NO_DUPLICATE',
    passed: true,
    reason: 'Sin solicitudes duplicadas',
  ),
];

/// Rule results with critical failure (rescuer not verified).
const _criticalRulesFailed = [
  RuleResultModel(
    ruleType: 'VERIFIED_RESCUER',
    passed: false,
    reason: 'Rescatista no verificada',
    detail: 'Pedro Vargas - Sin verificacion',
  ),
  RuleResultModel(
    ruleType: 'REGISTERED_ANIMAL',
    passed: false,
    reason: 'Animal sin microchip ni casa cuna',
    detail: 'Max - Perro - Sin registro oficial',
  ),
  RuleResultModel(
    ruleType: 'AUTHORIZED_VET',
    passed: true,
    reason: 'Veterinaria autorizada',
    detail: 'Vet. Mercedes',
  ),
  RuleResultModel(
    ruleType: 'WITHIN_BUDGET',
    passed: true,
    reason: 'Dentro de presupuesto',
  ),
  RuleResultModel(
    ruleType: 'NO_DUPLICATE',
    passed: true,
    reason: 'Sin solicitudes duplicadas',
  ),
];

/// Mock pending requests matching the HTML mockup.
final mockPendingRequests = [
  SubsidyRequestModel(
    id: '1',
    trackingCode: 'DV-2026-0847',
    animalName: 'Michi',
    animalEmoji: '\uD83D\uDC31', // cat
    requesterName: 'Sofia Mora',
    diagnosis: 'Gato, fractura pata',
    vetClinicName: 'Clinica Dr. Carlos',
    amountRequested: 45000,
    status: SubsidyRequestStatus.created,
    urgency: RequestUrgency.autoEligible,
    procedureType: ProcedureType.surgery,
    createdAt: DateTime.now().subtract(const Duration(minutes: 23)),
    ruleResults: _allRulesPassed,
  ),
  SubsidyRequestModel(
    id: '2',
    trackingCode: 'DV-2026-0848',
    animalName: 'Rocky',
    animalEmoji: '\uD83D\uDC15', // dog
    requesterName: 'Miguel R.',
    diagnosis: 'Perro, atropellado',
    vetClinicName: 'Vet. Santa Rosa',
    amountRequested: 120000,
    status: SubsidyRequestStatus.inReview,
    urgency: RequestUrgency.manualReview,
    procedureType: ProcedureType.emergency,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ruleResults: _someRulesFailed,
  ),
  SubsidyRequestModel(
    id: '3',
    trackingCode: 'DV-2026-0849',
    animalName: 'Luna',
    animalEmoji: '\uD83D\uDC31', // cat
    requesterName: 'Ana L.',
    diagnosis: 'Gata, prenada',
    vetClinicName: 'Clinica Dr. Carlos',
    amountRequested: 35000,
    status: SubsidyRequestStatus.created,
    urgency: RequestUrgency.autoEligible,
    procedureType: ProcedureType.consultation,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ruleResults: _allRulesPassed,
  ),
  SubsidyRequestModel(
    id: '4',
    trackingCode: 'DV-2026-0850',
    animalName: 'Max',
    animalEmoji: '\uD83D\uDC15', // dog
    requesterName: 'Pedro V.',
    diagnosis: 'Perro, sarna severa',
    vetClinicName: 'Vet. Mercedes',
    amountRequested: 85000,
    status: SubsidyRequestStatus.inReview,
    urgency: RequestUrgency.needsVerification,
    procedureType: ProcedureType.consultation,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ruleResults: _criticalRulesFailed,
  ),
];

/// Mock approved requests for the "Aprobadas" tab.
final mockApprovedRequests = [
  SubsidyRequestModel(
    id: '10',
    trackingCode: 'DV-2026-0830',
    animalName: 'Canela',
    animalEmoji: '\uD83D\uDC15',
    requesterName: 'Maria F.',
    diagnosis: 'Perro, esterilizacion',
    vetClinicName: 'Clinica Dr. Carlos',
    amountRequested: 42000,
    status: SubsidyRequestStatus.approved,
    urgency: RequestUrgency.autoEligible,
    procedureType: ProcedureType.sterilization,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    autoApproved: true,
    ruleResults: _allRulesPassed,
  ),
  SubsidyRequestModel(
    id: '11',
    trackingCode: 'DV-2026-0831',
    animalName: 'Pelusa',
    animalEmoji: '\uD83D\uDC31',
    requesterName: 'Carlos M.',
    diagnosis: 'Gato, vacunacion',
    vetClinicName: 'Vet. Santa Rosa',
    amountRequested: 15000,
    status: SubsidyRequestStatus.approved,
    urgency: RequestUrgency.autoEligible,
    procedureType: ProcedureType.vaccination,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    autoApproved: true,
    ruleResults: _allRulesPassed,
  ),
];
