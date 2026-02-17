// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      roles: (json['roles'] as List<dynamic>)
          .map((e) => $enumDecode(_$UserRoleEnumMap, e))
          .toList(),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      identification: json['identification'] as String?,
      country: json['country'] as String?,
      province: json['province'] as String?,
      canton: json['canton'] as String?,
      district: json['district'] as String?,
      bio: json['bio'] as String?,
      organizationId: json['organizationId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool,
      isVerified: json['isVerified'] as bool,
      avatarBase64: json['avatarBase64'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'roles': instance.roles.map((e) => _$UserRoleEnumMap[e]!).toList(),
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'identification': instance.identification,
      'country': instance.country,
      'province': instance.province,
      'canton': instance.canton,
      'district': instance.district,
      'bio': instance.bio,
      'organizationId': instance.organizationId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'avatarBase64': instance.avatarBase64,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
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

_$UserLoginRequestImpl _$$UserLoginRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UserLoginRequestImpl(
  username: json['username'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$UserLoginRequestImplToJson(
  _$UserLoginRequestImpl instance,
) => <String, dynamic>{
  'username': instance.username,
  'password': instance.password,
};

_$UserLoginResponseImpl _$$UserLoginResponseImplFromJson(
  Map<String, dynamic> json,
) => _$UserLoginResponseImpl(accessToken: json['accessToken'] as String);

Map<String, dynamic> _$$UserLoginResponseImplToJson(
  _$UserLoginResponseImpl instance,
) => <String, dynamic>{'accessToken': instance.accessToken};
