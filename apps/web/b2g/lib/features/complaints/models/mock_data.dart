import 'abuse_report_model.dart';

/// Mock metrics matching the complaints dashboard KPI cards.
const mockComplaintMetrics = AbuseReportMetricsModel(
  totalReports: 23,
  avgResponseTimeHours: 4.2,
  resolutionRate: 0.57,
  pendingClassification: 2,
  underInvestigation: 8,
  resolved: 13,
  scheduledVisits: 5,
);

/// 4 mock abuse reports as specified.
final mockAbuseReports = <AbuseReportModel>[
  // 1. FILED — "Perros encadenados sin agua" — HIGH, Barrio Fatima, 2 photos
  AbuseReportModel(
    id: 'ar-1',
    trackingCode: 'DEN-2026-0001',
    status: AbuseReportStatus.filed,
    abuseTypes: [AbuseType.permanentChaining, AbuseType.negligence],
    description:
        'Se observan 3 perros encadenados permanentemente sin acceso a agua ni sombra. '
        'Los animales estan en condiciones visiblemente deterioradas, con heridas en el cuello '
        'por las cadenas. Situacion observada durante varias semanas.',
    locationProvince: 'Heredia',
    locationCanton: 'Heredia',
    locationDistrict: 'Heredia',
    locationAddress: 'Barrio Fatima, 200m sur de la iglesia, casa color celeste',
    latitude: 9.9981,
    longitude: -84.1198,
    evidenceUrls: [
      'https://storage.altrupets.org/evidence/ar-1-foto1.jpg',
      'https://storage.altrupets.org/evidence/ar-1-foto2.jpg',
    ],
    privacyMode: PrivacyMode.confidential,
    priority: AbuseReportPriority.high,
    reporterInitials: 'A.M.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
  ),

  // 2. CLASSIFIED — "Gato herido abandonado" — MEDIUM, Mercedes Norte
  AbuseReportModel(
    id: 'ar-2',
    trackingCode: 'DEN-2026-0002',
    status: AbuseReportStatus.classified,
    abuseTypes: [AbuseType.abandonment],
    description:
        'Gato adulto con herida abierta en la pata trasera, abandonado en un lote baldio. '
        'El animal no puede caminar y lleva al menos 2 dias en el sitio segun vecinos.',
    locationProvince: 'Heredia',
    locationCanton: 'Heredia',
    locationDistrict: 'Mercedes',
    locationAddress: 'Mercedes Norte, frente al minisuper La Esquina',
    latitude: 10.0012,
    longitude: -84.1156,
    evidenceUrls: [
      'https://storage.altrupets.org/evidence/ar-2-foto1.jpg',
    ],
    privacyMode: PrivacyMode.public_,
    priority: AbuseReportPriority.medium,
    classifiedAs: 'Abandono con lesiones',
    reporterInitials: 'C.V.',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),

  // 3. UNDER_INVESTIGATION — "Acumulacion de animales" — assigned to inspector
  AbuseReportModel(
    id: 'ar-3',
    trackingCode: 'DEN-2026-0003',
    status: AbuseReportStatus.underInvestigation,
    abuseTypes: [AbuseType.hoarding, AbuseType.unsanitaryConditions],
    description:
        'Vivienda con mas de 30 gatos en condiciones de hacinamiento. '
        'Vecinos reportan malos olores y ruido constante. Los animales se ven desnutridos.',
    locationProvince: 'Heredia',
    locationCanton: 'Heredia',
    locationDistrict: 'San Francisco',
    locationAddress: 'San Francisco de Heredia, Residencial Los Pinos, casa 14',
    latitude: 9.9945,
    longitude: -84.1230,
    evidenceUrls: [
      'https://storage.altrupets.org/evidence/ar-3-foto1.jpg',
      'https://storage.altrupets.org/evidence/ar-3-foto2.jpg',
      'https://storage.altrupets.org/evidence/ar-3-foto3.jpg',
    ],
    privacyMode: PrivacyMode.anonymous,
    priority: AbuseReportPriority.high,
    classifiedAs: 'Acumulacion compulsiva',
    assignedToName: 'Inspector Rodriguez',
    reporterInitials: null,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),

  // 4. RESOLVED — "Envenenamiento sospechado"
  AbuseReportModel(
    id: 'ar-4',
    trackingCode: 'DEN-2026-0004',
    status: AbuseReportStatus.resolved,
    abuseTypes: [AbuseType.suspectedPoisoning],
    description:
        'Tres perros del vecindario murieron en un periodo de 2 dias. '
        'Los vecinos sospechan envenenamiento intencional con comida contaminada.',
    locationProvince: 'Heredia',
    locationCanton: 'Heredia',
    locationDistrict: 'Ulloa',
    locationAddress: 'Barrio El Carmen, Ulloa de Heredia',
    latitude: 9.9890,
    longitude: -84.1100,
    evidenceUrls: [],
    privacyMode: PrivacyMode.confidential,
    priority: AbuseReportPriority.critical,
    classifiedAs: 'Envenenamiento intencional',
    assignedToName: 'Inspector Mora',
    resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
    resolutionNotes:
        'Se coordino con OIJ. Se identifico al responsable y se presento denuncia penal. '
        'Los animales restantes del vecindario fueron evaluados por veterinario.',
    reporterInitials: 'L.G.',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
];

/// Convenience getters for tabs.
List<AbuseReportModel> get mockFiledReports =>
    mockAbuseReports.where((r) => r.status == AbuseReportStatus.filed).toList();

List<AbuseReportModel> get mockInvestigationReports => mockAbuseReports
    .where((r) =>
        r.status == AbuseReportStatus.classified ||
        r.status == AbuseReportStatus.underInvestigation)
    .toList();

List<AbuseReportModel> get mockResolvedReports => mockAbuseReports
    .where((r) =>
        r.status == AbuseReportStatus.resolved ||
        r.status == AbuseReportStatus.closed)
    .toList();
