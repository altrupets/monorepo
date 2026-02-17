// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Organization _$OrganizationFromJson(Map<String, dynamic> json) {
  return _Organization.fromJson(json);
}

/// @nodoc
mixin _$Organization {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  OrganizationType get type => throw _privateConstructorUsedError;
  String? get legalId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get province => throw _privateConstructorUsedError;
  String? get canton => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  OrganizationStatus get status => throw _privateConstructorUsedError;
  String? get legalRepresentativeId => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  int get maxCapacity => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Organization to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationCopyWith<Organization> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationCopyWith<$Res> {
  factory $OrganizationCopyWith(
    Organization value,
    $Res Function(Organization) then,
  ) = _$OrganizationCopyWithImpl<$Res, Organization>;
  @useResult
  $Res call({
    String id,
    String name,
    OrganizationType type,
    String? legalId,
    String? description,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? country,
    String? province,
    String? canton,
    String? district,
    OrganizationStatus status,
    String? legalRepresentativeId,
    int memberCount,
    int maxCapacity,
    bool isActive,
    bool isVerified,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$OrganizationCopyWithImpl<$Res, $Val extends Organization>
    implements $OrganizationCopyWith<$Res> {
  _$OrganizationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? legalId = freezed,
    Object? description = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? website = freezed,
    Object? address = freezed,
    Object? country = freezed,
    Object? province = freezed,
    Object? canton = freezed,
    Object? district = freezed,
    Object? status = null,
    Object? legalRepresentativeId = freezed,
    Object? memberCount = null,
    Object? maxCapacity = null,
    Object? isActive = null,
    Object? isVerified = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            legalId: freezed == legalId
                ? _value.legalId
                : legalId // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrganizationStatus,
            legalRepresentativeId: freezed == legalRepresentativeId
                ? _value.legalRepresentativeId
                : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int,
            maxCapacity: null == maxCapacity
                ? _value.maxCapacity
                : maxCapacity // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$OrganizationImplCopyWith<$Res>
    implements $OrganizationCopyWith<$Res> {
  factory _$$OrganizationImplCopyWith(
    _$OrganizationImpl value,
    $Res Function(_$OrganizationImpl) then,
  ) = __$$OrganizationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    OrganizationType type,
    String? legalId,
    String? description,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? country,
    String? province,
    String? canton,
    String? district,
    OrganizationStatus status,
    String? legalRepresentativeId,
    int memberCount,
    int maxCapacity,
    bool isActive,
    bool isVerified,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$OrganizationImplCopyWithImpl<$Res>
    extends _$OrganizationCopyWithImpl<$Res, _$OrganizationImpl>
    implements _$$OrganizationImplCopyWith<$Res> {
  __$$OrganizationImplCopyWithImpl(
    _$OrganizationImpl _value,
    $Res Function(_$OrganizationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? legalId = freezed,
    Object? description = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? website = freezed,
    Object? address = freezed,
    Object? country = freezed,
    Object? province = freezed,
    Object? canton = freezed,
    Object? district = freezed,
    Object? status = null,
    Object? legalRepresentativeId = freezed,
    Object? memberCount = null,
    Object? maxCapacity = null,
    Object? isActive = null,
    Object? isVerified = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$OrganizationImpl(
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
        legalId: freezed == legalId
            ? _value.legalId
            : legalId // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
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
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrganizationStatus,
        legalRepresentativeId: freezed == legalRepresentativeId
            ? _value.legalRepresentativeId
            : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int,
        maxCapacity: null == maxCapacity
            ? _value.maxCapacity
            : maxCapacity // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$OrganizationImpl implements _Organization {
  const _$OrganizationImpl({
    required this.id,
    required this.name,
    required this.type,
    this.legalId,
    this.description,
    this.email,
    this.phone,
    this.website,
    this.address,
    this.country,
    this.province,
    this.canton,
    this.district,
    required this.status,
    this.legalRepresentativeId,
    required this.memberCount,
    required this.maxCapacity,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$OrganizationImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final OrganizationType type;
  @override
  final String? legalId;
  @override
  final String? description;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? website;
  @override
  final String? address;
  @override
  final String? country;
  @override
  final String? province;
  @override
  final String? canton;
  @override
  final String? district;
  @override
  final OrganizationStatus status;
  @override
  final String? legalRepresentativeId;
  @override
  final int memberCount;
  @override
  final int maxCapacity;
  @override
  final bool isActive;
  @override
  final bool isVerified;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Organization(id: $id, name: $name, type: $type, legalId: $legalId, description: $description, email: $email, phone: $phone, website: $website, address: $address, country: $country, province: $province, canton: $canton, district: $district, status: $status, legalRepresentativeId: $legalRepresentativeId, memberCount: $memberCount, maxCapacity: $maxCapacity, isActive: $isActive, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.legalId, legalId) || other.legalId == legalId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.province, province) ||
                other.province == province) &&
            (identical(other.canton, canton) || other.canton == canton) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.legalRepresentativeId, legalRepresentativeId) ||
                other.legalRepresentativeId == legalRepresentativeId) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.maxCapacity, maxCapacity) ||
                other.maxCapacity == maxCapacity) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
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
    name,
    type,
    legalId,
    description,
    email,
    phone,
    website,
    address,
    country,
    province,
    canton,
    district,
    status,
    legalRepresentativeId,
    memberCount,
    maxCapacity,
    isActive,
    isVerified,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationImplCopyWith<_$OrganizationImpl> get copyWith =>
      __$$OrganizationImplCopyWithImpl<_$OrganizationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationImplToJson(this);
  }
}

abstract class _Organization implements Organization {
  const factory _Organization({
    required final String id,
    required final String name,
    required final OrganizationType type,
    final String? legalId,
    final String? description,
    final String? email,
    final String? phone,
    final String? website,
    final String? address,
    final String? country,
    final String? province,
    final String? canton,
    final String? district,
    required final OrganizationStatus status,
    final String? legalRepresentativeId,
    required final int memberCount,
    required final int maxCapacity,
    required final bool isActive,
    required final bool isVerified,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$OrganizationImpl;

  factory _Organization.fromJson(Map<String, dynamic> json) =
      _$OrganizationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  OrganizationType get type;
  @override
  String? get legalId;
  @override
  String? get description;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get website;
  @override
  String? get address;
  @override
  String? get country;
  @override
  String? get province;
  @override
  String? get canton;
  @override
  String? get district;
  @override
  OrganizationStatus get status;
  @override
  String? get legalRepresentativeId;
  @override
  int get memberCount;
  @override
  int get maxCapacity;
  @override
  bool get isActive;
  @override
  bool get isVerified;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationImplCopyWith<_$OrganizationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
