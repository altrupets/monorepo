// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuthPayload _$AuthPayloadFromJson(Map<String, dynamic> json) {
  return _AuthPayload.fromJson(json);
}

/// @nodoc
mixin _$AuthPayload {
  @JsonKey(name: 'access_token')
  String get accessToken => throw _privateConstructorUsedError;

  /// Serializes this AuthPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthPayloadCopyWith<AuthPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthPayloadCopyWith<$Res> {
  factory $AuthPayloadCopyWith(
    AuthPayload value,
    $Res Function(AuthPayload) then,
  ) = _$AuthPayloadCopyWithImpl<$Res, AuthPayload>;
  @useResult
  $Res call({@JsonKey(name: 'access_token') String accessToken});
}

/// @nodoc
class _$AuthPayloadCopyWithImpl<$Res, $Val extends AuthPayload>
    implements $AuthPayloadCopyWith<$Res> {
  _$AuthPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthPayload
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
abstract class _$$AuthPayloadImplCopyWith<$Res>
    implements $AuthPayloadCopyWith<$Res> {
  factory _$$AuthPayloadImplCopyWith(
    _$AuthPayloadImpl value,
    $Res Function(_$AuthPayloadImpl) then,
  ) = __$$AuthPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'access_token') String accessToken});
}

/// @nodoc
class __$$AuthPayloadImplCopyWithImpl<$Res>
    extends _$AuthPayloadCopyWithImpl<$Res, _$AuthPayloadImpl>
    implements _$$AuthPayloadImplCopyWith<$Res> {
  __$$AuthPayloadImplCopyWithImpl(
    _$AuthPayloadImpl _value,
    $Res Function(_$AuthPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? accessToken = null}) {
    return _then(
      _$AuthPayloadImpl(
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
class _$AuthPayloadImpl implements _AuthPayload {
  const _$AuthPayloadImpl({
    @JsonKey(name: 'access_token') required this.accessToken,
  });

  factory _$AuthPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthPayloadImplFromJson(json);

  @override
  @JsonKey(name: 'access_token')
  final String accessToken;

  @override
  String toString() {
    return 'AuthPayload(accessToken: $accessToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthPayloadImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken);

  /// Create a copy of AuthPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthPayloadImplCopyWith<_$AuthPayloadImpl> get copyWith =>
      __$$AuthPayloadImplCopyWithImpl<_$AuthPayloadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthPayloadImplToJson(this);
  }
}

abstract class _AuthPayload implements AuthPayload {
  const factory _AuthPayload({
    @JsonKey(name: 'access_token') required final String accessToken,
  }) = _$AuthPayloadImpl;

  factory _AuthPayload.fromJson(Map<String, dynamic> json) =
      _$AuthPayloadImpl.fromJson;

  @override
  @JsonKey(name: 'access_token')
  String get accessToken;

  /// Create a copy of AuthPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthPayloadImplCopyWith<_$AuthPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
