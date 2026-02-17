// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationModelImpl _$$OrganizationModelImplFromJson(
  Map<String, dynamic> json,
) => _$OrganizationModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$OrganizationTypeEnumMap, json['type']),
  description: json['description'] as String?,
  logoUrl: json['logoUrl'] as String?,
  website: json['website'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  legalRepresentativeId: json['legalRepresentativeId'] as String,
  isVerified: json['isVerified'] as bool,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  taxId: json['taxId'] as String?,
  registrationNumber: json['registrationNumber'] as String?,
);

Map<String, dynamic> _$$OrganizationModelImplToJson(
  _$OrganizationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$OrganizationTypeEnumMap[instance.type]!,
  'description': instance.description,
  'logoUrl': instance.logoUrl,
  'website': instance.website,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'legalRepresentativeId': instance.legalRepresentativeId,
  'isVerified': instance.isVerified,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'taxId': instance.taxId,
  'registrationNumber': instance.registrationNumber,
};

const _$OrganizationTypeEnumMap = {
  OrganizationType.individual: 'INDIVIDUAL',
  OrganizationType.ngo: 'NGO',
  OrganizationType.government: 'GOVERNMENT',
  OrganizationType.veterinaryClinic: 'VETERINARY_CLINIC',
  OrganizationType.rescueCenter: 'RESCUE_CENTER',
};

_$OrganizationCreateRequestImpl _$$OrganizationCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$OrganizationCreateRequestImpl(
  name: json['name'] as String,
  type: $enumDecode(_$OrganizationTypeEnumMap, json['type']),
  description: json['description'] as String?,
  website: json['website'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  legalRepresentativeId: json['legalRepresentativeId'] as String,
  taxId: json['taxId'] as String?,
  registrationNumber: json['registrationNumber'] as String?,
);

Map<String, dynamic> _$$OrganizationCreateRequestImplToJson(
  _$OrganizationCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': _$OrganizationTypeEnumMap[instance.type]!,
  'description': instance.description,
  'website': instance.website,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'legalRepresentativeId': instance.legalRepresentativeId,
  'taxId': instance.taxId,
  'registrationNumber': instance.registrationNumber,
};

_$OrganizationMembershipImpl _$$OrganizationMembershipImplFromJson(
  Map<String, dynamic> json,
) => _$OrganizationMembershipImpl(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  userId: json['userId'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  isApproved: json['isApproved'] as bool,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  approvedAt: json['approvedAt'] == null
      ? null
      : DateTime.parse(json['approvedAt'] as String),
  approvedBy: json['approvedBy'] as String?,
);

Map<String, dynamic> _$$OrganizationMembershipImplToJson(
  _$OrganizationMembershipImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'userId': instance.userId,
  'role': _$UserRoleEnumMap[instance.role]!,
  'isApproved': instance.isApproved,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'approvedAt': instance.approvedAt?.toIso8601String(),
  'approvedBy': instance.approvedBy,
};

const _$UserRoleEnumMap = {
  UserRole.superUser: 'SUPER_USER',
  UserRole.governmentAdmin: 'GOVERNMENT_ADMIN',
  UserRole.userAdmin: 'USER_ADMIN',
  UserRole.legalRepresentative: 'LEGAL_REPRESENTATIVE',
  UserRole.watcher: 'WATCHER',
  UserRole.helper: 'HELPER',
  UserRole.rescuer: 'RESCUER',
  UserRole.adopter: 'ADOPTER',
  UserRole.donor: 'DONOR',
  UserRole.veterinarian: 'VETERINARIAN',
};

_$OrganizationMembershipRequestImpl
_$$OrganizationMembershipRequestImplFromJson(Map<String, dynamic> json) =>
    _$OrganizationMembershipRequestImpl(
      organizationId: json['organizationId'] as String,
      userId: json['userId'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$$OrganizationMembershipRequestImplToJson(
  _$OrganizationMembershipRequestImpl instance,
) => <String, dynamic>{
  'organizationId': instance.organizationId,
  'userId': instance.userId,
  'role': _$UserRoleEnumMap[instance.role]!,
};
