// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  List<UserRole> get roles => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get identification => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get province => throw _privateConstructorUsedError;
  String? get canton => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get organizationId => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  String? get avatarBase64 => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String id,
    String username,
    String? email,
    List<UserRole> roles,
    String? firstName,
    String? lastName,
    String? phone,
    String? identification,
    String? country,
    String? province,
    String? canton,
    String? district,
    String? bio,
    String? organizationId,
    double? latitude,
    double? longitude,
    bool isActive,
    bool isVerified,
    String? avatarBase64,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? email = freezed,
    Object? roles = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phone = freezed,
    Object? identification = freezed,
    Object? country = freezed,
    Object? province = freezed,
    Object? canton = freezed,
    Object? district = freezed,
    Object? bio = freezed,
    Object? organizationId = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isActive = null,
    Object? isVerified = null,
    Object? avatarBase64 = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<UserRole>,
            firstName: freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            identification: freezed == identification
                ? _value.identification
                : identification // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            province: freezed == province
                ? _value.province
                : province // ignore: cast_nullable_to_non_nullable
                      as String?,
            canton: freezed == canton
                ? _value.canton
                : canton // ignore: cast_nullable_to_non_nullable
                      as String?,
            district: freezed == district
                ? _value.district
                : district // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            organizationId: freezed == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            avatarBase64: freezed == avatarBase64
                ? _value.avatarBase64
                : avatarBase64 // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String username,
    String? email,
    List<UserRole> roles,
    String? firstName,
    String? lastName,
    String? phone,
    String? identification,
    String? country,
    String? province,
    String? canton,
    String? district,
    String? bio,
    String? organizationId,
    double? latitude,
    double? longitude,
    bool isActive,
    bool isVerified,
    String? avatarBase64,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? email = freezed,
    Object? roles = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phone = freezed,
    Object? identification = freezed,
    Object? country = freezed,
    Object? province = freezed,
    Object? canton = freezed,
    Object? district = freezed,
    Object? bio = freezed,
    Object? organizationId = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isActive = null,
    Object? isVerified = null,
    Object? avatarBase64 = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$UserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        roles: null == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<UserRole>,
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        identification: freezed == identification
            ? _value.identification
            : identification // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        province: freezed == province
            ? _value.province
            : province // ignore: cast_nullable_to_non_nullable
                  as String?,
        canton: freezed == canton
            ? _value.canton
            : canton // ignore: cast_nullable_to_non_nullable
                  as String?,
        district: freezed == district
            ? _value.district
            : district // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        organizationId: freezed == organizationId
            ? _value.organizationId
            : organizationId // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        avatarBase64: freezed == avatarBase64
            ? _value.avatarBase64
            : avatarBase64 // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.id,
    required this.username,
    this.email,
    required final List<UserRole> roles,
    this.firstName,
    this.lastName,
    this.phone,
    this.identification,
    this.country,
    this.province,
    this.canton,
    this.district,
    this.bio,
    this.organizationId,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.isVerified,
    this.avatarBase64,
    required this.createdAt,
    required this.updatedAt,
  }) : _roles = roles;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  final String? email;
  final List<UserRole> _roles;
  @override
  List<UserRole> get roles {
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roles);
  }

  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? phone;
  @override
  final String? identification;
  @override
  final String? country;
  @override
  final String? province;
  @override
  final String? canton;
  @override
  final String? district;
  @override
  final String? bio;
  @override
  final String? organizationId;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final bool isActive;
  @override
  final bool isVerified;
  @override
  final String? avatarBase64;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, roles: $roles, firstName: $firstName, lastName: $lastName, phone: $phone, identification: $identification, country: $country, province: $province, canton: $canton, district: $district, bio: $bio, organizationId: $organizationId, latitude: $latitude, longitude: $longitude, isActive: $isActive, isVerified: $isVerified, avatarBase64: $avatarBase64, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.identification, identification) ||
                other.identification == identification) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.province, province) ||
                other.province == province) &&
            (identical(other.canton, canton) || other.canton == canton) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.avatarBase64, avatarBase64) ||
                other.avatarBase64 == avatarBase64) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    username,
    email,
    const DeepCollectionEquality().hash(_roles),
    firstName,
    lastName,
    phone,
    identification,
    country,
    province,
    canton,
    district,
    bio,
    organizationId,
    latitude,
    longitude,
    isActive,
    isVerified,
    avatarBase64,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final String id,
    required final String username,
    final String? email,
    required final List<UserRole> roles,
    final String? firstName,
    final String? lastName,
    final String? phone,
    final String? identification,
    final String? country,
    final String? province,
    final String? canton,
    final String? district,
    final String? bio,
    final String? organizationId,
    final double? latitude,
    final double? longitude,
    required final bool isActive,
    required final bool isVerified,
    final String? avatarBase64,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String? get email;
  @override
  List<UserRole> get roles;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get phone;
  @override
  String? get identification;
  @override
  String? get country;
  @override
  String? get province;
  @override
  String? get canton;
  @override
  String? get district;
  @override
  String? get bio;
  @override
  String? get organizationId;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  bool get isActive;
  @override
  bool get isVerified;
  @override
  String? get avatarBase64;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserLoginRequest _$UserLoginRequestFromJson(Map<String, dynamic> json) {
  return _UserLoginRequest.fromJson(json);
}

