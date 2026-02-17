import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:altrupets/core/models/user_model.dart';
import 'package:altrupets/core/storage/secure_storage_service.dart';

/// Exception thrown by AuthService operations
class AuthServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AuthServiceException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AuthServiceException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Sealed class representing authentication state
sealed class AuthServiceState {
  const AuthServiceState();
}

/// User is not authenticated
class AuthServiceUnauthenticated extends AuthServiceState {
  const AuthServiceUnauthenticated();
}

/// Authentication operation in progress
class AuthServiceLoading extends AuthServiceState {
  const AuthServiceLoading();
}

/// User is authenticated with valid token
class AuthServiceAuthenticated extends AuthServiceState {
  final UserModel user;
  final String accessToken;

  const AuthServiceAuthenticated({
    required this.user,
    required this.accessToken,
  });
}

/// Authentication error occurred
class AuthServiceError extends AuthServiceState {
  final AuthServiceException exception;

  const AuthServiceError(this.exception);
}

/// Account is locked due to too many failed attempts (client-side only)
class AuthServiceAccountLocked extends AuthServiceState {
  final DateTime lockoutUntil;

  const AuthServiceAccountLocked(this.lockoutUntil);

  Duration get lockoutRemaining {
    final now = DateTime.now();
    if (now.isAfter(lockoutUntil)) {
      return Duration.zero;
    }
    return lockoutUntil.difference(now);
  }
}

/// Service for managing authentication state and operations
///
/// This is a CLIENT-SIDE service that:
/// - Calls backend GraphQL mutations/queries for auth operations
/// - Stores tokens securely in device Keychain/Keystore
/// - Manages authentication state for the UI
/// - Handles account lockout after failed attempts (client-side only)
///
/// The backend handles:
/// - Credential validation
/// - JWT token generation
/// - User management
class AuthService {
  final SecureStorageService _secureStorage;
  final GraphQLClient _graphQLClient;

  // Storage keys
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyUserData = 'auth_user_data';
  static const String _keyFailedAttempts = 'auth_failed_attempts';
  static const String _keyLockoutUntil = 'auth_lockout_until';

