// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

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
  MembershipStatus get status => throw _privateConstructorUsedError;
  OrganizationRole get role => throw _privateConstructorUsedError;
  String? get requestMessage => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  String? get approvedBy => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

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
    MembershipStatus status,
    OrganizationRole role,
    String? requestMessage,
    String? rejectionReason,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime createdAt,
    DateTime updatedAt,
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
    Object? status = null,
    Object? role = null,
    Object? requestMessage = freezed,
    Object? rejectionReason = freezed,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MembershipStatus,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as OrganizationRole,
            requestMessage: freezed == requestMessage
                ? _value.requestMessage
                : requestMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            rejectionReason: freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            approvedBy: freezed == approvedBy
                ? _value.approvedBy
                : approvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            approvedAt: freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
    MembershipStatus status,
    OrganizationRole role,
    String? requestMessage,
    String? rejectionReason,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime createdAt,
    DateTime updatedAt,
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
    Object? status = null,
    Object? role = null,
    Object? requestMessage = freezed,
    Object? rejectionReason = freezed,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MembershipStatus,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as OrganizationRole,
        requestMessage: freezed == requestMessage
            ? _value.requestMessage
            : requestMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        rejectionReason: freezed == rejectionReason
            ? _value.rejectionReason
            : rejectionReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        approvedBy: freezed == approvedBy
            ? _value.approvedBy
            : approvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        approvedAt: freezed == approvedAt
            ? _value.approvedAt
            : approvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$OrganizationMembershipImpl implements _OrganizationMembership {
  const _$OrganizationMembershipImpl({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.status,
    required this.role,
    this.requestMessage,
    this.rejectionReason,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
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
  final MembershipStatus status;
  @override
  final OrganizationRole role;
  @override
  final String? requestMessage;
  @override
  final String? rejectionReason;
  @override
  final String? approvedBy;
  @override
  final DateTime? approvedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'OrganizationMembership(id: $id, organizationId: $organizationId, userId: $userId, status: $status, role: $role, requestMessage: $requestMessage, rejectionReason: $rejectionReason, approvedBy: $approvedBy, approvedAt: $approvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
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
            (identical(other.status, status) || other.status == status) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.requestMessage, requestMessage) ||
                other.requestMessage == requestMessage) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    organizationId,
    userId,
    status,
    role,
    requestMessage,
    rejectionReason,
    approvedBy,
    approvedAt,
    createdAt,
    updatedAt,
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
    required final MembershipStatus status,
    required final OrganizationRole role,
    final String? requestMessage,
    final String? rejectionReason,
    final String? approvedBy,
    final DateTime? approvedAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
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
  MembershipStatus get status;
  @override
  OrganizationRole get role;
  @override
  String? get requestMessage;
  @override
  String? get rejectionReason;
  @override
  String? get approvedBy;
  @override
  DateTime? get approvedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of OrganizationMembership
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationMembershipImplCopyWith<_$OrganizationMembershipImpl>
  get copyWith => throw _privateConstructorUsedError;
}
