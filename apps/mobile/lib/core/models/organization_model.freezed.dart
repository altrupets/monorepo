// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrganizationModel {

 String get id; String get name; OrganizationType get type; String? get description; String? get logoUrl; String? get website; String? get email; String? get phoneNumber; String? get address; double? get latitude; double? get longitude; String get legalRepresentativeId; bool get isVerified; bool get isActive; DateTime get createdAt; DateTime get updatedAt; String? get taxId; String? get registrationNumber;
/// Create a copy of OrganizationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationModelCopyWith<OrganizationModel> get copyWith => _$OrganizationModelCopyWithImpl<OrganizationModel>(this as OrganizationModel, _$identity);

  /// Serializes this OrganizationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.website, website) || other.website == website)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.legalRepresentativeId, legalRepresentativeId) || other.legalRepresentativeId == legalRepresentativeId)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,description,logoUrl,website,email,phoneNumber,address,latitude,longitude,legalRepresentativeId,isVerified,isActive,createdAt,updatedAt,taxId,registrationNumber);

@override
String toString() {
  return 'OrganizationModel(id: $id, name: $name, type: $type, description: $description, logoUrl: $logoUrl, website: $website, email: $email, phoneNumber: $phoneNumber, address: $address, latitude: $latitude, longitude: $longitude, legalRepresentativeId: $legalRepresentativeId, isVerified: $isVerified, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, taxId: $taxId, registrationNumber: $registrationNumber)';
}


}

