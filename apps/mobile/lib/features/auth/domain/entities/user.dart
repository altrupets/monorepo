import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String username,
    @JsonKey(fromJson: _rolesFromJson) List<String>? roles,
    String? firstName,
    String? lastName,
    String? phone,
    String? identification,
    String? country,
    String? province,
    String? canton,
    String? district,
    String? avatarBase64,
    @JsonKey(fromJson: _dateTimeFromJson) DateTime? createdAt,
    @JsonKey(fromJson: _dateTimeFromJson) DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

List<String>? _rolesFromJson(dynamic json) {
  if (json == null) return null;
  if (json is List) {
    return json.map((e) => e.toString()).toList();
  }
  return null;
}

DateTime? _dateTimeFromJson(dynamic json) {
  if (json == null) return null;
  if (json is String) {
    return DateTime.tryParse(json);
  }
  return null;
}
