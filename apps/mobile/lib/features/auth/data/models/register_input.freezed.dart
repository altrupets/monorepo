// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterInput {

 String get username; String get password; String? get email; String? get firstName; String? get lastName; String? get phone; String? get identification; String? get country; String? get province; String? get canton; String? get district; String? get occupation; String? get incomeSource; List<String>? get roles;
/// Create a copy of RegisterInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterInputCopyWith<RegisterInput> get copyWith => _$RegisterInputCopyWithImpl<RegisterInput>(this as RegisterInput, _$identity);

  /// Serializes this RegisterInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterInput&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.identification, identification) || other.identification == identification)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton)&&(identical(other.district, district) || other.district == district)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.incomeSource, incomeSource) || other.incomeSource == incomeSource)&&const DeepCollectionEquality().equals(other.roles, roles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password,email,firstName,lastName,phone,identification,country,province,canton,district,occupation,incomeSource,const DeepCollectionEquality().hash(roles));

@override
String toString() {
  return 'RegisterInput(username: $username, password: $password, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, identification: $identification, country: $country, province: $province, canton: $canton, district: $district, occupation: $occupation, incomeSource: $incomeSource, roles: $roles)';
}


}

/// @nodoc
abstract mixin class $RegisterInputCopyWith<$Res>  {
  factory $RegisterInputCopyWith(RegisterInput value, $Res Function(RegisterInput) _then) = _$RegisterInputCopyWithImpl;
@useResult
$Res call({
 String username, String password, String? email, String? firstName, String? lastName, String? phone, String? identification, String? country, String? province, String? canton, String? district, String? occupation, String? incomeSource, List<String>? roles
});




}
/// @nodoc
class _$RegisterInputCopyWithImpl<$Res>
    implements $RegisterInputCopyWith<$Res> {
  _$RegisterInputCopyWithImpl(this._self, this._then);

  final RegisterInput _self;
  final $Res Function(RegisterInput) _then;

/// Create a copy of RegisterInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? identification = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,Object? district = freezed,Object? occupation = freezed,Object? incomeSource = freezed,Object? roles = freezed,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
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
as String?,roles: freezed == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterInput].
extension RegisterInputPatterns on RegisterInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterInput value)  $default,){
final _that = this;
switch (_that) {
case _RegisterInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterInput value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password,  String? email,  String? firstName,  String? lastName,  String? phone,  String? identification,  String? country,  String? province,  String? canton,  String? district,  String? occupation,  String? incomeSource,  List<String>? roles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterInput() when $default != null:
return $default(_that.username,_that.password,_that.email,_that.firstName,_that.lastName,_that.phone,_that.identification,_that.country,_that.province,_that.canton,_that.district,_that.occupation,_that.incomeSource,_that.roles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password,  String? email,  String? firstName,  String? lastName,  String? phone,  String? identification,  String? country,  String? province,  String? canton,  String? district,  String? occupation,  String? incomeSource,  List<String>? roles)  $default,) {final _that = this;
switch (_that) {
case _RegisterInput():
return $default(_that.username,_that.password,_that.email,_that.firstName,_that.lastName,_that.phone,_that.identification,_that.country,_that.province,_that.canton,_that.district,_that.occupation,_that.incomeSource,_that.roles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password,  String? email,  String? firstName,  String? lastName,  String? phone,  String? identification,  String? country,  String? province,  String? canton,  String? district,  String? occupation,  String? incomeSource,  List<String>? roles)?  $default,) {final _that = this;
switch (_that) {
case _RegisterInput() when $default != null:
return $default(_that.username,_that.password,_that.email,_that.firstName,_that.lastName,_that.phone,_that.identification,_that.country,_that.province,_that.canton,_that.district,_that.occupation,_that.incomeSource,_that.roles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterInput implements RegisterInput {
  const _RegisterInput({required this.username, required this.password, this.email, this.firstName, this.lastName, this.phone, this.identification, this.country, this.province, this.canton, this.district, this.occupation, this.incomeSource, final  List<String>? roles}): _roles = roles;
  factory _RegisterInput.fromJson(Map<String, dynamic> json) => _$RegisterInputFromJson(json);

@override final  String username;
@override final  String password;
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
 final  List<String>? _roles;
@override List<String>? get roles {
  final value = _roles;
  if (value == null) return null;
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RegisterInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterInputCopyWith<_RegisterInput> get copyWith => __$RegisterInputCopyWithImpl<_RegisterInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterInput&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.identification, identification) || other.identification == identification)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton)&&(identical(other.district, district) || other.district == district)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.incomeSource, incomeSource) || other.incomeSource == incomeSource)&&const DeepCollectionEquality().equals(other._roles, _roles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password,email,firstName,lastName,phone,identification,country,province,canton,district,occupation,incomeSource,const DeepCollectionEquality().hash(_roles));

@override
String toString() {
  return 'RegisterInput(username: $username, password: $password, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, identification: $identification, country: $country, province: $province, canton: $canton, district: $district, occupation: $occupation, incomeSource: $incomeSource, roles: $roles)';
}


}

/// @nodoc
abstract mixin class _$RegisterInputCopyWith<$Res> implements $RegisterInputCopyWith<$Res> {
  factory _$RegisterInputCopyWith(_RegisterInput value, $Res Function(_RegisterInput) _then) = __$RegisterInputCopyWithImpl;
@override @useResult
$Res call({
 String username, String password, String? email, String? firstName, String? lastName, String? phone, String? identification, String? country, String? province, String? canton, String? district, String? occupation, String? incomeSource, List<String>? roles
});




}
/// @nodoc
class __$RegisterInputCopyWithImpl<$Res>
    implements _$RegisterInputCopyWith<$Res> {
  __$RegisterInputCopyWithImpl(this._self, this._then);

  final _RegisterInput _self;
  final $Res Function(_RegisterInput) _then;

/// Create a copy of RegisterInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? identification = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,Object? district = freezed,Object? occupation = freezed,Object? incomeSource = freezed,Object? roles = freezed,}) {
  return _then(_RegisterInput(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
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
as String?,roles: freezed == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
