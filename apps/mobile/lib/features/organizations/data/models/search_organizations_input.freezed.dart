// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_organizations_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SearchOrganizationsInput _$SearchOrganizationsInputFromJson(
  Map<String, dynamic> json,
) {
  return _SearchOrganizationsInput.fromJson(json);
}

/// @nodoc
mixin _$SearchOrganizationsInput {
  String? get name => throw _privateConstructorUsedError;
  OrganizationType? get type => throw _privateConstructorUsedError;
  OrganizationStatus? get status => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get province => throw _privateConstructorUsedError;
  String? get canton => throw _privateConstructorUsedError;

  /// Serializes this SearchOrganizationsInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchOrganizationsInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchOrganizationsInputCopyWith<SearchOrganizationsInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchOrganizationsInputCopyWith<$Res> {
  factory $SearchOrganizationsInputCopyWith(
    SearchOrganizationsInput value,
    $Res Function(SearchOrganizationsInput) then,
  ) = _$SearchOrganizationsInputCopyWithImpl<$Res, SearchOrganizationsInput>;
  @useResult
  $Res call({
    String? name,
    OrganizationType? type,
    OrganizationStatus? status,
    String? country,
    String? province,
    String? canton,
  });
}

/// @nodoc
class _$SearchOrganizationsInputCopyWithImpl<
  $Res,
  $Val extends SearchOrganizationsInput
>
    implements $SearchOrganizationsInputCopyWith<$Res> {
  _$SearchOrganizationsInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchOrganizationsInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? type = freezed,
    Object? status = freezed,
    Object? country = freezed,
    Object? province = freezed,
    Object? canton = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as OrganizationType?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrganizationStatus?,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchOrganizationsInputImplCopyWith<$Res>
    implements $SearchOrganizationsInputCopyWith<$Res> {
  factory _$$SearchOrganizationsInputImplCopyWith(
    _$SearchOrganizationsInputImpl value,
    $Res Function(_$SearchOrganizationsInputImpl) then,
  ) = __$$SearchOrganizationsInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    OrganizationType? type,
    OrganizationStatus? status,
    String? country,
    String? province,
    String? canton,
  });
}

/// @nodoc
class __$$SearchOrganizationsInputImplCopyWithImpl<$Res>
    extends
        _$SearchOrganizationsInputCopyWithImpl<
          $Res,
          _$SearchOrganizationsInputImpl
        >
    implements _$$SearchOrganizationsInputImplCopyWith<$Res> {
  __$$SearchOrganizationsInputImplCopyWithImpl(
    _$SearchOrganizationsInputImpl _value,
    $Res Function(_$SearchOrganizationsInputImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchOrganizationsInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? type = freezed,
    Object? status = freezed,
    Object? country = freezed,
    Object? province = freezed,
    Object? canton = freezed,
  }) {
    return _then(
      _$SearchOrganizationsInputImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as OrganizationType?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrganizationStatus?,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchOrganizationsInputImpl implements _SearchOrganizationsInput {
  const _$SearchOrganizationsInputImpl({
    this.name,
    this.type,
    this.status,
    this.country,
    this.province,
    this.canton,
  });

  factory _$SearchOrganizationsInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchOrganizationsInputImplFromJson(json);

  @override
  final String? name;
  @override
  final OrganizationType? type;
  @override
  final OrganizationStatus? status;
  @override
  final String? country;
  @override
  final String? province;
  @override
  final String? canton;

  @override
  String toString() {
    return 'SearchOrganizationsInput(name: $name, type: $type, status: $status, country: $country, province: $province, canton: $canton)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchOrganizationsInputImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.province, province) ||
                other.province == province) &&
            (identical(other.canton, canton) || other.canton == canton));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, type, status, country, province, canton);

  /// Create a copy of SearchOrganizationsInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchOrganizationsInputImplCopyWith<_$SearchOrganizationsInputImpl>
  get copyWith =>
      __$$SearchOrganizationsInputImplCopyWithImpl<
        _$SearchOrganizationsInputImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchOrganizationsInputImplToJson(this);
  }
}

abstract class _SearchOrganizationsInput implements SearchOrganizationsInput {
  const factory _SearchOrganizationsInput({
    final String? name,
    final OrganizationType? type,
    final OrganizationStatus? status,
    final String? country,
    final String? province,
    final String? canton,
  }) = _$SearchOrganizationsInputImpl;

  factory _SearchOrganizationsInput.fromJson(Map<String, dynamic> json) =
      _$SearchOrganizationsInputImpl.fromJson;

  @override
  String? get name;
  @override
  OrganizationType? get type;
  @override
  OrganizationStatus? get status;
  @override
  String? get country;
  @override
  String? get province;
  @override
  String? get canton;

  /// Create a copy of SearchOrganizationsInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchOrganizationsInputImplCopyWith<_$SearchOrganizationsInputImpl>
  get copyWith => throw _privateConstructorUsedError;
}
