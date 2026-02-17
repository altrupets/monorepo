// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_organization_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegisterOrganizationInputImpl _$$RegisterOrganizationInputImplFromJson(
  Map<String, dynamic> json,
) => _$RegisterOrganizationInputImpl(
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
  legalDocumentationBase64: json['legalDocumentationBase64'] as String?,
  financialStatementsBase64: json['financialStatementsBase64'] as String?,
  maxCapacity: (json['maxCapacity'] as num?)?.toInt(),
);

Map<String, dynamic> _$$RegisterOrganizationInputImplToJson(
  _$RegisterOrganizationInputImpl instance,
) => <String, dynamic>{
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
  'legalDocumentationBase64': instance.legalDocumentationBase64,
  'financialStatementsBase64': instance.financialStatementsBase64,
  'maxCapacity': instance.maxCapacity,
};

const _$OrganizationTypeEnumMap = {
  OrganizationType.foundation: 'FOUNDATION',
  OrganizationType.association: 'ASSOCIATION',
  OrganizationType.ngo: 'NGO',
  OrganizationType.cooperative: 'COOPERATIVE',
  OrganizationType.government: 'GOVERNMENT',
  OrganizationType.other: 'OTHER',
};
