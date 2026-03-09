// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrganizationMembership {

 String get id; String get organizationId; String get userId; MembershipStatus get status; OrganizationRole get role; DateTime get createdAt; DateTime get updatedAt; String? get requestMessage; String? get rejectionReason; String? get approvedBy; DateTime? get approvedAt;
/// Create a copy of OrganizationMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationMembershipCopyWith<OrganizationMembership> get copyWith => _$OrganizationMembershipCopyWithImpl<OrganizationMembership>(this as OrganizationMembership, _$identity);

  /// Serializes this OrganizationMembership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.requestMessage, requestMessage) || other.requestMessage == requestMessage)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,userId,status,role,createdAt,updatedAt,requestMessage,rejectionReason,approvedBy,approvedAt);

@override
String toString() {
  return 'OrganizationMembership(id: $id, organizationId: $organizationId, userId: $userId, status: $status, role: $role, createdAt: $createdAt, updatedAt: $updatedAt, requestMessage: $requestMessage, rejectionReason: $rejectionReason, approvedBy: $approvedBy, approvedAt: $approvedAt)';
}


}

/// @nodoc
abstract mixin class $OrganizationMembershipCopyWith<$Res>  {
  factory $OrganizationMembershipCopyWith(OrganizationMembership value, $Res Function(OrganizationMembership) _then) = _$OrganizationMembershipCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String userId, MembershipStatus status, OrganizationRole role, DateTime createdAt, DateTime updatedAt, String? requestMessage, String? rejectionReason, String? approvedBy, DateTime? approvedAt
});




}
/// @nodoc
class _$OrganizationMembershipCopyWithImpl<$Res>
    implements $OrganizationMembershipCopyWith<$Res> {
  _$OrganizationMembershipCopyWithImpl(this._self, this._then);

  final OrganizationMembership _self;
  final $Res Function(OrganizationMembership) _then;

/// Create a copy of OrganizationMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? status = null,Object? role = null,Object? createdAt = null,Object? updatedAt = null,Object? requestMessage = freezed,Object? rejectionReason = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as OrganizationRole,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,requestMessage: freezed == requestMessage ? _self.requestMessage : requestMessage // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationMembership].
extension OrganizationMembershipPatterns on OrganizationMembership {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationMembership() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationMembership value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationMembership():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationMembership value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationMembership() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String userId,  MembershipStatus status,  OrganizationRole role,  DateTime createdAt,  DateTime updatedAt,  String? requestMessage,  String? rejectionReason,  String? approvedBy,  DateTime? approvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationMembership() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.status,_that.role,_that.createdAt,_that.updatedAt,_that.requestMessage,_that.rejectionReason,_that.approvedBy,_that.approvedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String userId,  MembershipStatus status,  OrganizationRole role,  DateTime createdAt,  DateTime updatedAt,  String? requestMessage,  String? rejectionReason,  String? approvedBy,  DateTime? approvedAt)  $default,) {final _that = this;
switch (_that) {
case _OrganizationMembership():
return $default(_that.id,_that.organizationId,_that.userId,_that.status,_that.role,_that.createdAt,_that.updatedAt,_that.requestMessage,_that.rejectionReason,_that.approvedBy,_that.approvedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String userId,  MembershipStatus status,  OrganizationRole role,  DateTime createdAt,  DateTime updatedAt,  String? requestMessage,  String? rejectionReason,  String? approvedBy,  DateTime? approvedAt)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationMembership() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.status,_that.role,_that.createdAt,_that.updatedAt,_that.requestMessage,_that.rejectionReason,_that.approvedBy,_that.approvedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationMembership implements OrganizationMembership {
  const _OrganizationMembership({required this.id, required this.organizationId, required this.userId, required this.status, required this.role, required this.createdAt, required this.updatedAt, this.requestMessage, this.rejectionReason, this.approvedBy, this.approvedAt});
  factory _OrganizationMembership.fromJson(Map<String, dynamic> json) => _$OrganizationMembershipFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String userId;
@override final  MembershipStatus status;
@override final  OrganizationRole role;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? requestMessage;
@override final  String? rejectionReason;
@override final  String? approvedBy;
@override final  DateTime? approvedAt;

/// Create a copy of OrganizationMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationMembershipCopyWith<_OrganizationMembership> get copyWith => __$OrganizationMembershipCopyWithImpl<_OrganizationMembership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationMembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.requestMessage, requestMessage) || other.requestMessage == requestMessage)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,userId,status,role,createdAt,updatedAt,requestMessage,rejectionReason,approvedBy,approvedAt);

@override
String toString() {
  return 'OrganizationMembership(id: $id, organizationId: $organizationId, userId: $userId, status: $status, role: $role, createdAt: $createdAt, updatedAt: $updatedAt, requestMessage: $requestMessage, rejectionReason: $rejectionReason, approvedBy: $approvedBy, approvedAt: $approvedAt)';
}


}

/// @nodoc
abstract mixin class _$OrganizationMembershipCopyWith<$Res> implements $OrganizationMembershipCopyWith<$Res> {
  factory _$OrganizationMembershipCopyWith(_OrganizationMembership value, $Res Function(_OrganizationMembership) _then) = __$OrganizationMembershipCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String userId, MembershipStatus status, OrganizationRole role, DateTime createdAt, DateTime updatedAt, String? requestMessage, String? rejectionReason, String? approvedBy, DateTime? approvedAt
});




}
/// @nodoc
class __$OrganizationMembershipCopyWithImpl<$Res>
    implements _$OrganizationMembershipCopyWith<$Res> {
  __$OrganizationMembershipCopyWithImpl(this._self, this._then);

  final _OrganizationMembership _self;
  final $Res Function(_OrganizationMembership) _then;

/// Create a copy of OrganizationMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? status = null,Object? role = null,Object? createdAt = null,Object? updatedAt = null,Object? requestMessage = freezed,Object? rejectionReason = freezed,Object? approvedBy = freezed,Object? approvedAt = freezed,}) {
  return _then(_OrganizationMembership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as OrganizationRole,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,requestMessage: freezed == requestMessage ? _self.requestMessage : requestMessage // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
