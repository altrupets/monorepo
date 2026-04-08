/// Status of an abuse report in the workflow.
enum AbuseReportStatus {
  filed,
  classified,
  underInvestigation,
  resolved,
  closed,
}

/// Privacy mode for the reporter identity.
enum PrivacyMode {
  anonymous,
  public_,
  confidential,
}

/// Priority assigned during classification.
enum AbuseReportPriority {
  low,
  medium,
  high,
  critical,
}

/// Abuse type categories based on Anexo A (adapted for animal welfare).
enum AbuseType {
  physicalAbuse,
  negligence,
  abandonment,
  hoarding,
  permanentChaining,
  unsanitaryConditions,
  suspectedPoisoning,
  animalFighting,
  other,
}

/// Extension to get human-readable labels for abuse types.
extension AbuseTypeLabel on AbuseType {
  String get label {
    switch (this) {
      case AbuseType.physicalAbuse:
        return 'Maltrato fisico';
      case AbuseType.negligence:
        return 'Negligencia';
      case AbuseType.abandonment:
        return 'Abandono';
      case AbuseType.hoarding:
        return 'Acumulacion de animales';
      case AbuseType.permanentChaining:
        return 'Encadenados permanentemente';
      case AbuseType.unsanitaryConditions:
        return 'Condiciones insalubres';
      case AbuseType.suspectedPoisoning:
        return 'Envenenamiento sospechado';
      case AbuseType.animalFighting:
        return 'Peleas de animales';
      case AbuseType.other:
        return 'Otro';
    }
  }

  String get code {
    switch (this) {
      case AbuseType.physicalAbuse:
        return 'PHYSICAL_ABUSE';
      case AbuseType.negligence:
        return 'NEGLIGENCE';
      case AbuseType.abandonment:
        return 'ABANDONMENT';
      case AbuseType.hoarding:
        return 'HOARDING';
      case AbuseType.permanentChaining:
        return 'PERMANENT_CHAINING';
      case AbuseType.unsanitaryConditions:
        return 'UNSANITARY_CONDITIONS';
      case AbuseType.suspectedPoisoning:
        return 'SUSPECTED_POISONING';
      case AbuseType.animalFighting:
        return 'ANIMAL_FIGHTING';
      case AbuseType.other:
        return 'OTHER';
    }
  }
}

/// Lightweight model for an abuse report.
/// Uses mock data for now; will be replaced by GraphQL DTOs later.
class AbuseReportModel {
  final String id;
  final String trackingCode;
  final AbuseReportStatus status;
  final List<AbuseType> abuseTypes;
  final String description;
  final String locationProvince;
  final String locationCanton;
  final String locationDistrict;
  final String locationAddress;
  final double? latitude;
  final double? longitude;
  final List<String> evidenceUrls;
  final PrivacyMode privacyMode;
  final AbuseReportPriority priority;
  final String? classifiedAs;
  final String? assignedToName;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final String? reporterInitials;
  final DateTime createdAt;

  const AbuseReportModel({
    required this.id,
    required this.trackingCode,
    required this.status,
    required this.abuseTypes,
    required this.description,
    required this.locationProvince,
    required this.locationCanton,
    required this.locationDistrict,
    required this.locationAddress,
    this.latitude,
    this.longitude,
    this.evidenceUrls = const [],
    required this.privacyMode,
    required this.priority,
    this.classifiedAs,
    this.assignedToName,
    this.resolvedAt,
    this.resolutionNotes,
    this.reporterInitials,
    required this.createdAt,
  });

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case AbuseReportStatus.filed:
        return 'REQUIERE CLASIFICACION';
      case AbuseReportStatus.classified:
        return 'CLASIFICADA';
      case AbuseReportStatus.underInvestigation:
        return 'EN INVESTIGACION';
      case AbuseReportStatus.resolved:
        return 'RESUELTA';
      case AbuseReportStatus.closed:
        return 'CERRADA';
    }
  }

  /// Human-readable priority label.
  String get priorityLabel {
    switch (priority) {
      case AbuseReportPriority.low:
        return 'BAJA';
      case AbuseReportPriority.medium:
        return 'MEDIA';
      case AbuseReportPriority.high:
        return 'ALTA';
      case AbuseReportPriority.critical:
        return 'CRITICA';
    }
  }

  /// Summary of abuse types.
  String get abuseTypeSummary =>
      abuseTypes.map((t) => t.label).join(', ');

  /// Short location string.
  String get shortLocation => '$locationDistrict, $locationCanton';

  /// Time ago string.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }

  /// Whether this report has GPS coordinates.
  bool get hasGps => latitude != null && longitude != null;

  /// Number of evidence items.
  int get evidenceCount => evidenceUrls.length;
}

/// Metrics for the KPI bar in the complaints dashboard.
class AbuseReportMetricsModel {
  final int totalReports;
  final double avgResponseTimeHours;
  final double resolutionRate;
  final int pendingClassification;
  final int underInvestigation;
  final int resolved;
  final int scheduledVisits;

  const AbuseReportMetricsModel({
    required this.totalReports,
    required this.avgResponseTimeHours,
    required this.resolutionRate,
    required this.pendingClassification,
    required this.underInvestigation,
    required this.resolved,
    required this.scheduledVisits,
  });

  /// Format resolution rate as percentage string.
  String get formattedResolutionRate =>
      '${(resolutionRate * 100).toStringAsFixed(0)}%';

  /// Format response time.
  String get formattedResponseTime =>
      '${avgResponseTimeHours.toStringAsFixed(1)}h';
}
