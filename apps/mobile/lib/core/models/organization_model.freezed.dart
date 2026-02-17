// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrganizationModel _$OrganizationModelFromJson(Map<String, dynamic> json) {
  return _OrganizationModel.fromJson(json);
}

/// @nodoc
mixin _$OrganizationModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  OrganizationType get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String get legalRepresentativeId => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get taxId => throw _privateConstructorUsedError;
  String? get registrationNumber => throw _privateConstructorUsedError;

  /// Serializes this OrganizationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationModelCopyWith<OrganizationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationModelCopyWith<$Res> {
  factory $OrganizationModelCopyWith(
    OrganizationModel value,
    $Res Function(OrganizationModel) then,
  ) = _$OrganizationModelCopyWithImpl<$Res, OrganizationModel>;
  @useResult
  $Res call({
    String id,
    String name,
    OrganizationType type,
    String? description,
    String? logoUrl,
    String? website,
    String? email,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String legalRepresentativeId,
    bool isVerified,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
    String? taxId,
    String? registrationNumber,
  });
}

/// @nodoc
class _$OrganizationModelCopyWithImpl<$Res, $Val extends OrganizationModel>
    implements $OrganizationModelCopyWith<$Res> {
  _$OrganizationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? description = freezed,
    Object? logoUrl = freezed,
    Object? website = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? legalRepresentativeId = null,
    Object? isVerified = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? taxId = freezed,
    Object? registrationNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as OrganizationType,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            logoUrl: freezed == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            legalRepresentativeId: null == legalRepresentativeId
                ? _value.legalRepresentativeId
                : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
                      as String,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            taxId: freezed == taxId
                ? _value.taxId
                : taxId // ignore: cast_nullable_to_non_nullable
                      as String?,
            registrationNumber: freezed == registrationNumber
                ? _value.registrationNumber
                : registrationNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrganizationModelImplCopyWith<$Res>
    implements $OrganizationModelCopyWith<$Res> {
  factory _$$OrganizationModelImplCopyWith(
    _$OrganizationModelImpl value,
    $Res Function(_$OrganizationModelImpl) then,
  ) = __$$OrganizationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    OrganizationType type,
    String? description,
    String? logoUrl,
    String? website,
    String? email,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String legalRepresentativeId,
    bool isVerified,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
    String? taxId,
    String? registrationNumber,
  });
}

/// @nodoc
class __$$OrganizationModelImplCopyWithImpl<$Res>
    extends _$OrganizationModelCopyWithImpl<$Res, _$OrganizationModelImpl>
    implements _$$OrganizationModelImplCopyWith<$Res> {
  __$$OrganizationModelImplCopyWithImpl(
    _$OrganizationModelImpl _value,
    $Res Function(_$OrganizationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? description = freezed,
    Object? logoUrl = freezed,
    Object? website = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? legalRepresentativeId = null,
    Object? isVerified = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? taxId = freezed,
    Object? registrationNumber = freezed,
  }) {
    return _then(
      _$OrganizationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as OrganizationType,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        logoUrl: freezed == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        legalRepresentativeId: null == legalRepresentativeId
            ? _value.legalRepresentativeId
            : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
                  as String,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        taxId: freezed == taxId
            ? _value.taxId
            : taxId // ignore: cast_nullable_to_non_nullable
                  as String?,
        registrationNumber: freezed == registrationNumber
            ? _value.registrationNumber
            : registrationNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationModelImpl implements _OrganizationModel {
  const _$OrganizationModelImpl({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.logoUrl,
    required this.website,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.legalRepresentativeId,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.taxId,
    required this.registrationNumber,
  });

  factory _$OrganizationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final OrganizationType type;
  @override
  final String? description;
  @override
  final String? logoUrl;
  @override
  final String? website;
  @override
  final String? email;
  @override
  final String? phoneNumber;
  @override
  final String? address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String legalRepresentativeId;
  @override
  final bool isVerified;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? taxId;
  @override
  final String? registrationNumber;

  @override
  String toString() {
    return 'OrganizationModel(id: $id, name: $name, type: $type, description: $description, logoUrl: $logoUrl, website: $website, email: $email, phoneNumber: $phoneNumber, address: $address, latitude: $latitude, longitude: $longitude, legalRepresentativeId: $legalRepresentativeId, isVerified: $isVerified, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, taxId: $taxId, registrationNumber: $registrationNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.legalRepresentativeId, legalRepresentativeId) ||
                other.legalRepresentativeId == legalRepresentativeId) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.taxId, taxId) || other.taxId == taxId) &&
            (identical(other.registrationNumber, registrationNumber) ||
                other.registrationNumber == registrationNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    description,
    logoUrl,
    website,
    email,
    phoneNumber,
    address,
    latitude,
    longitude,
    legalRepresentativeId,
    isVerified,
    isActive,
    createdAt,
    updatedAt,
    taxId,
    registrationNumber,
  );

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationModelImplCopyWith<_$OrganizationModelImpl> get copyWith =>
      __$$OrganizationModelImplCopyWithImpl<_$OrganizationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationModelImplToJson(this);
  }
}

