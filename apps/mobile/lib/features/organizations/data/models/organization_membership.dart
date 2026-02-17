import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_membership.freezed.dart';
part 'organization_membership.g.dart';

enum MembershipStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('REVOKED')
  revoked,
}

enum OrganizationRole {
  @JsonValue('LEGAL_REPRESENTATIVE')
  legalRepresentative,
  @JsonValue('USER_ADMIN')
  userAdmin,
  @JsonValue('MEMBER')
  member,
}

@freezed
class OrganizationMembership with _$OrganizationMembership {
  const factory OrganizationMembership({
    required String id,
    required String organizationId,
    required String userId,
    required MembershipStatus status,
    required OrganizationRole role,
    String? requestMessage,
    String? rejectionReason,
    String? approvedBy,
    DateTime? approvedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OrganizationMembership;

  factory OrganizationMembership.fromJson(Map<String, dynamic> json) =>
      _$OrganizationMembershipFromJson(json);
}
