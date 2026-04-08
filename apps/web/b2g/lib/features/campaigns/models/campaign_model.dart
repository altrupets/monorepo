/// Status of a spay/neuter campaign.
enum CampaignStatus {
  draft,
  published,
  registrationOpen,
  registrationClosed,
  inProgress,
  completed,
  archived,
}

/// Status of a campaign registration.
enum RegistrationStatus {
  registered,
  checkedIn,
  operated,
  followUp3d,
  followUp7d,
  followUp14d,
  completed,
}

/// Animal species for campaign registration.
enum AnimalSpecies { dog, cat }

/// Animal sex for campaign registration.
enum AnimalSex { male, female }

/// Lightweight model for a spay/neuter campaign.
/// Uses mock data for now; will be replaced by GraphQL DTOs in Phase 6.
class CampaignModel {
  final String id;
  final String code;
  final String title;
  final String location;
  final CampaignStatus status;
  final int maxCapacity;
  final String surgeryDate;
  final String? promotionDate;
  final String? registrationOpenDate;
  final String? registrationCloseDate;
  final String? orientationDate;
  final double budgetAllocated;
  final double budgetSpent;
  final List<CampaignRegistrationModel> registrations;
  final String? notes;
  final DateTime createdAt;

  const CampaignModel({
    required this.id,
    required this.code,
    required this.title,
    required this.location,
    required this.status,
    required this.maxCapacity,
    required this.surgeryDate,
    this.promotionDate,
    this.registrationOpenDate,
    this.registrationCloseDate,
    this.orientationDate,
    required this.budgetAllocated,
    required this.budgetSpent,
    this.registrations = const [],
    this.notes,
    required this.createdAt,
  });

  /// Returns the number of registrations.
  int get registrationCount => registrations.length;

  /// Returns the number of operated animals.
  int get operatedCount => registrations
      .where((r) =>
          r.status == RegistrationStatus.operated ||
          r.status == RegistrationStatus.followUp3d ||
          r.status == RegistrationStatus.followUp7d ||
          r.status == RegistrationStatus.followUp14d ||
          r.status == RegistrationStatus.completed)
      .length;

  /// Returns the stepper step index (0-4).
  int get activeStepIndex {
    switch (status) {
      case CampaignStatus.draft:
      case CampaignStatus.published:
        return 0; // Plan
      case CampaignStatus.registrationOpen:
        return 2; // Inscripcion
      case CampaignStatus.registrationClosed:
        return 2; // Inscripcion (closing)
      case CampaignStatus.inProgress:
        return 3; // Cirugia
      case CampaignStatus.completed:
      case CampaignStatus.archived:
        return 4; // Seguimiento
    }
  }

  /// Number of completed steps (for the stepper).
  int get completedSteps {
    switch (status) {
      case CampaignStatus.draft:
        return 0;
      case CampaignStatus.published:
        return 1;
      case CampaignStatus.registrationOpen:
        return 2;
      case CampaignStatus.registrationClosed:
        return 3;
      case CampaignStatus.inProgress:
        return 3;
      case CampaignStatus.completed:
      case CampaignStatus.archived:
        return 5;
    }
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case CampaignStatus.draft:
        return 'EN PLANIFICACION';
      case CampaignStatus.published:
        return 'PUBLICADA';
      case CampaignStatus.registrationOpen:
        return 'INSCRIPCION ABIERTA';
      case CampaignStatus.registrationClosed:
        return 'INSCRIPCION CERRADA';
      case CampaignStatus.inProgress:
        return 'EN PROGRESO';
      case CampaignStatus.completed:
        return 'COMPLETADA';
      case CampaignStatus.archived:
        return 'ARCHIVADA';
    }
  }

  /// Format budget amount in Costa Rican colones.
  String get formattedBudget {
    if (budgetAllocated >= 1000) {
      return '\u20A1${(budgetAllocated / 1000).toStringAsFixed(0)}K';
    }
    return '\u20A1${budgetAllocated.toStringAsFixed(0)}';
  }

  /// Days until surgery.
  int get daysUntilSurgery {
    final surgery = DateTime.parse(surgeryDate);
    return surgery.difference(DateTime.now()).inDays;
  }
}

/// Model for a single campaign registration.
class CampaignRegistrationModel {
  final String id;
  final String ownerName;
  final String ownerPhone;
  final String animalName;
  final AnimalSpecies animalSpecies;
  final String? animalBreed;
  final String? animalAge;
  final AnimalSex animalSex;
  final RegistrationStatus status;
  final String? operatedByName;
  final DateTime? operatedAt;
  final String? notes;
  final DateTime createdAt;

  const CampaignRegistrationModel({
    required this.id,
    required this.ownerName,
    required this.ownerPhone,
    required this.animalName,
    required this.animalSpecies,
    this.animalBreed,
    this.animalAge,
    required this.animalSex,
    required this.status,
    this.operatedByName,
    this.operatedAt,
    this.notes,
    required this.createdAt,
  });

  /// Emoji for the animal species.
  String get speciesEmoji =>
      animalSpecies == AnimalSpecies.dog ? '\uD83D\uDC15' : '\uD83D\uDC31';

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case RegistrationStatus.registered:
        return 'Inscrito';
      case RegistrationStatus.checkedIn:
        return 'Presente';
      case RegistrationStatus.operated:
        return 'Operado';
      case RegistrationStatus.followUp3d:
        return 'Seg. 3d';
      case RegistrationStatus.followUp7d:
        return 'Seg. 7d';
      case RegistrationStatus.followUp14d:
        return 'Seg. 14d';
      case RegistrationStatus.completed:
        return 'Completado';
    }
  }
}

/// Campaign metrics for KPI display.
class CampaignMetricsModel {
  final int totalSterilized;
  final double avgCostPerAnimal;
  final int communitiesCovered;
  final int communitiesTotal;
  final int daysUntilNextCampaign;
  final int totalCampaigns;
  final int activeCampaigns;
  final int completedCampaigns;

  const CampaignMetricsModel({
    required this.totalSterilized,
    required this.avgCostPerAnimal,
    required this.communitiesCovered,
    required this.communitiesTotal,
    required this.daysUntilNextCampaign,
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.completedCampaigns,
  });

  /// Format cost in colones.
  String get formattedAvgCost {
    if (avgCostPerAnimal >= 1000) {
      return '\u20A1${(avgCostPerAnimal / 1000).toStringAsFixed(0)}K';
    }
    return '\u20A1${avgCostPerAnimal.toStringAsFixed(0)}';
  }
}
