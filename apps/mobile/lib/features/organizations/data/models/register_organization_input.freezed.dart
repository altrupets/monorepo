// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_organization_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterOrganizationInput {

 String get name; OrganizationType get type; String? get legalId; String? get description; String? get email; String? get phone; String? get website; String? get address; String? get country; String? get province; String? get canton; String? get district; String? get legalDocumentationBase64; String? get financialStatementsBase64; int? get maxCapacity;
/// Create a copy of RegisterOrganizationInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterOrganizationInputCopyWith<RegisterOrganizationInput> get copyWith => _$RegisterOrganizationInputCopyWithImpl<RegisterOrganizationInput>(this as RegisterOrganizationInput, _$identity);

  /// Serializes this RegisterOrganizationInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterOrganizationInput&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.legalId, legalId) || other.legalId == legalId)&&(identical(other.description, description) || other.description == description)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.address, address) || other.address == address)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton)&&(identical(other.district, district) || other.district == district)&&(identical(other.legalDocumentationBase64, legalDocumentationBase64) || other.legalDocumentationBase64 == legalDocumentationBase64)&&(identical(other.financialStatementsBase64, financialStatementsBase64) || other.financialStatementsBase64 == financialStatementsBase64)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,legalId,description,email,phone,website,address,country,province,canton,district,legalDocumentationBase64,financialStatementsBase64,maxCapacity);

@override
String toString() {
  return 'RegisterOrganizationInput(name: $name, type: $type, legalId: $legalId, description: $description, email: $email, phone: $phone, website: $website, address: $address, country: $country, province: $province, canton: $canton, district: $district, legalDocumentationBase64: $legalDocumentationBase64, financialStatementsBase64: $financialStatementsBase64, maxCapacity: $maxCapacity)';
}


}