  // Configuration (client-side lockout only)
  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);

  // State management
  final StreamController<AuthServiceState> _stateController =
      StreamController<AuthServiceState>.broadcast();
  AuthServiceState _currentState = const AuthServiceUnauthenticated();

  AuthService({
    required SecureStorageService secureStorage,
    required GraphQLClient graphQLClient,
  })  : _secureStorage = secureStorage,
        _graphQLClient = graphQLClient {
    _initializeState();
  }

  /// Current authentication state
  AuthServiceState get state => _currentState;

  /// Stream of authentication state changes
  Stream<AuthServiceState> get stateStream => _stateController.stream;

  /// Initialize authentication state from stored data
  Future<void> _initializeState() async {
    try {
      developer.log('Initializing auth state', name: 'AuthService');

      // Check if account is locked (client-side)
      final lockoutUntilStr = await _secureStorage.read(key: _keyLockoutUntil);
      if (lockoutUntilStr != null) {
        final lockoutUntil = DateTime.parse(lockoutUntilStr);
        if (DateTime.now().isBefore(lockoutUntil)) {
          _updateState(AuthServiceAccountLocked(lockoutUntil));
          return;
        } else {
          await _clearLockout();
        }
      }

      // Try to restore session
      final accessToken = await _secureStorage.read(key: _keyAccessToken);
      final userDataJson = await _secureStorage.read(key: _keyUserData);

      if (accessToken != null && userDataJson != null) {
        final userData = UserModel.fromJson(
          jsonDecode(userDataJson) as Map<String, dynamic>,
        );

        // Verify token is still valid by calling backend
        final isValid = await _verifyToken(accessToken);
        if (isValid) {
          _updateState(
            AuthServiceAuthenticated(
              user: userData,
              accessToken: accessToken,
            ),
          );
          developer.log('Session restored successfully', name: 'AuthService');
        } else {
          await _clearAuthData();
          _updateState(const AuthServiceUnauthenticated());
          developer.log('Stored token is invalid', name: 'AuthService');
        }
      } else {
        _updateState(const AuthServiceUnauthenticated());
        developer.log('No stored session found', name: 'AuthService');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to initialize auth state',
        name: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );
      _updateState(const AuthServiceUnauthenticated());
    }
  }

  /// Verify token with backend
  Future<bool> _verifyToken(String token) async {
    try {
      const query = r'''
        query Profile {
          profile {
            id
            username
          }
        }
      ''';

      final result = await _graphQLClient.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      return !result.hasException && result.data != null;
    } catch (e) {
      return false;
    }
  }

  /// Login with username and password
  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      developer.log('Login attempt for: $username', name: 'AuthService');

      // Check if account is locked (client-side)
      if (_currentState is AuthServiceAccountLocked) {
        final lockedState = _currentState as AuthServiceAccountLocked;
        if (lockedState.lockoutRemaining > Duration.zero) {
          throw AuthServiceException(
            'Account is locked. Try again in ${lockedState.lockoutRemaining.inMinutes} minutes.',
            code: 'ACCOUNT_LOCKED',
          );
        } else {
          await _clearLockout();
        }
      }

      _updateState(const AuthServiceLoading());

      // Call backend login mutation
      const mutation = r'''
        mutation Login($loginInput: LoginInput!) {
          login(loginInput: $loginInput) {
            access_token
          }
        }
      ''';

      final result = await _graphQLClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'loginInput': {
              'username': username,
              'password': password,
            },
          },
        ),
      );

      if (result.hasException) {
        await _handleFailedLogin();
        throw AuthServiceException(
          result.exception?.graphqlErrors.first.message ?? 'Login failed',
          code: 'LOGIN_FAILED',
          originalError: result.exception,
        );
      }

      final accessToken = result.data!['login']['access_token'] as String;

      // Fetch user profile
      final user = await _fetchUserProfile();

      // Store tokens and user data
      await _storeAuthData(
        accessToken: accessToken,
        user: user,
      );

      // Clear failed attempts on successful login
      await _clearFailedAttempts();

      _updateState(
        AuthServiceAuthenticated(
          user: user,
          accessToken: accessToken,
        ),
      );

      developer.log('Login successful', name: 'AuthService');
    } catch (e) {
      developer.log(
        'Login failed',
        name: 'AuthService',
        error: e,
      );

      if (e is AuthServiceException) {
        _updateState(AuthServiceError(e));
        rethrow;
      } else {
        final exception = AuthServiceException(
          'An unexpected error occurred',
          code: 'UNEXPECTED_ERROR',
          originalError: e,
        );
        _updateState(AuthServiceError(exception));
        throw exception;
      }
    }
  }

  /// Fetch user profile from backend
  Future<UserModel> _fetchUserProfile() async {
    const query = r'''
      query Profile {
        profile {
          id
          username
          email
          roles
          firstName
          lastName
          phone
          identification
          country
          province
          canton
          district
          bio
          organizationId
          latitude
          longitude
          isActive
          isVerified
          avatarBase64
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _graphQLClient.query(
      QueryOptions(
        document: gql(query),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw AuthServiceException(
        'Failed to fetch user profile',
        code: 'PROFILE_FETCH_FAILED',
        originalError: result.exception,
      );
    }

    final profileData = result.data!['profile'] as Map<String, dynamic>;
    return UserModel.fromJson(profileData);
  }

  /// Logout and clear all stored authentication data
  Future<void> logout() async {
    try {
      developer.log('Logging out', name: 'AuthService');

      // Clear all stored data
      await _clearAuthData();

      _updateState(const AuthServiceUnauthenticated());

      developer.log('Logout successful', name: 'AuthService');
    } catch (e, stackTrace) {
      developer.log(
        'Logout failed',
        name: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );
      // Even if logout fails, clear local state
      await _clearAuthData();
      _updateState(const AuthServiceUnauthenticated());
    }
  }

  /// Store authentication data securely
  Future<void> _storeAuthData({
    required String accessToken,
    required UserModel user,
  }) async {
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);
    await _secureStorage.write(key: _keyUserData, value: jsonEncode(user.toJson()));
  }

  /// Clear all authentication data
  Future<void> _clearAuthData() async {
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyUserData);
  }

  /// Handle failed login attempt (client-side lockout)
  Future<void> _handleFailedLogin() async {
    final attemptsStr = await _secureStorage.read(key: _keyFailedAttempts);
    final attempts = int.tryParse(attemptsStr ?? '0') ?? 0;
    final newAttempts = attempts + 1;

    await _secureStorage.write(key: _keyFailedAttempts, value: newAttempts.toString());

    if (newAttempts >= _maxFailedAttempts) {
      final lockoutUntil = DateTime.now().add(_lockoutDuration);
      await _secureStorage.write(key: _keyLockoutUntil, value: lockoutUntil.toIso8601String());
      _updateState(AuthServiceAccountLocked(lockoutUntil));

      developer.log(
        'Account locked until $lockoutUntil',
        name: 'AuthService',
      );
    }
  }

  /// Clear failed login attempts
  Future<void> _clearFailedAttempts() async {
    await _secureStorage.delete(key: _keyFailedAttempts);
  }

  /// Clear account lockout
  Future<void> _clearLockout() async {
    await _secureStorage.delete(key: _keyLockoutUntil);
    await _clearFailedAttempts();
  }

  /// Update authentication state and notify listeners
  void _updateState(AuthServiceState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  /// Dispose resources
  void dispose() {
    _stateController.close();
  }
}
