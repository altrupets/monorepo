import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_input.freezed.dart';
part 'register_input.g.dart';

@freezed
class RegisterInput with _$RegisterInput {
  const factory RegisterInput({
    required String username,
    required String password,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? identification,
    String? country,
    String? province,
    String? canton,
    String? district,
    String? occupation,
    String? incomeSource,
    List<String>? roles,
  }) = _RegisterInput;

  factory RegisterInput.fromJson(Map<String, dynamic> json) =>
      _$RegisterInputFromJson(json);
}
