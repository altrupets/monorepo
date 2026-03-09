// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get id; String get username; List<UserRole> get roles; bool get isActive; bool get isVerified; DateTime get createdAt; DateTime get updatedAt; String? get email; String? get firstName; String? get lastName; String? get phone; String? get identification; String? get country; String? get province; String? get canton; String? get district; String? get bio; String? get organizationId; double? get latitude; double? get longitude; String? get avatarBase64;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.identification, identification) || other.identification == identification)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton)&&(identical(other.district, district) || other.district == district)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.avatarBase64, avatarBase64) || other.avatarBase64 == avatarBase64));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,username,const DeepCollectionEquality().hash(roles),isActive,isVerified,createdAt,updatedAt,email,firstName,lastName,phone,identification,country,province,canton,district,bio,organizationId,latitude,longitude,avatarBase64]);

@override
String toString() {
  return 'UserModel(id: $id, username: $username, roles: $roles, isActive: $isActive, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, identification: $identification, country: $country, province: $province, canton: $canton, district: $district, bio: $bio, organizationId: $organizationId, latitude: $latitude, longitude: $longitude, avatarBase64: $avatarBase64)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id, String username, List<UserRole> roles, bool isActive, bool isVerified, DateTime createdAt, DateTime updatedAt, String? email, String? firstName, String? lastName, String? phone, String? identification, String? country, String? province, String? canton, String? district, String? bio, String? organizationId, double? latitude, double? longitude, String? avatarBase64
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? roles = null,Object? isActive = null,Object? isVerified = null,Object? createdAt = null,Object? updatedAt = null,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? identification = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,Object? district = freezed,Object? bio = freezed,Object? organizationId = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? avatarBase64 = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<UserRole>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,identification: freezed == identification ? _self.identification : identification // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,canton: freezed == canton ? _self.canton : canton // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,avatarBase64: freezed == avatarBase64 ? _self.avatarBase64 : avatarBase64 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  List<UserRole> roles,  bool isActive,  bool isVerified,  DateTime createdAt,  DateTime updatedAt,  String? email,  String? firstName,  String? lastName,  String? phone,  String? identification,  String? country,  String? province,  String? canton,  String? district,  String? bio,  String? organizationId,  double? latitude,  double? longitude,  String? avatarBase64)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.username,_that.roles,_that.isActive,_that.isVerified,_that.createdAt,_that.updatedAt,_that.email,_that.firstName,_that.lastName,_that.phone,_that.identification,_that.country,_that.province,_that.canton,_that.district,_that.bio,_that.organizationId,_that.latitude,_that.longitude,_that.avatarBase64);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  List<UserRole> roles,  bool isActive,  bool isVerified,  DateTime createdAt,  DateTime updatedAt,  String? email,  String? firstName,  String? lastName,  String? phone,  String? identification,  String? country,  String? province,  String? canton,  String? district,  String? bio,  String? organizationId,  double? latitude,  double? longitude,  String? avatarBase64)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.username,_that.roles,_that.isActive,_that.isVerified,_that.createdAt,_that.updatedAt,_that.email,_that.firstName,_that.lastName,_that.phone,_that.identification,_that.country,_that.province,_that.canton,_that.district,_that.bio,_that.organizationId,_that.latitude,_that.longitude,_that.avatarBase64);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  List<UserRole> roles,  bool isActive,  bool isVerified,  DateTime createdAt,  DateTime updatedAt,  String? email,  String? firstName,  String? lastName,  String? phone,  String? identification,  String? country,  String? province,  String? canton,  String? district,  String? bio,  String? organizationId,  double? latitude,  double? longitude,  String? avatarBase64)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.username,_that.roles,_that.isActive,_that.isVerified,_that.createdAt,_that.updatedAt,_that.email,_that.firstName,_that.lastName,_that.phone,_that.identification,_that.country,_that.province,_that.canton,_that.district,_that.bio,_that.organizationId,_that.latitude,_that.longitude,_that.avatarBase64);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, required this.username, required final  List<UserRole> roles, required this.isActive, required this.isVerified, required this.createdAt, required this.updatedAt, this.email, this.firstName, this.lastName, this.phone, this.identification, this.country, this.province, this.canton, this.district, this.bio, this.organizationId, this.latitude, this.longitude, this.avatarBase64}): _roles = roles;
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;
@override final  String username;
 final  List<UserRole> _roles;
@override List<UserRole> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override final  bool isActive;
@override final  bool isVerified;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? email;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? phone;
@override final  String? identification;
@override final  String? country;
@override final  String? province;
@override final  String? canton;
@override final  String? district;
@override final  String? bio;
@override final  String? organizationId;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? avatarBase64;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.identification, identification) || other.identification == identification)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton)&&(identical(other.district, district) || other.district == district)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.avatarBase64, avatarBase64) || other.avatarBase64 == avatarBase64));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,username,const DeepCollectionEquality().hash(_roles),isActive,isVerified,createdAt,updatedAt,email,firstName,lastName,phone,identification,country,province,canton,district,bio,organizationId,latitude,longitude,avatarBase64]);

