// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get username;@JsonKey(fromJson: _rolesFromJson) List<String>? get roles; String? get email; String? get firstName; String? get lastName; String? get phone; String? get identification; String? get country; String? get province; String? get canton; String? get district; String? get occupation; String? get incomeSource; bool? get isActive; bool? get isVerified; String? get avatarBase64;@JsonKey(fromJson: _dateTimeFromJson) DateTime? get createdAt;@JsonKey(fromJson: _dateTimeFromJson) DateTime? get updatedAt;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.identification, identification) || other.identification == identification)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton)&&(identical(other.district, district) || other.district == district)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.incomeSource, incomeSource) || other.incomeSource == incomeSource)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.avatarBase64, avatarBase64) || other.avatarBase64 == avatarBase64)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,username,const DeepCollectionEquality().hash(roles),email,firstName,lastName,phone,identification,country,province,canton,district,occupation,incomeSource,isActive,isVerified,avatarBase64,createdAt,updatedAt]);

@override
String toString() {
  return 'User(id: $id, username: $username, roles: $roles, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, identification: $identification, country: $country, province: $province, canton: $canton, district: $district, occupation: $occupation, incomeSource: $incomeSource, isActive: $isActive, isVerified: $isVerified, avatarBase64: $avatarBase64, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String username,@JsonKey(fromJson: _rolesFromJson) List<String>? roles, String? email, String? firstName, String? lastName, String? phone, String? identification, String? country, String? province, String? canton, String? district, String? occupation, String? incomeSource, bool? isActive, bool? isVerified, String? avatarBase64,@JsonKey(fromJson: _dateTimeFromJson) DateTime? createdAt,@JsonKey(fromJson: _dateTimeFromJson) DateTime? updatedAt
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? roles = freezed,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? identification = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,Object? district = freezed,Object? occupation = freezed,Object? incomeSource = freezed,Object? isActive = freezed,Object? isVerified = freezed,Object? avatarBase64 = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,roles: freezed == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,identification: freezed == identification ? _self.identification : identification // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,canton: freezed == canton ? _self.canton : canton // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,incomeSource: freezed == incomeSource ? _self.incomeSource : incomeSource // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,avatarBase64: freezed == avatarBase64 ? _self.avatarBase64 : avatarBase64 // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(fromJson: _rolesFromJson)  List<String>? roles,  String? email,  String? firstName,  String? lastName,  String? phone,  String? identification,  String? country,  String? province,  String? canton,  String? district,  String? occupation,  String? incomeSource,  bool? isActive,  bool? isVerified,  String? avatarBase64, @JsonKey(fromJson: _dateTimeFromJson)  DateTime? createdAt, @JsonKey(fromJson: _dateTimeFromJson)  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.roles,_that.email,_that.firstName,_that.lastName,_that.phone,_that.identification,_that.country,_that.province,_that.canton,_that.district,_that.occupation,_that.incomeSource,_that.isActive,_that.isVerified,_that.avatarBase64,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(fromJson: _rolesFromJson)  List<String>? roles,  String? email,  String? firstName,  String? lastName,  String? phone,  String? identification,  String? country,  String? province,  String? canton,  String? district,  String? occupation,  String? incomeSource,  bool? isActive,  bool? isVerified,  String? avatarBase64, @JsonKey(fromJson: _dateTimeFromJson)  DateTime? createdAt, @JsonKey(fromJson: _dateTimeFromJson)  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.username,_that.roles,_that.email,_that.firstName,_that.lastName,_that.phone,_that.identification,_that.country,_that.province,_that.canton,_that.district,_that.occupation,_that.incomeSource,_that.isActive,_that.isVerified,_that.avatarBase64,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username, @JsonKey(fromJson: _rolesFromJson)  List<String>? roles,  String? email,  String? firstName,  String? lastName,  String? phone,  String? identification,  String? country,  String? province,  String? canton,  String? district,  String? occupation,  String? incomeSource,  bool? isActive,  bool? isVerified,  String? avatarBase64, @JsonKey(fromJson: _dateTimeFromJson)  DateTime? createdAt, @JsonKey(fromJson: _dateTimeFromJson)  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.roles,_that.email,_that.firstName,_that.lastName,_that.phone,_that.identification,_that.country,_that.province,_that.canton,_that.district,_that.occupation,_that.incomeSource,_that.isActive,_that.isVerified,_that.avatarBase64,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.username, @JsonKey(fromJson: _rolesFromJson) final  List<String>? roles, this.email, this.firstName, this.lastName, this.phone, this.identification, this.country, this.province, this.canton, this.district, this.occupation, this.incomeSource, this.isActive, this.isVerified, this.avatarBase64, @JsonKey(fromJson: _dateTimeFromJson) this.createdAt, @JsonKey(fromJson: _dateTimeFromJson) this.updatedAt}): _roles = roles;
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String username;
 final  List<String>? _roles;
@override@JsonKey(fromJson: _rolesFromJson) List<String>? get roles {
  final value = _roles;
  if (value == null) return null;
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? email;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? phone;
@override final  String? identification;
@override final  String? country;
@override final  String? province;
@override final  String? canton;
@override final  String? district;
@override final  String? occupation;
@override final  String? incomeSource;
@override final  bool? isActive;
@override final  bool? isVerified;
@override final  String? avatarBase64;
@override@JsonKey(fromJson: _dateTimeFromJson) final  DateTime? createdAt;
@override@JsonKey(fromJson: _dateTimeFromJson) final  DateTime? updatedAt;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.identification, identification) || other.identification == identification)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton)&&(identical(other.district, district) || other.district == district)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.incomeSource, incomeSource) || other.incomeSource == incomeSource)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.avatarBase64, avatarBase64) || other.avatarBase64 == avatarBase64)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,username,const DeepCollectionEquality().hash(_roles),email,firstName,lastName,phone,identification,country,province,canton,district,occupation,incomeSource,isActive,isVerified,avatarBase64,createdAt,updatedAt]);

@override
String toString() {
  return 'User(id: $id, username: $username, roles: $roles, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, identification: $identification, country: $country, province: $province, canton: $canton, district: $district, occupation: $occupation, incomeSource: $incomeSource, isActive: $isActive, isVerified: $isVerified, avatarBase64: $avatarBase64, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String username,@JsonKey(fromJson: _rolesFromJson) List<String>? roles, String? email, String? firstName, String? lastName, String? phone, String? identification, String? country, String? province, String? canton, String? district, String? occupation, String? incomeSource, bool? isActive, bool? isVerified, String? avatarBase64,@JsonKey(fromJson: _dateTimeFromJson) DateTime? createdAt,@JsonKey(fromJson: _dateTimeFromJson) DateTime? updatedAt
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? roles = freezed,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? identification = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,Object? district = freezed,Object? occupation = freezed,Object? incomeSource = freezed,Object? isActive = freezed,Object? isVerified = freezed,Object? avatarBase64 = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,roles: freezed == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,identification: freezed == identification ? _self.identification : identification // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,canton: freezed == canton ? _self.canton : canton // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,incomeSource: freezed == incomeSource ? _self.incomeSource : incomeSource // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,avatarBase64: freezed == avatarBase64 ? _self.avatarBase64 : avatarBase64 // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
