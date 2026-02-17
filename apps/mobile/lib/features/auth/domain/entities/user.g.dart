// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  username: json['username'] as String,
  roles: _rolesFromJson(json['roles']),
  email: json['email'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  phone: json['phone'] as String?,
  identification: json['identification'] as String?,
  country: json['country'] as String?,
  province: json['province'] as String?,
  canton: json['canton'] as String?,
  district: json['district'] as String?,
  occupation: json['occupation'] as String?,
  incomeSource: json['incomeSource'] as String?,
  isActive: json['isActive'] as bool?,
  isVerified: json['isVerified'] as bool?,
  avatarBase64: json['avatarBase64'] as String?,
  createdAt: _dateTimeFromJson(json['createdAt']),
  updatedAt: _dateTimeFromJson(json['updatedAt']),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'roles': instance.roles,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'identification': instance.identification,
      'country': instance.country,
      'province': instance.province,
      'canton': instance.canton,
      'district': instance.district,
      'occupation': instance.occupation,
      'incomeSource': instance.incomeSource,
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'avatarBase64': instance.avatarBase64,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
