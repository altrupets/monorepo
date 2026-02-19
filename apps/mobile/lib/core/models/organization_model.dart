import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:altrupets/core/models/user_model.dart';

part 'organization_model.freezed.dart';
part 'organization_model.g.dart';

/// Organization type enum
enum OrganizationType {
  @JsonValue('INDIVIDUAL')
  individual,
  @JsonValue('NGO')
  ngo,
  @JsonValue('GOVERNMENT')
  government,
  @JsonValue('VETERINARY_CLINIC')
  veterinaryClinic,
  @JsonValue('RESCUE_CENTER')
  rescueCenter,
}

/// Organization model
@freezed
class OrganizationModel with _$OrganizationModel {
  const factory OrganizationModel({
    required String id,
    required String name,
    required OrganizationType type,
    required String? description,
    required String? logoUrl,
    required String? website,
    required String? email,
    required String? phoneNumber,
    required String? address,
    required double? latitude,
    required double? longitude,
    required String legalRepresentativeId,
    required bool isVerified,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String? taxId,
    required String? registrationNumber,
  }) = _OrganizationModel;

  factory OrganizationModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizationModelFromJson(json);
}

/// Organization creation request
@freezed
class OrganizationCreateRequest with _$OrganizationCreateRequest {
  const factory OrganizationCreateRequest({
    required String name,
    required OrganizationType type,
    required String? description,
    required String? website,
    required String? email,
    required String? phoneNumber,
    required String? address,
    required double? latitude,
    required double? longitude,
    required String legalRepresentativeId,
    required String? taxId,
    required String? registrationNumber,
  }) = _OrganizationCreateRequest;

  factory OrganizationCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$OrganizationCreateRequestFromJson(json);
}

/// Organization membership model
@freezed
class OrganizationMembership with _$OrganizationMembership {
  const factory OrganizationMembership({
    required String id,
    required String organizationId,
    required String userId,
    required UserRole role,
    required bool isApproved,
    required DateTime joinedAt,
    required DateTime? approvedAt,
    required String? approvedBy,
  }) = _OrganizationMembership;

  factory OrganizationMembership.fromJson(Map<String, dynamic> json) =>
      _$OrganizationMembershipFromJson(json);
}

/// Organization membership request
@freezed
class OrganizationMembershipRequest with _$OrganizationMembershipRequest {
  const factory OrganizationMembershipRequest({
    required String organizationId,
    required String userId,
    required UserRole role,
  }) = _OrganizationMembershipRequest;

  factory OrganizationMembershipRequest.fromJson(Map<String, dynamic> json) =>
      _$OrganizationMembershipRequestFromJson(json);
}
