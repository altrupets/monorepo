import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Enum for user roles - synchronized with backend (apps/backend/src/auth/roles/user-role.enum.ts)
enum UserRole {
  // Super Administrator
  @JsonValue('SUPER_USER')
  superUser,

  // Administrative Roles (B2G)
  @JsonValue('GOVERNMENT_ADMIN')
  governmentAdmin,

  // Administrative Roles (AltruPets Staff)
  @JsonValue('USER_ADMIN')
  userAdmin,
  @JsonValue('LEGAL_REPRESENTATIVE')
  legalRepresentative,

  // Operational Roles
  @JsonValue('WATCHER')
  watcher, // Previously: CENTINELA
  @JsonValue('HELPER')
  helper, // Previously: AUXILIAR
  @JsonValue('RESCUER')
  rescuer, // Previously: RESCATISTA
  @JsonValue('ADOPTER')
  adopter, // Previously: ADOPTANTE
  @JsonValue('DONOR')
  donor, // Previously: DONANTE
  @JsonValue('VETERINARIAN')
  veterinarian; // Previously: VETERINARIO

  /// Convert to GraphQL enum string
  String toGraphQLString() {
    switch (this) {
      case UserRole.superUser:
        return 'SUPER_USER';
      case UserRole.governmentAdmin:
        return 'GOVERNMENT_ADMIN';
      case UserRole.userAdmin:
        return 'USER_ADMIN';
      case UserRole.legalRepresentative:
        return 'LEGAL_REPRESENTATIVE';
      case UserRole.watcher:
        return 'WATCHER';
      case UserRole.helper:
        return 'HELPER';
      case UserRole.rescuer:
        return 'RESCUER';
      case UserRole.adopter:
        return 'ADOPTER';
      case UserRole.donor:
        return 'DONOR';
      case UserRole.veterinarian:
        return 'VETERINARIAN';
    }
  }

  /// Create from string value
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.toGraphQLString() == value,
      orElse: () => UserRole.watcher,
    );
  }
}

/// User model - DTO that maps backend User entity (apps/backend/src/users/entities/user.entity.ts)
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String username,
    String? email,
    required List<UserRole> roles,
    String? firstName,
    String? lastName,
    String? phone,
    String? identification,
    String? country,
    String? province,
    String? canton,
    String? district,
    String? bio,
    String? organizationId,
    double? latitude,
    double? longitude,
    required bool isActive,
    required bool isVerified,
    String? avatarBase64,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// User login request - maps to backend LoginInput
@freezed
class UserLoginRequest with _$UserLoginRequest {
  const factory UserLoginRequest({
    required String username,
    required String password,
  }) = _UserLoginRequest;

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$UserLoginRequestFromJson(json);
}

/// User login response - maps to backend AuthPayload
@freezed
class UserLoginResponse with _$UserLoginResponse {
  const factory UserLoginResponse({
    required String accessToken,
  }) = _UserLoginResponse;

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$UserLoginResponseFromJson(json);
}