@override
String toString() {
  return 'UserModel(id: $id, username: $username, roles: $roles, isActive: $isActive, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, identification: $identification, country: $country, province: $province, canton: $canton, district: $district, bio: $bio, organizationId: $organizationId, latitude: $latitude, longitude: $longitude, avatarBase64: $avatarBase64)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, List<UserRole> roles, bool isActive, bool isVerified, DateTime createdAt, DateTime updatedAt, String? email, String? firstName, String? lastName, String? phone, String? identification, String? country, String? province, String? canton, String? district, String? bio, String? organizationId, double? latitude, double? longitude, String? avatarBase64
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? roles = null,Object? isActive = null,Object? isVerified = null,Object? createdAt = null,Object? updatedAt = null,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? identification = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,Object? district = freezed,Object? bio = freezed,Object? organizationId = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? avatarBase64 = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<UserRole>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,identification: freezed == identification ? _self.identification : identification // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,canton: freezed == canton ? _self.canton : canton // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,avatarBase64: freezed == avatarBase64 ? _self.avatarBase64 : avatarBase64 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserLoginRequest {

 String get username; String get password;
/// Create a copy of UserLoginRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserLoginRequestCopyWith<UserLoginRequest> get copyWith => _$UserLoginRequestCopyWithImpl<UserLoginRequest>(this as UserLoginRequest, _$identity);

  /// Serializes this UserLoginRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserLoginRequest&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password);

@override
String toString() {
  return 'UserLoginRequest(username: $username, password: $password)';
}


}

