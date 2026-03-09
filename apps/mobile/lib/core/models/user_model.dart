import 'package:altrupets/features/auth/domain/entities/user.dart';
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
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String username,
    required List<UserRole> roles,
    required bool isActive,
    required bool isVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? email,
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
    String? avatarBase64,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      roles: (user.roles ?? [])
          .map((r) => UserRole.fromString(r.toString()))
          .toList(),
      isActive: user.isActive ?? true,
      isVerified: user.isVerified ?? false,
      createdAt: user.createdAt ?? DateTime.now(),
      updatedAt: user.updatedAt ?? DateTime.now(),
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      identification: user.identification,
      country: user.country,
      province: user.province,
      canton: user.canton,
      district: user.district,
      avatarBase64: user.avatarBase64,
    );
  }
}

/// User login request - maps to backend LoginInput
@freezed
abstract class UserLoginRequest with _$UserLoginRequest {
  const factory UserLoginRequest({
    required String username,
    required String password,
  }) = _UserLoginRequest;

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$UserLoginRequestFromJson(json);
}

/// User login response - maps to backend AuthPayload
@freezed
abstract class UserLoginResponse with _$UserLoginResponse {
  const factory UserLoginResponse({required String accessToken}) =
      _UserLoginResponse;

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$UserLoginResponseFromJson(json);
}
