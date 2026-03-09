// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_organizations_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchOrganizationsInput {

 String? get name; OrganizationType? get type; OrganizationStatus? get status; String? get country; String? get province; String? get canton;
/// Create a copy of SearchOrganizationsInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchOrganizationsInputCopyWith<SearchOrganizationsInput> get copyWith => _$SearchOrganizationsInputCopyWithImpl<SearchOrganizationsInput>(this as SearchOrganizationsInput, _$identity);

  /// Serializes this SearchOrganizationsInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchOrganizationsInput&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,status,country,province,canton);

@override
String toString() {
  return 'SearchOrganizationsInput(name: $name, type: $type, status: $status, country: $country, province: $province, canton: $canton)';
}


}

/// @nodoc
abstract mixin class $SearchOrganizationsInputCopyWith<$Res>  {
  factory $SearchOrganizationsInputCopyWith(SearchOrganizationsInput value, $Res Function(SearchOrganizationsInput) _then) = _$SearchOrganizationsInputCopyWithImpl;
@useResult
$Res call({
 String? name, OrganizationType? type, OrganizationStatus? status, String? country, String? province, String? canton
});




}
/// @nodoc
class _$SearchOrganizationsInputCopyWithImpl<$Res>
    implements $SearchOrganizationsInputCopyWith<$Res> {
  _$SearchOrganizationsInputCopyWithImpl(this._self, this._then);

  final SearchOrganizationsInput _self;
  final $Res Function(SearchOrganizationsInput) _then;

/// Create a copy of SearchOrganizationsInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? type = freezed,Object? status = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrganizationType?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrganizationStatus?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,canton: freezed == canton ? _self.canton : canton // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchOrganizationsInput].
extension SearchOrganizationsInputPatterns on SearchOrganizationsInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchOrganizationsInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchOrganizationsInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchOrganizationsInput value)  $default,){
final _that = this;
switch (_that) {
case _SearchOrganizationsInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchOrganizationsInput value)?  $default,){
final _that = this;
switch (_that) {
case _SearchOrganizationsInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  OrganizationType? type,  OrganizationStatus? status,  String? country,  String? province,  String? canton)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchOrganizationsInput() when $default != null:
return $default(_that.name,_that.type,_that.status,_that.country,_that.province,_that.canton);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  OrganizationType? type,  OrganizationStatus? status,  String? country,  String? province,  String? canton)  $default,) {final _that = this;
switch (_that) {
case _SearchOrganizationsInput():
return $default(_that.name,_that.type,_that.status,_that.country,_that.province,_that.canton);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  OrganizationType? type,  OrganizationStatus? status,  String? country,  String? province,  String? canton)?  $default,) {final _that = this;
switch (_that) {
case _SearchOrganizationsInput() when $default != null:
return $default(_that.name,_that.type,_that.status,_that.country,_that.province,_that.canton);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchOrganizationsInput implements SearchOrganizationsInput {
  const _SearchOrganizationsInput({this.name, this.type, this.status, this.country, this.province, this.canton});
  factory _SearchOrganizationsInput.fromJson(Map<String, dynamic> json) => _$SearchOrganizationsInputFromJson(json);

@override final  String? name;
@override final  OrganizationType? type;
@override final  OrganizationStatus? status;
@override final  String? country;
@override final  String? province;
@override final  String? canton;

/// Create a copy of SearchOrganizationsInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchOrganizationsInputCopyWith<_SearchOrganizationsInput> get copyWith => __$SearchOrganizationsInputCopyWithImpl<_SearchOrganizationsInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchOrganizationsInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchOrganizationsInput&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.country, country) || other.country == country)&&(identical(other.province, province) || other.province == province)&&(identical(other.canton, canton) || other.canton == canton));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,status,country,province,canton);

@override
String toString() {
  return 'SearchOrganizationsInput(name: $name, type: $type, status: $status, country: $country, province: $province, canton: $canton)';
}


}

/// @nodoc
abstract mixin class _$SearchOrganizationsInputCopyWith<$Res> implements $SearchOrganizationsInputCopyWith<$Res> {
  factory _$SearchOrganizationsInputCopyWith(_SearchOrganizationsInput value, $Res Function(_SearchOrganizationsInput) _then) = __$SearchOrganizationsInputCopyWithImpl;
@override @useResult
$Res call({
 String? name, OrganizationType? type, OrganizationStatus? status, String? country, String? province, String? canton
});




}
/// @nodoc
class __$SearchOrganizationsInputCopyWithImpl<$Res>
    implements _$SearchOrganizationsInputCopyWith<$Res> {
  __$SearchOrganizationsInputCopyWithImpl(this._self, this._then);

  final _SearchOrganizationsInput _self;
  final $Res Function(_SearchOrganizationsInput) _then;

/// Create a copy of SearchOrganizationsInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? type = freezed,Object? status = freezed,Object? country = freezed,Object? province = freezed,Object? canton = freezed,}) {
  return _then(_SearchOrganizationsInput(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrganizationType?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrganizationStatus?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,canton: freezed == canton ? _self.canton : canton // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