/// @nodoc
abstract mixin class $UserLoginRequestCopyWith<$Res>  {
  factory $UserLoginRequestCopyWith(UserLoginRequest value, $Res Function(UserLoginRequest) _then) = _$UserLoginRequestCopyWithImpl;
@useResult
$Res call({
 String username, String password
});




}
/// @nodoc
class _$UserLoginRequestCopyWithImpl<$Res>
    implements $UserLoginRequestCopyWith<$Res> {
  _$UserLoginRequestCopyWithImpl(this._self, this._then);

  final UserLoginRequest _self;
  final $Res Function(UserLoginRequest) _then;

/// Create a copy of UserLoginRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserLoginRequest].
extension UserLoginRequestPatterns on UserLoginRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserLoginRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserLoginRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserLoginRequest value)  $default,){
final _that = this;
switch (_that) {
case _UserLoginRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserLoginRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UserLoginRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserLoginRequest() when $default != null:
return $default(_that.username,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password)  $default,) {final _that = this;
switch (_that) {
case _UserLoginRequest():
return $default(_that.username,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password)?  $default,) {final _that = this;
switch (_that) {
case _UserLoginRequest() when $default != null:
return $default(_that.username,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserLoginRequest implements UserLoginRequest {
  const _UserLoginRequest({required this.username, required this.password});
  factory _UserLoginRequest.fromJson(Map<String, dynamic> json) => _$UserLoginRequestFromJson(json);

@override final  String username;
@override final  String password;

/// Create a copy of UserLoginRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserLoginRequestCopyWith<_UserLoginRequest> get copyWith => __$UserLoginRequestCopyWithImpl<_UserLoginRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserLoginRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserLoginRequest&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password);

@override
String toString() {
  return 'UserLoginRequest(username: $username, password: $password)';
}


}

/// @nodoc
abstract mixin class _$UserLoginRequestCopyWith<$Res> implements $UserLoginRequestCopyWith<$Res> {
  factory _$UserLoginRequestCopyWith(_UserLoginRequest value, $Res Function(_UserLoginRequest) _then) = __$UserLoginRequestCopyWithImpl;
@override @useResult
$Res call({
 String username, String password
});




}
/// @nodoc
class __$UserLoginRequestCopyWithImpl<$Res>
    implements _$UserLoginRequestCopyWith<$Res> {
  __$UserLoginRequestCopyWithImpl(this._self, this._then);

  final _UserLoginRequest _self;
  final $Res Function(_UserLoginRequest) _then;

/// Create a copy of UserLoginRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,}) {
  return _then(_UserLoginRequest(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserLoginResponse {

 String get accessToken;
/// Create a copy of UserLoginResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserLoginResponseCopyWith<UserLoginResponse> get copyWith => _$UserLoginResponseCopyWithImpl<UserLoginResponse>(this as UserLoginResponse, _$identity);

  /// Serializes this UserLoginResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserLoginResponse&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken);

@override
String toString() {
  return 'UserLoginResponse(accessToken: $accessToken)';
}


}

/// @nodoc
abstract mixin class $UserLoginResponseCopyWith<$Res>  {
  factory $UserLoginResponseCopyWith(UserLoginResponse value, $Res Function(UserLoginResponse) _then) = _$UserLoginResponseCopyWithImpl;
@useResult
$Res call({
 String accessToken
});




}
/// @nodoc
class _$UserLoginResponseCopyWithImpl<$Res>
    implements $UserLoginResponseCopyWith<$Res> {
  _$UserLoginResponseCopyWithImpl(this._self, this._then);

  final UserLoginResponse _self;
  final $Res Function(UserLoginResponse) _then;

/// Create a copy of UserLoginResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserLoginResponse].
extension UserLoginResponsePatterns on UserLoginResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserLoginResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserLoginResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserLoginResponse value)  $default,){
final _that = this;
switch (_that) {
case _UserLoginResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserLoginResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UserLoginResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserLoginResponse() when $default != null:
return $default(_that.accessToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken)  $default,) {final _that = this;
switch (_that) {
case _UserLoginResponse():
return $default(_that.accessToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken)?  $default,) {final _that = this;
switch (_that) {
case _UserLoginResponse() when $default != null:
return $default(_that.accessToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserLoginResponse implements UserLoginResponse {
  const _UserLoginResponse({required this.accessToken});
  factory _UserLoginResponse.fromJson(Map<String, dynamic> json) => _$UserLoginResponseFromJson(json);

@override final  String accessToken;

/// Create a copy of UserLoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserLoginResponseCopyWith<_UserLoginResponse> get copyWith => __$UserLoginResponseCopyWithImpl<_UserLoginResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserLoginResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserLoginResponse&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken);

@override
String toString() {
  return 'UserLoginResponse(accessToken: $accessToken)';
}


}

/// @nodoc
abstract mixin class _$UserLoginResponseCopyWith<$Res> implements $UserLoginResponseCopyWith<$Res> {
  factory _$UserLoginResponseCopyWith(_UserLoginResponse value, $Res Function(_UserLoginResponse) _then) = __$UserLoginResponseCopyWithImpl;
@override @useResult
$Res call({
 String accessToken
});




}
/// @nodoc
class __$UserLoginResponseCopyWithImpl<$Res>
    implements _$UserLoginResponseCopyWith<$Res> {
  __$UserLoginResponseCopyWithImpl(this._self, this._then);

  final _UserLoginResponse _self;
  final $Res Function(_UserLoginResponse) _then;

/// Create a copy of UserLoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,}) {
  return _then(_UserLoginResponse(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
