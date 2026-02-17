// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationMembershipImpl _$$OrganizationMembershipImplFromJson(
  Map<String, dynamic> json,
) => _$OrganizationMembershipImpl(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  userId: json['userId'] as String,
  status: $enumDecode(_$MembershipStatusEnumMap, json['status']),
  role: $enumDecode(_$OrganizationRoleEnumMap, json['role']),
  requestMessage: json['requestMessage'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
  approvedBy: json['approvedBy'] as String?,
  approvedAt: json['approvedAt'] == null
      ? null
      : DateTime.parse(json['approvedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$OrganizationMembershipImplToJson(
  _$OrganizationMembershipImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'userId': instance.userId,
  'status': _$MembershipStatusEnumMap[instance.status]!,
  'role': _$OrganizationRoleEnumMap[instance.role]!,
  'requestMessage': instance.requestMessage,
  'rejectionReason': instance.rejectionReason,
  'approvedBy': instance.approvedBy,
  'approvedAt': instance.approvedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.pending: 'PENDING',
  MembershipStatus.approved: 'APPROVED',
  MembershipStatus.rejected: 'REJECTED',
  MembershipStatus.revoked: 'REVOKED',
};

const _$OrganizationRoleEnumMap = {
  OrganizationRole.legalRepresentative: 'LEGAL_REPRESENTATIVE',
  OrganizationRole.userAdmin: 'USER_ADMIN',
  OrganizationRole.member: 'MEMBER',
};
