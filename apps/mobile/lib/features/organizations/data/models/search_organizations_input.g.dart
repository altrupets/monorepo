// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_organizations_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchOrganizationsInputImpl _$$SearchOrganizationsInputImplFromJson(
  Map<String, dynamic> json,
) => _$SearchOrganizationsInputImpl(
  name: json['name'] as String?,
  type: $enumDecodeNullable(_$OrganizationTypeEnumMap, json['type']),
  status: $enumDecodeNullable(_$OrganizationStatusEnumMap, json['status']),
  country: json['country'] as String?,
  province: json['province'] as String?,
  canton: json['canton'] as String?,
);

Map<String, dynamic> _$$SearchOrganizationsInputImplToJson(
  _$SearchOrganizationsInputImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': _$OrganizationTypeEnumMap[instance.type],
  'status': _$OrganizationStatusEnumMap[instance.status],
  'country': instance.country,
  'province': instance.province,
  'canton': instance.canton,
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