/// @nodoc
abstract mixin class $OrganizationModelCopyWith<$Res>  {
  factory $OrganizationModelCopyWith(OrganizationModel value, $Res Function(OrganizationModel) _then) = _$OrganizationModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, OrganizationType type, String? description, String? logoUrl, String? website, String? email, String? phoneNumber, String? address, double? latitude, double? longitude, String legalRepresentativeId, bool isVerified, bool isActive, DateTime createdAt, DateTime updatedAt, String? taxId, String? registrationNumber
});




}
/// @nodoc
class _$OrganizationModelCopyWithImpl<$Res>
    implements $OrganizationModelCopyWith<$Res> {
  _$OrganizationModelCopyWithImpl(this._self, this._then);

  final OrganizationModel _self;
  final $Res Function(OrganizationModel) _then;

/// Create a copy of OrganizationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? description = freezed,Object? logoUrl = freezed,Object? website = freezed,Object? email = freezed,Object? phoneNumber = freezed,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? legalRepresentativeId = null,Object? isVerified = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? taxId = freezed,Object? registrationNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrganizationType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,legalRepresentativeId: null == legalRepresentativeId ? _self.legalRepresentativeId : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationModel].
extension OrganizationModelPatterns on OrganizationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationModel value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  OrganizationType type,  String? description,  String? logoUrl,  String? website,  String? email,  String? phoneNumber,  String? address,  double? latitude,  double? longitude,  String legalRepresentativeId,  bool isVerified,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? taxId,  String? registrationNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationModel() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.description,_that.logoUrl,_that.website,_that.email,_that.phoneNumber,_that.address,_that.latitude,_that.longitude,_that.legalRepresentativeId,_that.isVerified,_that.isActive,_that.createdAt,_that.updatedAt,_that.taxId,_that.registrationNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  OrganizationType type,  String? description,  String? logoUrl,  String? website,  String? email,  String? phoneNumber,  String? address,  double? latitude,  double? longitude,  String legalRepresentativeId,  bool isVerified,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? taxId,  String? registrationNumber)  $default,) {final _that = this;
switch (_that) {
case _OrganizationModel():
return $default(_that.id,_that.name,_that.type,_that.description,_that.logoUrl,_that.website,_that.email,_that.phoneNumber,_that.address,_that.latitude,_that.longitude,_that.legalRepresentativeId,_that.isVerified,_that.isActive,_that.createdAt,_that.updatedAt,_that.taxId,_that.registrationNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  OrganizationType type,  String? description,  String? logoUrl,  String? website,  String? email,  String? phoneNumber,  String? address,  double? latitude,  double? longitude,  String legalRepresentativeId,  bool isVerified,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? taxId,  String? registrationNumber)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationModel() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.description,_that.logoUrl,_that.website,_that.email,_that.phoneNumber,_that.address,_that.latitude,_that.longitude,_that.legalRepresentativeId,_that.isVerified,_that.isActive,_that.createdAt,_that.updatedAt,_that.taxId,_that.registrationNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationModel implements OrganizationModel {
  const _OrganizationModel({required this.id, required this.name, required this.type, required this.description, required this.logoUrl, required this.website, required this.email, required this.phoneNumber, required this.address, required this.latitude, required this.longitude, required this.legalRepresentativeId, required this.isVerified, required this.isActive, required this.createdAt, required this.updatedAt, required this.taxId, required this.registrationNumber});
  factory _OrganizationModel.fromJson(Map<String, dynamic> json) => _$OrganizationModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  OrganizationType type;
@override final  String? description;
@override final  String? logoUrl;
@override final  String? website;
@override final  String? email;
@override final  String? phoneNumber;
@override final  String? address;
@override final  double? latitude;
@override final  double? longitude;
@override final  String legalRepresentativeId;
@override final  bool isVerified;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? taxId;
@override final  String? registrationNumber;

/// Create a copy of OrganizationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationModelCopyWith<_OrganizationModel> get copyWith => __$OrganizationModelCopyWithImpl<_OrganizationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.website, website) || other.website == website)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.legalRepresentativeId, legalRepresentativeId) || other.legalRepresentativeId == legalRepresentativeId)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,description,logoUrl,website,email,phoneNumber,address,latitude,longitude,legalRepresentativeId,isVerified,isActive,createdAt,updatedAt,taxId,registrationNumber);

@override
String toString() {
  return 'OrganizationModel(id: $id, name: $name, type: $type, description: $description, logoUrl: $logoUrl, website: $website, email: $email, phoneNumber: $phoneNumber, address: $address, latitude: $latitude, longitude: $longitude, legalRepresentativeId: $legalRepresentativeId, isVerified: $isVerified, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, taxId: $taxId, registrationNumber: $registrationNumber)';
}


}

/// @nodoc
abstract mixin class _$OrganizationModelCopyWith<$Res> implements $OrganizationModelCopyWith<$Res> {
  factory _$OrganizationModelCopyWith(_OrganizationModel value, $Res Function(_OrganizationModel) _then) = __$OrganizationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, OrganizationType type, String? description, String? logoUrl, String? website, String? email, String? phoneNumber, String? address, double? latitude, double? longitude, String legalRepresentativeId, bool isVerified, bool isActive, DateTime createdAt, DateTime updatedAt, String? taxId, String? registrationNumber
});




}
/// @nodoc
class __$OrganizationModelCopyWithImpl<$Res>
    implements _$OrganizationModelCopyWith<$Res> {
  __$OrganizationModelCopyWithImpl(this._self, this._then);

  final _OrganizationModel _self;
  final $Res Function(_OrganizationModel) _then;

/// Create a copy of OrganizationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? description = freezed,Object? logoUrl = freezed,Object? website = freezed,Object? email = freezed,Object? phoneNumber = freezed,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? legalRepresentativeId = null,Object? isVerified = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? taxId = freezed,Object? registrationNumber = freezed,}) {
  return _then(_OrganizationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrganizationType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,legalRepresentativeId: null == legalRepresentativeId ? _self.legalRepresentativeId : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OrganizationCreateRequest {

 String get name; OrganizationType get type; String? get description; String? get website; String? get email; String? get phoneNumber; String? get address; double? get latitude; double? get longitude; String get legalRepresentativeId; String? get taxId; String? get registrationNumber;
/// Create a copy of OrganizationCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationCreateRequestCopyWith<OrganizationCreateRequest> get copyWith => _$OrganizationCreateRequestCopyWithImpl<OrganizationCreateRequest>(this as OrganizationCreateRequest, _$identity);

  /// Serializes this OrganizationCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationCreateRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.website, website) || other.website == website)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.legalRepresentativeId, legalRepresentativeId) || other.legalRepresentativeId == legalRepresentativeId)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,description,website,email,phoneNumber,address,latitude,longitude,legalRepresentativeId,taxId,registrationNumber);

@override
String toString() {
  return 'OrganizationCreateRequest(name: $name, type: $type, description: $description, website: $website, email: $email, phoneNumber: $phoneNumber, address: $address, latitude: $latitude, longitude: $longitude, legalRepresentativeId: $legalRepresentativeId, taxId: $taxId, registrationNumber: $registrationNumber)';
}


}

/// @nodoc
abstract mixin class $OrganizationCreateRequestCopyWith<$Res>  {
  factory $OrganizationCreateRequestCopyWith(OrganizationCreateRequest value, $Res Function(OrganizationCreateRequest) _then) = _$OrganizationCreateRequestCopyWithImpl;
@useResult
$Res call({
 String name, OrganizationType type, String? description, String? website, String? email, String? phoneNumber, String? address, double? latitude, double? longitude, String legalRepresentativeId, String? taxId, String? registrationNumber
});




}
/// @nodoc
class _$OrganizationCreateRequestCopyWithImpl<$Res>
    implements $OrganizationCreateRequestCopyWith<$Res> {
  _$OrganizationCreateRequestCopyWithImpl(this._self, this._then);

  final OrganizationCreateRequest _self;
  final $Res Function(OrganizationCreateRequest) _then;

/// Create a copy of OrganizationCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? description = freezed,Object? website = freezed,Object? email = freezed,Object? phoneNumber = freezed,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? legalRepresentativeId = null,Object? taxId = freezed,Object? registrationNumber = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrganizationType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,legalRepresentativeId: null == legalRepresentativeId ? _self.legalRepresentativeId : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationCreateRequest].
extension OrganizationCreateRequestPatterns on OrganizationCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  OrganizationType type,  String? description,  String? website,  String? email,  String? phoneNumber,  String? address,  double? latitude,  double? longitude,  String legalRepresentativeId,  String? taxId,  String? registrationNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationCreateRequest() when $default != null:
return $default(_that.name,_that.type,_that.description,_that.website,_that.email,_that.phoneNumber,_that.address,_that.latitude,_that.longitude,_that.legalRepresentativeId,_that.taxId,_that.registrationNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  OrganizationType type,  String? description,  String? website,  String? email,  String? phoneNumber,  String? address,  double? latitude,  double? longitude,  String legalRepresentativeId,  String? taxId,  String? registrationNumber)  $default,) {final _that = this;
switch (_that) {
case _OrganizationCreateRequest():
return $default(_that.name,_that.type,_that.description,_that.website,_that.email,_that.phoneNumber,_that.address,_that.latitude,_that.longitude,_that.legalRepresentativeId,_that.taxId,_that.registrationNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  OrganizationType type,  String? description,  String? website,  String? email,  String? phoneNumber,  String? address,  double? latitude,  double? longitude,  String legalRepresentativeId,  String? taxId,  String? registrationNumber)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationCreateRequest() when $default != null:
return $default(_that.name,_that.type,_that.description,_that.website,_that.email,_that.phoneNumber,_that.address,_that.latitude,_that.longitude,_that.legalRepresentativeId,_that.taxId,_that.registrationNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationCreateRequest implements OrganizationCreateRequest {
  const _OrganizationCreateRequest({required this.name, required this.type, required this.description, required this.website, required this.email, required this.phoneNumber, required this.address, required this.latitude, required this.longitude, required this.legalRepresentativeId, required this.taxId, required this.registrationNumber});
  factory _OrganizationCreateRequest.fromJson(Map<String, dynamic> json) => _$OrganizationCreateRequestFromJson(json);

@override final  String name;
@override final  OrganizationType type;
@override final  String? description;
@override final  String? website;
@override final  String? email;
@override final  String? phoneNumber;
@override final  String? address;
@override final  double? latitude;
@override final  double? longitude;
@override final  String legalRepresentativeId;
@override final  String? taxId;
@override final  String? registrationNumber;

/// Create a copy of OrganizationCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationCreateRequestCopyWith<_OrganizationCreateRequest> get copyWith => __$OrganizationCreateRequestCopyWithImpl<_OrganizationCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationCreateRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.website, website) || other.website == website)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.legalRepresentativeId, legalRepresentativeId) || other.legalRepresentativeId == legalRepresentativeId)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,description,website,email,phoneNumber,address,latitude,longitude,legalRepresentativeId,taxId,registrationNumber);

@override
String toString() {
  return 'OrganizationCreateRequest(name: $name, type: $type, description: $description, website: $website, email: $email, phoneNumber: $phoneNumber, address: $address, latitude: $latitude, longitude: $longitude, legalRepresentativeId: $legalRepresentativeId, taxId: $taxId, registrationNumber: $registrationNumber)';
}


}

/// @nodoc
abstract mixin class _$OrganizationCreateRequestCopyWith<$Res> implements $OrganizationCreateRequestCopyWith<$Res> {
  factory _$OrganizationCreateRequestCopyWith(_OrganizationCreateRequest value, $Res Function(_OrganizationCreateRequest) _then) = __$OrganizationCreateRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, OrganizationType type, String? description, String? website, String? email, String? phoneNumber, String? address, double? latitude, double? longitude, String legalRepresentativeId, String? taxId, String? registrationNumber
});




}
/// @nodoc
class __$OrganizationCreateRequestCopyWithImpl<$Res>
    implements _$OrganizationCreateRequestCopyWith<$Res> {
  __$OrganizationCreateRequestCopyWithImpl(this._self, this._then);

  final _OrganizationCreateRequest _self;
  final $Res Function(_OrganizationCreateRequest) _then;

/// Create a copy of OrganizationCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? description = freezed,Object? website = freezed,Object? email = freezed,Object? phoneNumber = freezed,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? legalRepresentativeId = null,Object? taxId = freezed,Object? registrationNumber = freezed,}) {
  return _then(_OrganizationCreateRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrganizationType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,legalRepresentativeId: null == legalRepresentativeId ? _self.legalRepresentativeId : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OrganizationMembership {

 String get id; String get organizationId; String get userId; UserRole get role; bool get isApproved; DateTime get joinedAt; DateTime? get approvedAt; String? get approvedBy;
/// Create a copy of OrganizationMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationMembershipCopyWith<OrganizationMembership> get copyWith => _$OrganizationMembershipCopyWithImpl<OrganizationMembership>(this as OrganizationMembership, _$identity);

  /// Serializes this OrganizationMembership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.isApproved, isApproved) || other.isApproved == isApproved)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,userId,role,isApproved,joinedAt,approvedAt,approvedBy);

@override
String toString() {
  return 'OrganizationMembership(id: $id, organizationId: $organizationId, userId: $userId, role: $role, isApproved: $isApproved, joinedAt: $joinedAt, approvedAt: $approvedAt, approvedBy: $approvedBy)';
}


}

/// @nodoc
abstract mixin class $OrganizationMembershipCopyWith<$Res>  {
  factory $OrganizationMembershipCopyWith(OrganizationMembership value, $Res Function(OrganizationMembership) _then) = _$OrganizationMembershipCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String userId, UserRole role, bool isApproved, DateTime joinedAt, DateTime? approvedAt, String? approvedBy
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? role = null,Object? isApproved = null,Object? joinedAt = null,Object? approvedAt = freezed,Object? approvedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,isApproved: null == isApproved ? _self.isApproved : isApproved // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String userId,  UserRole role,  bool isApproved,  DateTime joinedAt,  DateTime? approvedAt,  String? approvedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationMembership() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.role,_that.isApproved,_that.joinedAt,_that.approvedAt,_that.approvedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String userId,  UserRole role,  bool isApproved,  DateTime joinedAt,  DateTime? approvedAt,  String? approvedBy)  $default,) {final _that = this;
switch (_that) {
case _OrganizationMembership():
return $default(_that.id,_that.organizationId,_that.userId,_that.role,_that.isApproved,_that.joinedAt,_that.approvedAt,_that.approvedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String userId,  UserRole role,  bool isApproved,  DateTime joinedAt,  DateTime? approvedAt,  String? approvedBy)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationMembership() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.role,_that.isApproved,_that.joinedAt,_that.approvedAt,_that.approvedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationMembership implements OrganizationMembership {
  const _OrganizationMembership({required this.id, required this.organizationId, required this.userId, required this.role, required this.isApproved, required this.joinedAt, required this.approvedAt, required this.approvedBy});
  factory _OrganizationMembership.fromJson(Map<String, dynamic> json) => _$OrganizationMembershipFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String userId;
@override final  UserRole role;
@override final  bool isApproved;
@override final  DateTime joinedAt;
@override final  DateTime? approvedAt;
@override final  String? approvedBy;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.isApproved, isApproved) || other.isApproved == isApproved)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,userId,role,isApproved,joinedAt,approvedAt,approvedBy);

@override
String toString() {
  return 'OrganizationMembership(id: $id, organizationId: $organizationId, userId: $userId, role: $role, isApproved: $isApproved, joinedAt: $joinedAt, approvedAt: $approvedAt, approvedBy: $approvedBy)';
}


}

/// @nodoc
abstract mixin class _$OrganizationMembershipCopyWith<$Res> implements $OrganizationMembershipCopyWith<$Res> {
  factory _$OrganizationMembershipCopyWith(_OrganizationMembership value, $Res Function(_OrganizationMembership) _then) = __$OrganizationMembershipCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String userId, UserRole role, bool isApproved, DateTime joinedAt, DateTime? approvedAt, String? approvedBy
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? role = null,Object? isApproved = null,Object? joinedAt = null,Object? approvedAt = freezed,Object? approvedBy = freezed,}) {
  return _then(_OrganizationMembership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,isApproved: null == isApproved ? _self.isApproved : isApproved // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OrganizationMembershipRequest {

 String get organizationId; String get userId; UserRole get role;
/// Create a copy of OrganizationMembershipRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationMembershipRequestCopyWith<OrganizationMembershipRequest> get copyWith => _$OrganizationMembershipRequestCopyWithImpl<OrganizationMembershipRequest>(this as OrganizationMembershipRequest, _$identity);

  /// Serializes this OrganizationMembershipRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationMembershipRequest&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,organizationId,userId,role);

@override
String toString() {
  return 'OrganizationMembershipRequest(organizationId: $organizationId, userId: $userId, role: $role)';
}


}

/// @nodoc
abstract mixin class $OrganizationMembershipRequestCopyWith<$Res>  {
  factory $OrganizationMembershipRequestCopyWith(OrganizationMembershipRequest value, $Res Function(OrganizationMembershipRequest) _then) = _$OrganizationMembershipRequestCopyWithImpl;
@useResult
$Res call({
 String organizationId, String userId, UserRole role
});




}
/// @nodoc
class _$OrganizationMembershipRequestCopyWithImpl<$Res>
    implements $OrganizationMembershipRequestCopyWith<$Res> {
  _$OrganizationMembershipRequestCopyWithImpl(this._self, this._then);

  final OrganizationMembershipRequest _self;
  final $Res Function(OrganizationMembershipRequest) _then;

/// Create a copy of OrganizationMembershipRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? organizationId = null,Object? userId = null,Object? role = null,}) {
  return _then(_self.copyWith(
organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationMembershipRequest].
extension OrganizationMembershipRequestPatterns on OrganizationMembershipRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationMembershipRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationMembershipRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationMembershipRequest value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationMembershipRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationMembershipRequest value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationMembershipRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String organizationId,  String userId,  UserRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationMembershipRequest() when $default != null:
return $default(_that.organizationId,_that.userId,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String organizationId,  String userId,  UserRole role)  $default,) {final _that = this;
switch (_that) {
case _OrganizationMembershipRequest():
return $default(_that.organizationId,_that.userId,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String organizationId,  String userId,  UserRole role)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationMembershipRequest() when $default != null:
return $default(_that.organizationId,_that.userId,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationMembershipRequest implements OrganizationMembershipRequest {
  const _OrganizationMembershipRequest({required this.organizationId, required this.userId, required this.role});
  factory _OrganizationMembershipRequest.fromJson(Map<String, dynamic> json) => _$OrganizationMembershipRequestFromJson(json);

@override final  String organizationId;
@override final  String userId;
@override final  UserRole role;

/// Create a copy of OrganizationMembershipRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationMembershipRequestCopyWith<_OrganizationMembershipRequest> get copyWith => __$OrganizationMembershipRequestCopyWithImpl<_OrganizationMembershipRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationMembershipRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationMembershipRequest&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,organizationId,userId,role);

@override
String toString() {
  return 'OrganizationMembershipRequest(organizationId: $organizationId, userId: $userId, role: $role)';
}


}

/// @nodoc
abstract mixin class _$OrganizationMembershipRequestCopyWith<$Res> implements $OrganizationMembershipRequestCopyWith<$Res> {
  factory _$OrganizationMembershipRequestCopyWith(_OrganizationMembershipRequest value, $Res Function(_OrganizationMembershipRequest) _then) = __$OrganizationMembershipRequestCopyWithImpl;
@override @useResult
$Res call({
 String organizationId, String userId, UserRole role
});




}
/// @nodoc
class __$OrganizationMembershipRequestCopyWithImpl<$Res>
    implements _$OrganizationMembershipRequestCopyWith<$Res> {
  __$OrganizationMembershipRequestCopyWithImpl(this._self, this._then);

  final _OrganizationMembershipRequest _self;
  final $Res Function(_OrganizationMembershipRequest) _then;

/// Create a copy of OrganizationMembershipRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? organizationId = null,Object? userId = null,Object? role = null,}) {
  return _then(_OrganizationMembershipRequest(
organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}


}

// dart format on