abstract class _OrganizationModel implements OrganizationModel {
  const factory _OrganizationModel({
    required final String id,
    required final String name,
    required final OrganizationType type,
    required final String? description,
    required final String? logoUrl,
    required final String? website,
    required final String? email,
    required final String? phoneNumber,
    required final String? address,
    required final double? latitude,
    required final double? longitude,
    required final String legalRepresentativeId,
    required final bool isVerified,
    required final bool isActive,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final String? taxId,
    required final String? registrationNumber,
  }) = _$OrganizationModelImpl;

  factory _OrganizationModel.fromJson(Map<String, dynamic> json) =
      _$OrganizationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  OrganizationType get type;
  @override
  String? get description;
  @override
  String? get logoUrl;
  @override
  String? get website;
  @override
  String? get email;
  @override
  String? get phoneNumber;
  @override
  String? get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String get legalRepresentativeId;
  @override
  bool get isVerified;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get taxId;
  @override
  String? get registrationNumber;

  /// Create a copy of OrganizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationModelImplCopyWith<_$OrganizationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrganizationCreateRequest _$OrganizationCreateRequestFromJson(
  Map<String, dynamic> json,
) {
  return _OrganizationCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$OrganizationCreateRequest {
  String get name => throw _privateConstructorUsedError;
  OrganizationType get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String get legalRepresentativeId => throw _privateConstructorUsedError;
  String? get taxId => throw _privateConstructorUsedError;
  String? get registrationNumber => throw _privateConstructorUsedError;

  /// Serializes this OrganizationCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationCreateRequestCopyWith<OrganizationCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationCreateRequestCopyWith<$Res> {
  factory $OrganizationCreateRequestCopyWith(
    OrganizationCreateRequest value,
    $Res Function(OrganizationCreateRequest) then,
  ) = _$OrganizationCreateRequestCopyWithImpl<$Res, OrganizationCreateRequest>;
  @useResult
  $Res call({
    String name,
    OrganizationType type,
    String? description,
    String? website,
    String? email,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String legalRepresentativeId,
    String? taxId,
    String? registrationNumber,
  });
}

/// @nodoc
class _$OrganizationCreateRequestCopyWithImpl<
  $Res,
  $Val extends OrganizationCreateRequest
>
    implements $OrganizationCreateRequestCopyWith<$Res> {
  _$OrganizationCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? description = freezed,
    Object? website = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? legalRepresentativeId = null,
    Object? taxId = freezed,
    Object? registrationNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as OrganizationType,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            legalRepresentativeId: null == legalRepresentativeId
                ? _value.legalRepresentativeId
                : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
                      as String,
            taxId: freezed == taxId
                ? _value.taxId
                : taxId // ignore: cast_nullable_to_non_nullable
                      as String?,
            registrationNumber: freezed == registrationNumber
                ? _value.registrationNumber
                : registrationNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrganizationCreateRequestImplCopyWith<$Res>
    implements $OrganizationCreateRequestCopyWith<$Res> {
  factory _$$OrganizationCreateRequestImplCopyWith(
    _$OrganizationCreateRequestImpl value,
    $Res Function(_$OrganizationCreateRequestImpl) then,
  ) = __$$OrganizationCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    OrganizationType type,
    String? description,
    String? website,
    String? email,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String legalRepresentativeId,
    String? taxId,
    String? registrationNumber,
  });
}

