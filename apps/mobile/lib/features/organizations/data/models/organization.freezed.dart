// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Organization {

 String get id; String get name; OrganizationType get type; OrganizationStatus get status; int get memberCount; int get maxCapacity; bool get isActive; bool get isVerified; DateTime get createdAt; DateTime get updatedAt; String? get legalId; String? get description; String? get email; String? get phone; String? get website; String? get address; String? get country; String? get province; String? get canton; String? get district; String? get legalRepresentativeId;
/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationCopyWith<Organization> get copyWith => _$OrganizationCopyWithImpl<Organization>(this as Organization, _$identity);

  /// Serializes this Organization to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Organization&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.legalId, legalId) || other.legalId == legalId)&&(identical(other.description, description) || other.description == description)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.address, address) || other.address == address)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton)&&(identical(other.district, district) || other.district == district)&&(identical(other.legalRepresentativeId, legalRepresentativeId) || other.legalRepresentativeId == legalRepresentativeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,status,memberCount,maxCapacity,isActive,isVerified,createdAt,updatedAt,legalId,description,email,phone,website,address,country,province,canton,district,legalRepresentativeId]);

@override
String toString() {
  return 'Organization(id: $id, name: $name, type: $type, status: $status, memberCount: $memberCount, maxCapacity: $maxCapacity, isActive: $isActive, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt, legalId: $legalId, description: $description, email: $email, phone: $phone, website: $website, address: $address, country: $country, province: $province, canton: $canton, district: $district, legalRepresentativeId: $legalRepresentativeId)';
}


}

/// @nodoc
abstract mixin class $OrganizationCopyWith<$Res>  {
  factory $OrganizationCopyWith(Organization value, $Res Function(Organization) _then) = _$OrganizationCopyWithImpl;
@useResult
$Res call({
 String id, String name, OrganizationType type, OrganizationStatus status, int memberCount, int maxCapacity, bool isActive, bool isVerified, DateTime createdAt, DateTime updatedAt, String? legalId, String? description, String? email, String? phone, String? website, String? address, String? country, String? province, String? canton, String? district, String? legalRepresentativeId
});




}
/// @nodoc
class _$OrganizationCopyWithImpl<$Res>
    implements $OrganizationCopyWith<$Res> {
  _$OrganizationCopyWithImpl(this._self, this._then);

  final Organization _self;
  final $Res Function(Organization) _then;

/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? status = null,Object? memberCount = null,Object? maxCapacity = null,Object? isActive = null,Object? isVerified = null,Object? createdAt = null,Object? updatedAt = null,Object? legalId = freezed,Object? description = freezed,Object? email = freezed,Object? phone = freezed,Object? website = freezed,Object? address = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,Object? district = freezed,Object? legalRepresentativeId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrganizationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrganizationStatus,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,legalId: freezed == legalId ? _self.legalId : legalId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,canton: freezed == canton ? _self.canton : canton // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,legalRepresentativeId: freezed == legalRepresentativeId ? _self.legalRepresentativeId : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Organization].
extension OrganizationPatterns on Organization {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Organization value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Organization() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Organization value)  $default,){
final _that = this;
switch (_that) {
case _Organization():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Organization value)?  $default,){
final _that = this;
switch (_that) {
case _Organization() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  OrganizationType type,  OrganizationStatus status,  int memberCount,  int maxCapacity,  bool isActive,  bool isVerified,  DateTime createdAt,  DateTime updatedAt,  String? legalId,  String? description,  String? email,  String? phone,  String? website,  String? address,  String? country,  String? province,  String? canton,  String? district,  String? legalRepresentativeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Organization() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.status,_that.memberCount,_that.maxCapacity,_that.isActive,_that.isVerified,_that.createdAt,_that.updatedAt,_that.legalId,_that.description,_that.email,_that.phone,_that.website,_that.address,_that.country,_that.province,_that.canton,_that.district,_that.legalRepresentativeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  OrganizationType type,  OrganizationStatus status,  int memberCount,  int maxCapacity,  bool isActive,  bool isVerified,  DateTime createdAt,  DateTime updatedAt,  String? legalId,  String? description,  String? email,  String? phone,  String? website,  String? address,  String? country,  String? province,  String? canton,  String? district,  String? legalRepresentativeId)  $default,) {final _that = this;
switch (_that) {
case _Organization():
return $default(_that.id,_that.name,_that.type,_that.status,_that.memberCount,_that.maxCapacity,_that.isActive,_that.isVerified,_that.createdAt,_that.updatedAt,_that.legalId,_that.description,_that.email,_that.phone,_that.website,_that.address,_that.country,_that.province,_that.canton,_that.district,_that.legalRepresentativeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  OrganizationType type,  OrganizationStatus status,  int memberCount,  int maxCapacity,  bool isActive,  bool isVerified,  DateTime createdAt,  DateTime updatedAt,  String? legalId,  String? description,  String? email,  String? phone,  String? website,  String? address,  String? country,  String? province,  String? canton,  String? district,  String? legalRepresentativeId)?  $default,) {final _that = this;
switch (_that) {
case _Organization() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.status,_that.memberCount,_that.maxCapacity,_that.isActive,_that.isVerified,_that.createdAt,_that.updatedAt,_that.legalId,_that.description,_that.email,_that.phone,_that.website,_that.address,_that.country,_that.province,_that.canton,_that.district,_that.legalRepresentativeId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Organization implements Organization {
  const _Organization({required this.id, required this.name, required this.type, required this.status, required this.memberCount, required this.maxCapacity, required this.isActive, required this.isVerified, required this.createdAt, required this.updatedAt, this.legalId, this.description, this.email, this.phone, this.website, this.address, this.country, this.province, this.canton, this.district, this.legalRepresentativeId});
  factory _Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);

@override final  String id;
@override final  String name;
@override final  OrganizationType type;
@override final  OrganizationStatus status;
@override final  int memberCount;
@override final  int maxCapacity;
@override final  bool isActive;
@override final  bool isVerified;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
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
@override final  String? legalRepresentativeId;

/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationCopyWith<_Organization> get copyWith => __$OrganizationCopyWithImpl<_Organization>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Organization&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.legalId, legalId) || other.legalId == legalId)&&(identical(other.description, description) || other.description == description)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.address, address) || other.address == address)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton)&&(identical(other.district, district) || other.district == district)&&(identical(other.legalRepresentativeId, legalRepresentativeId) || other.legalRepresentativeId == legalRepresentativeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,status,memberCount,maxCapacity,isActive,isVerified,createdAt,updatedAt,legalId,description,email,phone,website,address,country,province,canton,district,legalRepresentativeId]);

