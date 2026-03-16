import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:altrupets/core/graphql/graphql_client.dart';
import 'package:altrupets/core/services/auth_service.dart';
import 'package:altrupets/core/storage/secure_storage_service.dart';
import 'package:altrupets/features/auth/data/repositories/auth_repository.dart';
import 'package:altrupets/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:altrupets/core/models/user_model.dart';
import 'package:altrupets/features/auth/data/models/auth_payload.dart';
import 'package:altrupets/features/auth/data/models/register_input.dart';

part 'auth_provider.freezed.dart';

final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  return AuthRepository();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final graphQLClient = GraphQLClientService.getClient();
  return AuthService(
    secureStorage: secureStorage,
    graphQLClient: graphQLClient,
  );
});

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isLocked,
    @Default(false) bool isForbidden,
    DateTime? lockoutUntil,
    AuthPayload? payload,
    UserModel? user,
    String? error,
  }) = _AuthState;
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService = ref.read(authServiceProvider);
  late final AuthRepositoryInterface _repository = ref.read(
    authRepositoryProvider,
  );

  @override
  AuthState build() {
    // Listen to AuthService state changes
    final authSub = _authService.stateStream.listen(_onServiceStateChanged);

    // Listen for session expiry events (401/403 from server)
    final sessionSub = GraphQLClientService.sessionExpiredStream.listen((_) {
      // If we were authenticated, mark as forbidden / session expired
      if (state.user != null) {
        state = state.copyWith(
          isForbidden: true,
          error:
              'Tu sesión ha expirado o no tienes acceso. Inicia sesión de nuevo.',
        );
      }
    });

    ref.onDispose(() {
      authSub.cancel();
      sessionSub.cancel();
    });

    // Initialize state from service
    _onServiceStateChanged(_authService.state);

    return const AuthState();
  }

  /// Clear the forbidden/access-denied flag (e.g. after the user acknowledges the error)
  void clearForbidden() {
    state = state.copyWith(isForbidden: false, error: null);
  }

  void _onServiceStateChanged(AuthServiceState serviceState) {
    switch (serviceState) {
      case AuthServiceUnauthenticated():
        state = const AuthState();
      case AuthServiceLoading():
        state = state.copyWith(isLoading: true, error: null);
      case AuthServiceAuthenticated(
        :final user,
        :final accessToken,
        :final refreshToken,
      ):
        state = state.copyWith(
          isLoading: false,
          user: user,
          payload: AuthPayload(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: 3600, // Dummy value, should be from backend
          ),
          error: null,
        );
      case AuthServiceAccountLocked(:final lockoutUntil):
        state = state.copyWith(
          isLoading: false,
          isLocked: true,
          lockoutUntil: lockoutUntil,
          error: 'Account locked until $lockoutUntil',
        );
      case AuthServiceError(:final exception):
        state = state.copyWith(isLoading: false, error: exception.message);
    }
  }

  Future<void> register(RegisterInput input) async {
    state = state.copyWith(isLoading: true, error: null, user: null);
    final result = await _repository.register(input);
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          user: null,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: UserModel.fromEntity(user),
          error: null,
        );
      },
    );
  }

  Future<void> login(String username, String password) async {
    try {
      await _authService.login(username: username, password: password);
    } catch (e) {
      // Error is handled by stream listener
    }
  }

  Future<void> loadCurrentUser() async {
    // This method might become redundant if AuthService handles current user loading internally
    // For now, keep it as a direct repository call if needed for specific scenarios
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getCurrentUser();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: UserModel.fromEntity(user),
          error: null,
        );
      },
    );
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authService = ref.read(authServiceProvider);
  return authService.state is AuthServiceAuthenticated;
});

final sessionExpiredProvider = StreamProvider<void>((ref) {
  return GraphQLClientService.sessionExpiredStream;
});
