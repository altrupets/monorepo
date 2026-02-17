// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegisterInputImpl _$$RegisterInputImplFromJson(Map<String, dynamic> json) =>
    _$RegisterInputImpl(
      username: json['username'] as String,
      password: json['password'] as String,
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
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$RegisterInputImplToJson(_$RegisterInputImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
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
      'roles': instance.roles,
    };
