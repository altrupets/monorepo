import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_payload.freezed.dart';
part 'auth_payload.g.dart';

@freezed
class AuthPayload with _$AuthPayload {
  const factory AuthPayload({
    @JsonKey(name: 'access_token') required String accessToken,
  }) = _AuthPayload;

  factory AuthPayload.fromJson(Map<String, dynamic> json) =>
      _$AuthPayloadFromJson(json);
}