/// @nodoc
class __$$OrganizationCreateRequestImplCopyWithImpl<$Res>
    extends
        _$OrganizationCreateRequestCopyWithImpl<
          $Res,
          _$OrganizationCreateRequestImpl
        >
    implements _$$OrganizationCreateRequestImplCopyWith<$Res> {
  __$$OrganizationCreateRequestImplCopyWithImpl(
    _$OrganizationCreateRequestImpl _value,
    $Res Function(_$OrganizationCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? description = freezed,
    Object? website = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? legalRepresentativeId = null,
    Object? taxId = freezed,
    Object? registrationNumber = freezed,
  }) {
    return _then(
      _$OrganizationCreateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as OrganizationType,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        legalRepresentativeId: null == legalRepresentativeId
            ? _value.legalRepresentativeId
            : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
                  as String,
        taxId: freezed == taxId
            ? _value.taxId
            : taxId // ignore: cast_nullable_to_non_nullable
                  as String?,
        registrationNumber: freezed == registrationNumber
            ? _value.registrationNumber
            : registrationNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationCreateRequestImpl implements _OrganizationCreateRequest {
  const _$OrganizationCreateRequestImpl({
    required this.name,
    required this.type,
    required this.description,
    required this.website,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.legalRepresentativeId,
    required this.taxId,
    required this.registrationNumber,
  });

  factory _$OrganizationCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final OrganizationType type;
  @override
  final String? description;
  @override
  final String? website;
  @override
  final String? email;
  @override
  final String? phoneNumber;
  @override
  final String? address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String legalRepresentativeId;
  @override
  final String? taxId;
  @override
  final String? registrationNumber;

  @override
  String toString() {
    return 'OrganizationCreateRequest(name: $name, type: $type, description: $description, website: $website, email: $email, phoneNumber: $phoneNumber, address: $address, latitude: $latitude, longitude: $longitude, legalRepresentativeId: $legalRepresentativeId, taxId: $taxId, registrationNumber: $registrationNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.legalRepresentativeId, legalRepresentativeId) ||
                other.legalRepresentativeId == legalRepresentativeId) &&
            (identical(other.taxId, taxId) || other.taxId == taxId) &&
            (identical(other.registrationNumber, registrationNumber) ||
                other.registrationNumber == registrationNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    type,
    description,
    website,
    email,
    phoneNumber,
    address,
    latitude,
    longitude,
    legalRepresentativeId,
    taxId,
    registrationNumber,
  );

  /// Create a copy of OrganizationCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationCreateRequestImplCopyWith<_$OrganizationCreateRequestImpl>
  get copyWith =>
      __$$OrganizationCreateRequestImplCopyWithImpl<
        _$OrganizationCreateRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationCreateRequestImplToJson(this);
  }
}

abstract class _OrganizationCreateRequest implements OrganizationCreateRequest {
  const factory _OrganizationCreateRequest({
    required final String name,
    required final OrganizationType type,
    required final String? description,
    required final String? website,
    required final String? email,
    required final String? phoneNumber,
    required final String? address,
    required final double? latitude,
    required final double? longitude,
    required final String legalRepresentativeId,
    required final String? taxId,
    required final String? registrationNumber,
  }) = _$OrganizationCreateRequestImpl;

  factory _OrganizationCreateRequest.fromJson(Map<String, dynamic> json) =
      _$OrganizationCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  OrganizationType get type;
  @override
  String? get description;
  @override
  String? get website;
  @override
  String? get email;
  @override
  String? get phoneNumber;
  @override
  String? get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String get legalRepresentativeId;
  @override
  String? get taxId;
  @override
  String? get registrationNumber;

  /// Create a copy of OrganizationCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationCreateRequestImplCopyWith<_$OrganizationCreateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

OrganizationMembership _$OrganizationMembershipFromJson(
  Map<String, dynamic> json,
) {
  return _OrganizationMembership.fromJson(json);
}

/// @nodoc
mixin _$OrganizationMembership {
  String get id => throw _privateConstructorUsedError;
  String get organizationId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  bool get isApproved => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  String? get approvedBy => throw _privateConstructorUsedError;

  /// Serializes this OrganizationMembership to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationMembership
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationMembershipCopyWith<OrganizationMembership> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationMembershipCopyWith<$Res> {
  factory $OrganizationMembershipCopyWith(
    OrganizationMembership value,
    $Res Function(OrganizationMembership) then,
  ) = _$OrganizationMembershipCopyWithImpl<$Res, OrganizationMembership>;
  @useResult
  $Res call({
    String id,
    String organizationId,
    String userId,
    UserRole role,
    bool isApproved,
    DateTime joinedAt,
    DateTime? approvedAt,
    String? approvedBy,
  });
}

/// @nodoc
class _$OrganizationMembershipCopyWithImpl<
  $Res,
  $Val extends OrganizationMembership
>
    implements $OrganizationMembershipCopyWith<$Res> {
  _$OrganizationMembershipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationMembership
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizationId = null,
    Object? userId = null,
    Object? role = null,
    Object? isApproved = null,
    Object? joinedAt = null,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            organizationId: null == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as UserRole,
            isApproved: null == isApproved
                ? _value.isApproved
                : isApproved // ignore: cast_nullable_to_non_nullable
                      as bool,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            approvedAt: freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            approvedBy: freezed == approvedBy
                ? _value.approvedBy
                : approvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrganizationMembershipImplCopyWith<$Res>
    implements $OrganizationMembershipCopyWith<$Res> {
  factory _$$OrganizationMembershipImplCopyWith(
    _$OrganizationMembershipImpl value,
    $Res Function(_$OrganizationMembershipImpl) then,
  ) = __$$OrganizationMembershipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String organizationId,
    String userId,
    UserRole role,
    bool isApproved,
    DateTime joinedAt,
    DateTime? approvedAt,
    String? approvedBy,
  });
}

/// @nodoc
class __$$OrganizationMembershipImplCopyWithImpl<$Res>
    extends
        _$OrganizationMembershipCopyWithImpl<$Res, _$OrganizationMembershipImpl>
    implements _$$OrganizationMembershipImplCopyWith<$Res> {
  __$$OrganizationMembershipImplCopyWithImpl(
    _$OrganizationMembershipImpl _value,
    $Res Function(_$OrganizationMembershipImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationMembership
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizationId = null,
    Object? userId = null,
    Object? role = null,
    Object? isApproved = null,
    Object? joinedAt = null,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
  }) {
    return _then(
      _$OrganizationMembershipImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        organizationId: null == organizationId
            ? _value.organizationId
            : organizationId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as UserRole,
        isApproved: null == isApproved
            ? _value.isApproved
            : isApproved // ignore: cast_nullable_to_non_nullable
                  as bool,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        approvedAt: freezed == approvedAt
            ? _value.approvedAt
            : approvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        approvedBy: freezed == approvedBy
            ? _value.approvedBy
            : approvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationMembershipImpl implements _OrganizationMembership {
  const _$OrganizationMembershipImpl({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.role,
    required this.isApproved,
    required this.joinedAt,
    required this.approvedAt,
    required this.approvedBy,
  });

  factory _$OrganizationMembershipImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationMembershipImplFromJson(json);

  @override
  final String id;
  @override
  final String organizationId;
  @override
  final String userId;
  @override
  final UserRole role;
  @override
  final bool isApproved;
  @override
  final DateTime joinedAt;
  @override
  final DateTime? approvedAt;
  @override
  final String? approvedBy;

  @override
  String toString() {
    return 'OrganizationMembership(id: $id, organizationId: $organizationId, userId: $userId, role: $role, isApproved: $isApproved, joinedAt: $joinedAt, approvedAt: $approvedAt, approvedBy: $approvedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationMembershipImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isApproved, isApproved) ||
                other.isApproved == isApproved) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    organizationId,
    userId,
    role,
    isApproved,
    joinedAt,
    approvedAt,
    approvedBy,
  );

  /// Create a copy of OrganizationMembership
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationMembershipImplCopyWith<_$OrganizationMembershipImpl>
  get copyWith =>
      __$$OrganizationMembershipImplCopyWithImpl<_$OrganizationMembershipImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationMembershipImplToJson(this);
  }
}

abstract class _OrganizationMembership implements OrganizationMembership {
  const factory _OrganizationMembership({
    required final String id,
    required final String organizationId,
    required final String userId,
    required final UserRole role,
    required final bool isApproved,
    required final DateTime joinedAt,
    required final DateTime? approvedAt,
    required final String? approvedBy,
  }) = _$OrganizationMembershipImpl;

  factory _OrganizationMembership.fromJson(Map<String, dynamic> json) =
      _$OrganizationMembershipImpl.fromJson;

  @override
  String get id;
  @override
  String get organizationId;
  @override
  String get userId;
  @override
  UserRole get role;
  @override
  bool get isApproved;
  @override
  DateTime get joinedAt;
  @override
  DateTime? get approvedAt;
  @override
  String? get approvedBy;

  /// Create a copy of OrganizationMembership
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationMembershipImplCopyWith<_$OrganizationMembershipImpl>
  get copyWith => throw _privateConstructorUsedError;
}

OrganizationMembershipRequest _$OrganizationMembershipRequestFromJson(
  Map<String, dynamic> json,
) {
  return _OrganizationMembershipRequest.fromJson(json);
}

/// @nodoc
mixin _$OrganizationMembershipRequest {
  String get organizationId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;

  /// Serializes this OrganizationMembershipRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationMembershipRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationMembershipRequestCopyWith<OrganizationMembershipRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationMembershipRequestCopyWith<$Res> {
  factory $OrganizationMembershipRequestCopyWith(
    OrganizationMembershipRequest value,
    $Res Function(OrganizationMembershipRequest) then,
  ) =
      _$OrganizationMembershipRequestCopyWithImpl<
        $Res,
        OrganizationMembershipRequest
      >;
  @useResult
  $Res call({String organizationId, String userId, UserRole role});
}

/// @nodoc
class _$OrganizationMembershipRequestCopyWithImpl<
  $Res,
  $Val extends OrganizationMembershipRequest
>
    implements $OrganizationMembershipRequestCopyWith<$Res> {
  _$OrganizationMembershipRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationMembershipRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizationId = null,
    Object? userId = null,
    Object? role = null,
  }) {
    return _then(
      _value.copyWith(
            organizationId: null == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as UserRole,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrganizationMembershipRequestImplCopyWith<$Res>
    implements $OrganizationMembershipRequestCopyWith<$Res> {
  factory _$$OrganizationMembershipRequestImplCopyWith(
    _$OrganizationMembershipRequestImpl value,
    $Res Function(_$OrganizationMembershipRequestImpl) then,
  ) = __$$OrganizationMembershipRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String organizationId, String userId, UserRole role});
}

/// @nodoc
class __$$OrganizationMembershipRequestImplCopyWithImpl<$Res>
    extends
        _$OrganizationMembershipRequestCopyWithImpl<
          $Res,
          _$OrganizationMembershipRequestImpl
        >
    implements _$$OrganizationMembershipRequestImplCopyWith<$Res> {
  __$$OrganizationMembershipRequestImplCopyWithImpl(
    _$OrganizationMembershipRequestImpl _value,
    $Res Function(_$OrganizationMembershipRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationMembershipRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizationId = null,
    Object? userId = null,
    Object? role = null,
  }) {
    return _then(
      _$OrganizationMembershipRequestImpl(
        organizationId: null == organizationId
            ? _value.organizationId
            : organizationId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as UserRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationMembershipRequestImpl
    implements _OrganizationMembershipRequest {
  const _$OrganizationMembershipRequestImpl({
    required this.organizationId,
    required this.userId,
    required this.role,
  });

  factory _$OrganizationMembershipRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$OrganizationMembershipRequestImplFromJson(json);

  @override
  final String organizationId;
  @override
  final String userId;
  @override
  final UserRole role;

  @override
  String toString() {
    return 'OrganizationMembershipRequest(organizationId: $organizationId, userId: $userId, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationMembershipRequestImpl &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, organizationId, userId, role);

  /// Create a copy of OrganizationMembershipRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationMembershipRequestImplCopyWith<
    _$OrganizationMembershipRequestImpl
  >
  get copyWith =>
      __$$OrganizationMembershipRequestImplCopyWithImpl<
        _$OrganizationMembershipRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationMembershipRequestImplToJson(this);
  }
}

abstract class _OrganizationMembershipRequest
    implements OrganizationMembershipRequest {
  const factory _OrganizationMembershipRequest({
    required final String organizationId,
    required final String userId,
    required final UserRole role,
  }) = _$OrganizationMembershipRequestImpl;

  factory _OrganizationMembershipRequest.fromJson(Map<String, dynamic> json) =
      _$OrganizationMembershipRequestImpl.fromJson;

  @override
  String get organizationId;
  @override
  String get userId;
  @override
  UserRole get role;

  /// Create a copy of OrganizationMembershipRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationMembershipRequestImplCopyWith<
    _$OrganizationMembershipRequestImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
