import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization.freezed.dart';
part 'organization.g.dart';

enum OrganizationType {
  @JsonValue('FOUNDATION')
  foundation,
  @JsonValue('ASSOCIATION')
  association,
  @JsonValue('NGO')
  ngo,
  @JsonValue('COOPERATIVE')
  cooperative,
  @JsonValue('GOVERNMENT')
  government,
  @JsonValue('OTHER')
  other,
}

enum OrganizationStatus {
  @JsonValue('PENDING_VERIFICATION')
  pendingVerification,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('INACTIVE')
  inactive,
}

@freezed
class Organization with _$Organization {
  const factory Organization({
    required String id,
    required String name,
    required OrganizationType type,
    String? legalId,
    String? description,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? country,
    String? province,
    String? canton,
    String? district,
    required OrganizationStatus status,
    String? legalRepresentativeId,
    required int memberCount,
    required int maxCapacity,
    required bool isActive,
    required bool isVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
}