/// @nodoc
abstract mixin class $RegisterOrganizationInputCopyWith<$Res>  {
  factory $RegisterOrganizationInputCopyWith(RegisterOrganizationInput value, $Res Function(RegisterOrganizationInput) _then) = _$RegisterOrganizationInputCopyWithImpl;
@useResult
$Res call({
 String name, OrganizationType type, String? legalId, String? description, String? email, String? phone, String? website, String? address, String? country, String? province, String? canton, String? district, String? legalDocumentationBase64, String? financialStatementsBase64, int? maxCapacity
});




}
/// @nodoc
class _$RegisterOrganizationInputCopyWithImpl<$Res>
    implements $RegisterOrganizationInputCopyWith<$Res> {
  _$RegisterOrganizationInputCopyWithImpl(this._self, this._then);

  final RegisterOrganizationInput _self;
  final $Res Function(RegisterOrganizationInput) _then;

/// Create a copy of RegisterOrganizationInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? legalId = freezed,Object? description = freezed,Object? email = freezed,Object? phone = freezed,Object? website = freezed,Object? address = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,Object? district = freezed,Object? legalDocumentationBase64 = freezed,Object? financialStatementsBase64 = freezed,Object? maxCapacity = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrganizationType,legalId: freezed == legalId ? _self.legalId : legalId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,canton: freezed == canton ? _self.canton : canton // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,legalDocumentationBase64: freezed == legalDocumentationBase64 ? _self.legalDocumentationBase64 : legalDocumentationBase64 // ignore: cast_nullable_to_non_nullable
as String?,financialStatementsBase64: freezed == financialStatementsBase64 ? _self.financialStatementsBase64 : financialStatementsBase64 // ignore: cast_nullable_to_non_nullable
as String?,maxCapacity: freezed == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterOrganizationInput].
extension RegisterOrganizationInputPatterns on RegisterOrganizationInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterOrganizationInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterOrganizationInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterOrganizationInput value)  $default,){
final _that = this;
switch (_that) {
case _RegisterOrganizationInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterOrganizationInput value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterOrganizationInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  OrganizationType type,  String? legalId,  String? description,  String? email,  String? phone,  String? website,  String? address,  String? country,  String? province,  String? canton,  String? district,  String? legalDocumentationBase64,  String? financialStatementsBase64,  int? maxCapacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterOrganizationInput() when $default != null:
return $default(_that.name,_that.type,_that.legalId,_that.description,_that.email,_that.phone,_that.website,_that.address,_that.country,_that.province,_that.canton,_that.district,_that.legalDocumentationBase64,_that.financialStatementsBase64,_that.maxCapacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  OrganizationType type,  String? legalId,  String? description,  String? email,  String? phone,  String? website,  String? address,  String? country,  String? province,  String? canton,  String? district,  String? legalDocumentationBase64,  String? financialStatementsBase64,  int? maxCapacity)  $default,) {final _that = this;
switch (_that) {
case _RegisterOrganizationInput():
return $default(_that.name,_that.type,_that.legalId,_that.description,_that.email,_that.phone,_that.website,_that.address,_that.country,_that.province,_that.canton,_that.district,_that.legalDocumentationBase64,_that.financialStatementsBase64,_that.maxCapacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  OrganizationType type,  String? legalId,  String? description,  String? email,  String? phone,  String? website,  String? address,  String? country,  String? province,  String? canton,  String? district,  String? legalDocumentationBase64,  String? financialStatementsBase64,  int? maxCapacity)?  $default,) {final _that = this;
switch (_that) {
case _RegisterOrganizationInput() when $default != null:
return $default(_that.name,_that.type,_that.legalId,_that.description,_that.email,_that.phone,_that.website,_that.address,_that.country,_that.province,_that.canton,_that.district,_that.legalDocumentationBase64,_that.financialStatementsBase64,_that.maxCapacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterOrganizationInput implements RegisterOrganizationInput {
  const _RegisterOrganizationInput({required this.name, required this.type, this.legalId, this.description, this.email, this.phone, this.website, this.address, this.country, this.province, this.canton, this.district, this.legalDocumentationBase64, this.financialStatementsBase64, this.maxCapacity});
  factory _RegisterOrganizationInput.fromJson(Map<String, dynamic> json) => _$RegisterOrganizationInputFromJson(json);

@override final  String name;
@override final  OrganizationType type;
@override final  String? legalId;
@override final  String? description;
@override final  String? email;
@override final  String? phone;
@override final  String? website;
@override final  String? address;
@override final  String? country;
@override final  String? province;
@override final  String? canton;
@override final  String? district;
@override final  String? legalDocumentationBase64;
@override final  String? financialStatementsBase64;
@override final  int? maxCapacity;

/// Create a copy of RegisterOrganizationInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterOrganizationInputCopyWith<_RegisterOrganizationInput> get copyWith => __$RegisterOrganizationInputCopyWithImpl<_RegisterOrganizationInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterOrganizationInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterOrganizationInput&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.legalId, legalId) || other.legalId == legalId)&&(identical(other.description, description) || other.description == description)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.address, address) || other.address == address)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton)&&(identical(other.district, district) || other.district == district)&&(identical(other.legalDocumentationBase64, legalDocumentationBase64) || other.legalDocumentationBase64 == legalDocumentationBase64)&&(identical(other.financialStatementsBase64, financialStatementsBase64) || other.financialStatementsBase64 == financialStatementsBase64)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,legalId,description,email,phone,website,address,country,province,canton,district,legalDocumentationBase64,financialStatementsBase64,maxCapacity);

@override
String toString() {
  return 'RegisterOrganizationInput(name: $name, type: $type, legalId: $legalId, description: $description, email: $email, phone: $phone, website: $website, address: $address, country: $country, province: $province, canton: $canton, district: $district, legalDocumentationBase64: $legalDocumentationBase64, financialStatementsBase64: $financialStatementsBase64, maxCapacity: $maxCapacity)';
}


}

/// @nodoc
abstract mixin class _$RegisterOrganizationInputCopyWith<$Res> implements $RegisterOrganizationInputCopyWith<$Res> {
  factory _$RegisterOrganizationInputCopyWith(_RegisterOrganizationInput value, $Res Function(_RegisterOrganizationInput) _then) = __$RegisterOrganizationInputCopyWithImpl;
@override @useResult
$Res call({
 String name, OrganizationType type, String? legalId, String? description, String? email, String? phone, String? website, String? address, String? country, String? province, String? canton, String? district, String? legalDocumentationBase64, String? financialStatementsBase64, int? maxCapacity
});




}
/// @nodoc
class __$RegisterOrganizationInputCopyWithImpl<$Res>
    implements _$RegisterOrganizationInputCopyWith<$Res> {
  __$RegisterOrganizationInputCopyWithImpl(this._self, this._then);

  final _RegisterOrganizationInput _self;
  final $Res Function(_RegisterOrganizationInput) _then;

/// Create a copy of RegisterOrganizationInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? legalId = freezed,Object? description = freezed,Object? email = freezed,Object? phone = freezed,Object? website = freezed,Object? address = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,Object? district = freezed,Object? legalDocumentationBase64 = freezed,Object? financialStatementsBase64 = freezed,Object? maxCapacity = freezed,}) {
  return _then(_RegisterOrganizationInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrganizationType,legalId: freezed == legalId ? _self.legalId : legalId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,canton: freezed == canton ? _self.canton : canton // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,legalDocumentationBase64: freezed == legalDocumentationBase64 ? _self.legalDocumentationBase64 : legalDocumentationBase64 // ignore: cast_nullable_to_non_nullable
as String?,financialStatementsBase64: freezed == financialStatementsBase64 ? _self.financialStatementsBase64 : financialStatementsBase64 // ignore: cast_nullable_to_non_nullable
as String?,maxCapacity: freezed == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
