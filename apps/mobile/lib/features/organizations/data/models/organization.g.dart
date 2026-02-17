// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationImpl _$$OrganizationImplFromJson(Map<String, dynamic> json) =>
    _$OrganizationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$OrganizationTypeEnumMap, json['type']),
      legalId: json['legalId'] as String?,
      description: json['description'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      province: json['province'] as String?,
      canton: json['canton'] as String?,
      district: json['district'] as String?,
      status: $enumDecode(_$OrganizationStatusEnumMap, json['status']),
      legalRepresentativeId: json['legalRepresentativeId'] as String?,
      memberCount: (json['memberCount'] as num).toInt(),
      maxCapacity: (json['maxCapacity'] as num).toInt(),
      isActive: json['isActive'] as bool,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$OrganizationImplToJson(_$OrganizationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$OrganizationTypeEnumMap[instance.type]!,
      'legalId': instance.legalId,
      'description': instance.description,
      'email': instance.email,
      'phone': instance.phone,
      'website': instance.website,
      'address': instance.address,
      'country': instance.country,
      'province': instance.province,
      'canton': instance.canton,
      'district': instance.district,
      'status': _$OrganizationStatusEnumMap[instance.status]!,
      'legalRepresentativeId': instance.legalRepresentativeId,
      'memberCount': instance.memberCount,
      'maxCapacity': instance.maxCapacity,
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$OrganizationTypeEnumMap = {
  OrganizationType.foundation: 'FOUNDATION',
  OrganizationType.association: 'ASSOCIATION',
  OrganizationType.ngo: 'NGO',
  OrganizationType.cooperative: 'COOPERATIVE',
  OrganizationType.government: 'GOVERNMENT',
  OrganizationType.other: 'OTHER',
};

const _$OrganizationStatusEnumMap = {
  OrganizationStatus.pendingVerification: 'PENDING_VERIFICATION',
  OrganizationStatus.active: 'ACTIVE',
  OrganizationStatus.suspended: 'SUSPENDED',
  OrganizationStatus.inactive: 'INACTIVE',
};