/// @nodoc
mixin _$UserLoginRequest {
  String get username => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this UserLoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserLoginRequestCopyWith<UserLoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLoginRequestCopyWith<$Res> {
  factory $UserLoginRequestCopyWith(
    UserLoginRequest value,
    $Res Function(UserLoginRequest) then,
  ) = _$UserLoginRequestCopyWithImpl<$Res, UserLoginRequest>;
  @useResult
  $Res call({String username, String password});
}

/// @nodoc
class _$UserLoginRequestCopyWithImpl<$Res, $Val extends UserLoginRequest>
    implements $UserLoginRequestCopyWith<$Res> {
  _$UserLoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? username = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserLoginRequestImplCopyWith<$Res>
    implements $UserLoginRequestCopyWith<$Res> {
  factory _$$UserLoginRequestImplCopyWith(
    _$UserLoginRequestImpl value,
    $Res Function(_$UserLoginRequestImpl) then,
  ) = __$$UserLoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String username, String password});
}

/// @nodoc
class __$$UserLoginRequestImplCopyWithImpl<$Res>
    extends _$UserLoginRequestCopyWithImpl<$Res, _$UserLoginRequestImpl>
    implements _$$UserLoginRequestImplCopyWith<$Res> {
  __$$UserLoginRequestImplCopyWithImpl(
    _$UserLoginRequestImpl _value,
    $Res Function(_$UserLoginRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? username = null, Object? password = null}) {
    return _then(
      _$UserLoginRequestImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserLoginRequestImpl implements _UserLoginRequest {
  const _$UserLoginRequestImpl({
    required this.username,
    required this.password,
  });

  factory _$UserLoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserLoginRequestImplFromJson(json);

  @override
  final String username;
  @override
  final String password;

  @override
  String toString() {
    return 'UserLoginRequest(username: $username, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLoginRequestImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, username, password);

  /// Create a copy of UserLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLoginRequestImplCopyWith<_$UserLoginRequestImpl> get copyWith =>
      __$$UserLoginRequestImplCopyWithImpl<_$UserLoginRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserLoginRequestImplToJson(this);
  }
}

abstract class _UserLoginRequest implements UserLoginRequest {
  const factory _UserLoginRequest({
    required final String username,
    required final String password,
  }) = _$UserLoginRequestImpl;

  factory _UserLoginRequest.fromJson(Map<String, dynamic> json) =
      _$UserLoginRequestImpl.fromJson;

  @override
  String get username;
  @override
  String get password;

  /// Create a copy of UserLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserLoginRequestImplCopyWith<_$UserLoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserLoginResponse _$UserLoginResponseFromJson(Map<String, dynamic> json) {
  return _UserLoginResponse.fromJson(json);
}

/// @nodoc
mixin _$UserLoginResponse {
  String get accessToken => throw _privateConstructorUsedError;

  /// Serializes this UserLoginResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserLoginResponseCopyWith<UserLoginResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLoginResponseCopyWith<$Res> {
  factory $UserLoginResponseCopyWith(
    UserLoginResponse value,
    $Res Function(UserLoginResponse) then,
  ) = _$UserLoginResponseCopyWithImpl<$Res, UserLoginResponse>;
  @useResult
  $Res call({String accessToken});
}

/// @nodoc
class _$UserLoginResponseCopyWithImpl<$Res, $Val extends UserLoginResponse>
    implements $UserLoginResponseCopyWith<$Res> {
  _$UserLoginResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? accessToken = null}) {
    return _then(
      _value.copyWith(
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserLoginResponseImplCopyWith<$Res>
    implements $UserLoginResponseCopyWith<$Res> {
  factory _$$UserLoginResponseImplCopyWith(
    _$UserLoginResponseImpl value,
    $Res Function(_$UserLoginResponseImpl) then,
  ) = __$$UserLoginResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken});
}

/// @nodoc
class __$$UserLoginResponseImplCopyWithImpl<$Res>
    extends _$UserLoginResponseCopyWithImpl<$Res, _$UserLoginResponseImpl>
    implements _$$UserLoginResponseImplCopyWith<$Res> {
  __$$UserLoginResponseImplCopyWithImpl(
    _$UserLoginResponseImpl _value,
    $Res Function(_$UserLoginResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? accessToken = null}) {
    return _then(
      _$UserLoginResponseImpl(
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserLoginResponseImpl implements _UserLoginResponse {
  const _$UserLoginResponseImpl({required this.accessToken});

  factory _$UserLoginResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserLoginResponseImplFromJson(json);

  @override
  final String accessToken;

  @override
  String toString() {
    return 'UserLoginResponse(accessToken: $accessToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLoginResponseImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken);

  /// Create a copy of UserLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLoginResponseImplCopyWith<_$UserLoginResponseImpl> get copyWith =>
      __$$UserLoginResponseImplCopyWithImpl<_$UserLoginResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserLoginResponseImplToJson(this);
  }
}

abstract class _UserLoginResponse implements UserLoginResponse {
  const factory _UserLoginResponse({required final String accessToken}) =
      _$UserLoginResponseImpl;

  factory _UserLoginResponse.fromJson(Map<String, dynamic> json) =
      _$UserLoginResponseImpl.fromJson;

  @override
  String get accessToken;

  /// Create a copy of UserLoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserLoginResponseImplCopyWith<_$UserLoginResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
