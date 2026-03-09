// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  username: json['username'] as String,
  roles: (json['roles'] as List<dynamic>)
      .map((e) => $enumDecode(_$UserRoleEnumMap, e))
      .toList(),
  isActive: json['isActive'] as bool,
  isVerified: json['isVerified'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  email: json['email'] as String?,
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
  avatarBase64: json['avatarBase64'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'roles': instance.roles.map((e) => _$UserRoleEnumMap[e]!).toList(),
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'email': instance.email,
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
      'avatarBase64': instance.avatarBase64,
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

_UserLoginRequest _$UserLoginRequestFromJson(Map<String, dynamic> json) =>
    _UserLoginRequest(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UserLoginRequestToJson(_UserLoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

_UserLoginResponse _$UserLoginResponseFromJson(Map<String, dynamic> json) =>
    _UserLoginResponse(accessToken: json['accessToken'] as String);

Map<String, dynamic> _$UserLoginResponseToJson(_UserLoginResponse instance) =>
    <String, dynamic>{'accessToken': instance.accessToken};
