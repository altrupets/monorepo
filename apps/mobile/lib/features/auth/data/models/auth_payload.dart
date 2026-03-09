import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_payload.freezed.dart';
part 'auth_payload.g.dart';

@freezed
abstract class AuthPayload with _$AuthPayload {
  const factory AuthPayload({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_in') required int expiresIn,
  }) = _AuthPayload;

  factory AuthPayload.fromJson(Map<String, dynamic> json) =>
      _$AuthPayloadFromJson(json);
}
