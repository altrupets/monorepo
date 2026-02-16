import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:altrupets/core/graphql/graphql_client.dart';
import 'package:altrupets/features/auth/data/repositories/auth_repository.dart';
import 'package:altrupets/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:altrupets/features/auth/domain/entities/user.dart';
import 'package:altrupets/features/auth/data/models/auth_payload.dart';

part 'auth_provider.freezed.dart';

final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  return AuthRepository();
});

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    AuthPayload? payload,
    User? user,
    String? error,
  }) = _AuthState;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final AuthRepositoryInterface _repository;

  Future<void> login(String username, String password) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      payload: null,
      user: null,
    );

    final result = await _repository.login(username, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          payload: null,
        );
      },
      (payload) {
        state = state.copyWith(
          isLoading: false,
          payload: payload,
          error: null,
        );
      },
    );
  }

  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getCurrentUser();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          error: null,
        );
      },
    );
  }

  Future<void> logout() async {
    final result = await _repository.logout();
    result.fold(
      (_) {},
      (_) {},
    );
    // Siempre limpiamos el estado local de auth al cerrar sesión.
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final hasActiveSession = await GraphQLClientService.hasActiveSession();
  if (!hasActiveSession) {
    return false;
  }

  final repository = ref.read(authRepositoryProvider);
  final currentUserResult = await repository.getCurrentUser();

  final isValid = currentUserResult.fold(
    (_) => false,
    (_) => true,
  );

  if (!isValid) {
    await GraphQLClientService.clearToken();
  }

  return isValid;
});

final sessionExpiredProvider = StreamProvider<void>((ref) {
  return GraphQLClientService.sessionExpiredStream;
});