@override
String toString() {
  return 'Organization(id: $id, name: $name, type: $type, status: $status, memberCount: $memberCount, maxCapacity: $maxCapacity, isActive: $isActive, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt, legalId: $legalId, description: $description, email: $email, phone: $phone, website: $website, address: $address, country: $country, province: $province, canton: $canton, district: $district, legalRepresentativeId: $legalRepresentativeId)';
}


}

/// @nodoc
abstract mixin class _$OrganizationCopyWith<$Res> implements $OrganizationCopyWith<$Res> {
  factory _$OrganizationCopyWith(_Organization value, $Res Function(_Organization) _then) = __$OrganizationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, OrganizationType type, OrganizationStatus status, int memberCount, int maxCapacity, bool isActive, bool isVerified, DateTime createdAt, DateTime updatedAt, String? legalId, String? description, String? email, String? phone, String? website, String? address, String? country, String? province, String? canton, String? district, String? legalRepresentativeId
});




}
/// @nodoc
class __$OrganizationCopyWithImpl<$Res>
    implements _$OrganizationCopyWith<$Res> {
  __$OrganizationCopyWithImpl(this._self, this._then);

  final _Organization _self;
  final $Res Function(_Organization) _then;

/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? status = null,Object? memberCount = null,Object? maxCapacity = null,Object? isActive = null,Object? isVerified = null,Object? createdAt = null,Object? updatedAt = null,Object? legalId = freezed,Object? description = freezed,Object? email = freezed,Object? phone = freezed,Object? website = freezed,Object? address = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,Object? district = freezed,Object? legalRepresentativeId = freezed,}) {
  return _then(_Organization(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrganizationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrganizationStatus,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,legalId: freezed == legalId ? _self.legalId : legalId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,canton: freezed == canton ? _self.canton : canton // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,legalRepresentativeId: freezed == legalRepresentativeId ? _self.legalRepresentativeId : legalRepresentativeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
