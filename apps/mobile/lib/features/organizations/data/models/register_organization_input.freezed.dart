// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_organization_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RegisterOrganizationInput _$RegisterOrganizationInputFromJson(
  Map<String, dynamic> json,
) {
  return _RegisterOrganizationInput.fromJson(json);
}

/// @nodoc
mixin _$RegisterOrganizationInput {
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
  String? get legalDocumentationBase64 => throw _privateConstructorUsedError;
  String? get financialStatementsBase64 => throw _privateConstructorUsedError;
  int? get maxCapacity => throw _privateConstructorUsedError;

  /// Serializes this RegisterOrganizationInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterOrganizationInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterOrganizationInputCopyWith<RegisterOrganizationInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterOrganizationInputCopyWith<$Res> {
  factory $RegisterOrganizationInputCopyWith(
    RegisterOrganizationInput value,
    $Res Function(RegisterOrganizationInput) then,
  ) = _$RegisterOrganizationInputCopyWithImpl<$Res, RegisterOrganizationInput>;
  @useResult
  $Res call({
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
    String? legalDocumentationBase64,
    String? financialStatementsBase64,
    int? maxCapacity,
  });
}

/// @nodoc
class _$RegisterOrganizationInputCopyWithImpl<
  $Res,
  $Val extends RegisterOrganizationInput
>
    implements $RegisterOrganizationInputCopyWith<$Res> {
  _$RegisterOrganizationInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterOrganizationInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
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
    Object? legalDocumentationBase64 = freezed,
    Object? financialStatementsBase64 = freezed,
    Object? maxCapacity = freezed,
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
            legalDocumentationBase64: freezed == legalDocumentationBase64
                ? _value.legalDocumentationBase64
                : legalDocumentationBase64 // ignore: cast_nullable_to_non_nullable
                      as String?,
            financialStatementsBase64: freezed == financialStatementsBase64
                ? _value.financialStatementsBase64
                : financialStatementsBase64 // ignore: cast_nullable_to_non_nullable
                      as String?,
            maxCapacity: freezed == maxCapacity
                ? _value.maxCapacity
                : maxCapacity // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegisterOrganizationInputImplCopyWith<$Res>
    implements $RegisterOrganizationInputCopyWith<$Res> {
  factory _$$RegisterOrganizationInputImplCopyWith(
    _$RegisterOrganizationInputImpl value,
    $Res Function(_$RegisterOrganizationInputImpl) then,
  ) = __$$RegisterOrganizationInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
    String? legalDocumentationBase64,
    String? financialStatementsBase64,
    int? maxCapacity,
  });
}

/// @nodoc
class __$$RegisterOrganizationInputImplCopyWithImpl<$Res>
    extends
        _$RegisterOrganizationInputCopyWithImpl<
          $Res,
          _$RegisterOrganizationInputImpl
        >
    implements _$$RegisterOrganizationInputImplCopyWith<$Res> {
  __$$RegisterOrganizationInputImplCopyWithImpl(
    _$RegisterOrganizationInputImpl _value,
    $Res Function(_$RegisterOrganizationInputImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterOrganizationInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
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
    Object? legalDocumentationBase64 = freezed,
    Object? financialStatementsBase64 = freezed,
    Object? maxCapacity = freezed,
  }) {
    return _then(
      _$RegisterOrganizationInputImpl(
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
        legalDocumentationBase64: freezed == legalDocumentationBase64
            ? _value.legalDocumentationBase64
            : legalDocumentationBase64 // ignore: cast_nullable_to_non_nullable
                  as String?,
        financialStatementsBase64: freezed == financialStatementsBase64
            ? _value.financialStatementsBase64
            : financialStatementsBase64 // ignore: cast_nullable_to_non_nullable
                  as String?,
        maxCapacity: freezed == maxCapacity
            ? _value.maxCapacity
            : maxCapacity // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterOrganizationInputImpl implements _RegisterOrganizationInput {
  const _$RegisterOrganizationInputImpl({
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
    this.legalDocumentationBase64,
    this.financialStatementsBase64,
    this.maxCapacity,
  });

  factory _$RegisterOrganizationInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterOrganizationInputImplFromJson(json);

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
  final String? legalDocumentationBase64;
  @override
  final String? financialStatementsBase64;
  @override
  final int? maxCapacity;

  @override
  String toString() {
    return 'RegisterOrganizationInput(name: $name, type: $type, legalId: $legalId, description: $description, email: $email, phone: $phone, website: $website, address: $address, country: $country, province: $province, canton: $canton, district: $district, legalDocumentationBase64: $legalDocumentationBase64, financialStatementsBase64: $financialStatementsBase64, maxCapacity: $maxCapacity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterOrganizationInputImpl &&
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
            (identical(
                  other.legalDocumentationBase64,
                  legalDocumentationBase64,
                ) ||
                other.legalDocumentationBase64 == legalDocumentationBase64) &&
            (identical(
                  other.financialStatementsBase64,
                  financialStatementsBase64,
                ) ||
                other.financialStatementsBase64 == financialStatementsBase64) &&
            (identical(other.maxCapacity, maxCapacity) ||
                other.maxCapacity == maxCapacity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
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
    legalDocumentationBase64,
    financialStatementsBase64,
    maxCapacity,
  );

  /// Create a copy of RegisterOrganizationInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterOrganizationInputImplCopyWith<_$RegisterOrganizationInputImpl>
  get copyWith =>
      __$$RegisterOrganizationInputImplCopyWithImpl<
        _$RegisterOrganizationInputImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterOrganizationInputImplToJson(this);
  }
}

abstract class _RegisterOrganizationInput implements RegisterOrganizationInput {
  const factory _RegisterOrganizationInput({
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
    final String? legalDocumentationBase64,
    final String? financialStatementsBase64,
    final int? maxCapacity,
  }) = _$RegisterOrganizationInputImpl;

  factory _RegisterOrganizationInput.fromJson(Map<String, dynamic> json) =
      _$RegisterOrganizationInputImpl.fromJson;

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
  String? get legalDocumentationBase64;
  @override
  String? get financialStatementsBase64;
  @override
  int? get maxCapacity;

  /// Create a copy of RegisterOrganizationInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterOrganizationInputImplCopyWith<_$RegisterOrganizationInputImpl>
  get copyWith => throw _privateConstructorUsedError;
}
