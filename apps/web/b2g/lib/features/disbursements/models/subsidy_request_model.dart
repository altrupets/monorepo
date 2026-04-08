/// Status of a subsidy request.
enum SubsidyRequestStatus {
  created,
  inReview,
  approved,
  rejected,
  expired,
  paid,
}

/// Type of veterinary procedure.
enum ProcedureType {
  sterilization,
  vaccination,
  emergency,
  surgery,
  consultation,
  deworming,
  other,
}

/// Urgency level inferred from rule evaluation results.
enum RequestUrgency {
  /// All rules pass — auto-approval available
  autoEligible,

  /// Some rules fail — manual review needed
  manualReview,

  /// Critical rules fail — needs investigation
  needsVerification,
}

/// Lightweight model for display in the Flutter B2G dashboard.
/// Uses mock data for now; will be replaced by GraphQL DTOs in Phase 6.
class SubsidyRequestModel {
  final String id;
  final String trackingCode;
  final String animalName;
  final String animalEmoji;
  final String requesterName;
  final String diagnosis;
  final String vetClinicName;
  final double amountRequested;
  final SubsidyRequestStatus status;
  final RequestUrgency urgency;
  final ProcedureType procedureType;
  final DateTime createdAt;
  final bool? autoApproved;
  final String? rejectionReason;
  final List<RuleResultModel> ruleResults;

  const SubsidyRequestModel({
    required this.id,
    required this.trackingCode,
    required this.animalName,
    required this.animalEmoji,
    required this.requesterName,
    required this.diagnosis,
    required this.vetClinicName,
    required this.amountRequested,
    required this.status,
    required this.urgency,
    required this.procedureType,
    required this.createdAt,
    this.autoApproved,
    this.rejectionReason,
    this.ruleResults = const [],
  });

  /// Human-readable time ago string.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }

  /// Format amount in Costa Rican colones.
  String get formattedAmount {
    if (amountRequested >= 1000) {
      return '\u20A1${(amountRequested / 1000).toStringAsFixed(0)}K';
    }
    return '\u20A1${amountRequested.toStringAsFixed(0)}';
  }
}

/// Result of a single rule evaluation.
class RuleResultModel {
  final String ruleType;
  final bool passed;
  final String reason;
  final String? detail;

  const RuleResultModel({
    required this.ruleType,
    required this.passed,
    required this.reason,
    this.detail,
  });
}

/// Budget status for KPI display.
class BudgetStatusModel {
  final double monthlyBudget;
  final double disbursed;
  final double available;
  final double usagePercent;
  final int totalRequests;
  final int approvedCount;
  final int inReviewCount;
  final int rejectedCount;
  final int daysRemainingInMonth;

  const BudgetStatusModel({
    required this.monthlyBudget,
    required this.disbursed,
    required this.available,
    required this.usagePercent,
    required this.totalRequests,
    required this.approvedCount,
    required this.inReviewCount,
    required this.rejectedCount,
    required this.daysRemainingInMonth,
  });
}
