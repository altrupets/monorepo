import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/features/auth/presentation/providers/auth_provider.dart';
import 'package:altrupets/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:altrupets/features/auth/domain/entities/user.dart';
import 'package:altrupets/features/auth/data/models/auth_payload.dart';
import 'package:altrupets/features/auth/data/models/register_input.dart';
import 'package:altrupets/core/error/failures.dart';

class FakeAuthRepository implements AuthRepositoryInterface {
  User? mockUser;
  AuthPayload? mockPayload;
  Failure? mockFailure;
  bool shouldFailRegister = false;
  bool shouldFailLogin = false;
  bool shouldFailGetCurrentUser = false;
  bool shouldFailLogout = false;

  @override
  Future<Either<Failure, User>> register(RegisterInput input) async {
    if (shouldFailRegister || mockFailure != null) {
      return Left(mockFailure ?? ServerFailure('Registration failed'));
    }
    return Right(mockUser ?? User(id: '1', username: 'testuser'));
  }

  @override
  Future<Either<Failure, AuthPayload>> login(
    String username,
    String password,
  ) async {
    if (shouldFailLogin || mockFailure != null) {
      return Left(mockFailure ?? ServerFailure('Invalid credentials'));
    }
    return Right(mockPayload ?? const AuthPayload(accessToken: 'token123'));
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (shouldFailGetCurrentUser || mockFailure != null) {
      return Left(mockFailure ?? ServerFailure('Unauthorized'));
    }
    return Right(mockUser ?? User(id: '1', username: 'testuser'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (shouldFailLogout || mockFailure != null) {
      return Left(mockFailure ?? ServerFailure('Logout failed'));
    }
    return const Right(null);
  }
}

void main() {
  late FakeAuthRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeAuthRepository();
  });

  group('AuthState', () {
    test('should have correct default values', () {
      const state = AuthState();

      expect(state.isLoading, isFalse);
      expect(state.payload, isNull);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('should copy with new values', () {
      const state = AuthState();
      final newState = state.copyWith(isLoading: true, error: 'Test error');

      expect(newState.isLoading, isTrue);
      expect(newState.error, 'Test error');
      expect(newState.user, isNull);
    });

    test('should copy with user', () {
      const state = AuthState();
      final testUser = User(
        id: '1',
        username: 'testuser',
        firstName: 'Test',
        lastName: 'User',
      );
      final newState = state.copyWith(user: testUser);

      expect(newState.user, isNotNull);
      expect(newState.user?.username, 'testuser');
    });

    test('should copy with payload', () {
      const state = AuthState();
      const payload = AuthPayload(accessToken: 'token123');
      final newState = state.copyWith(payload: payload);

      expect(newState.payload, isNotNull);
      expect(newState.payload?.accessToken, 'token123');
    });
  });

  group('AuthNotifier', () {
    test('register - should set loading state then success', () async {
      final testUser = User(
        id: '1',
        username: 'testuser',
        firstName: 'Test',
        lastName: 'User',
      );
      fakeRepository.mockUser = testUser;

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.register(
        RegisterInput(
          username: 'testuser',
          password: 'password123',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
        ),
      );

      final state = container.read(authProvider);

      expect(state.isLoading, isFalse);
      expect(state.user, isNotNull);
      expect(state.user?.username, 'testuser');
      expect(state.error, isNull);

      container.dispose();
    });

    test('register - should set error on failure', () async {
      fakeRepository.shouldFailRegister = true;

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.register(
        RegisterInput(
          username: 'testuser',
          password: 'password123',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
        ),
      );

      final state = container.read(authProvider);

      expect(state.isLoading, isFalse);
      expect(state.user, isNull);
      expect(state.error, 'Registration failed');

      container.dispose();
    });

    test(
      'login - should set loading state then success with payload',
      () async {
        const testPayload = AuthPayload(accessToken: 'token123');
        fakeRepository.mockPayload = testPayload;

        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
        );

        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.login('testuser', 'password123');

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.payload, isNotNull);
        expect(state.payload?.accessToken, 'token123');
        expect(state.error, isNull);

        container.dispose();
      },
    );

    test('login - should set error on failure', () async {
      fakeRepository.shouldFailLogin = true;

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.login('testuser', 'wrongpassword');

      final state = container.read(authProvider);

      expect(state.isLoading, isFalse);
      expect(state.payload, isNull);
      expect(state.error, 'Invalid credentials');

      container.dispose();
    });

    test('loadCurrentUser - should load user successfully', () async {
      final testUser = User(
        id: '1',
        username: 'testuser',
        firstName: 'Test',
        lastName: 'User',
      );
      fakeRepository.mockUser = testUser;

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.loadCurrentUser();

      final state = container.read(authProvider);

      expect(state.isLoading, isFalse);
      expect(state.user, isNotNull);
      expect(state.user?.username, 'testuser');

      container.dispose();
    });

    test('loadCurrentUser - should set error on failure', () async {
      fakeRepository.shouldFailGetCurrentUser = true;

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.loadCurrentUser();

      final state = container.read(authProvider);

      expect(state.isLoading, isFalse);
      expect(state.error, 'Unauthorized');

      container.dispose();
    });

    test('logout - should reset state', () async {
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.logout();

      final state = container.read(authProvider);

      expect(state.isLoading, isFalse);
      expect(state.user, isNull);
      expect(state.payload, isNull);
      expect(state.error, isNull);

      container.dispose();
    });
  });
}
