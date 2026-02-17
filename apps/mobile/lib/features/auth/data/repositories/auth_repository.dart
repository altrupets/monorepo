import 'package:flutter/foundation.dart';

import 'package:dartz/dartz.dart';
import 'package:graphql/client.dart';
import 'package:altrupets/core/error/failures.dart';
import 'package:altrupets/core/graphql/graphql_client.dart';
import 'package:altrupets/core/storage/profile_cache_store.dart';
import 'package:altrupets/core/storage/app_prefs_store.dart';
import 'package:altrupets/core/sync/profile_update_queue_store.dart';
import 'package:altrupets/features/auth/domain/entities/user.dart';
import 'package:altrupets/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:altrupets/features/auth/data/models/auth_payload.dart';
import 'package:altrupets/features/auth/data/models/register_input.dart';

class AuthRepository implements AuthRepositoryInterface {
  GraphQLClient get _client => GraphQLClientService.getClient();

  static const String _loginMutation = '''
    mutation Login(\$loginInput: LoginInput!) {
      login(loginInput: \$loginInput) {
        access_token
      }
    }
  ''';

  static const String _registerMutation = '''
    mutation Register(\$registerInput: RegisterInput!) {
      register(registerInput: \$registerInput) {
        id
        username
        email
        firstName
        lastName
        phone
        identification
        country
        province
        canton
        district
        occupation
        incomeSource
        roles
        isActive
        isVerified
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _currentUserQuery = '''
    query CurrentUser {
      currentUser {
        id
        username
        roles
        firstName
        lastName
        phone
        identification
        country
        province
        canton
        district
        createdAt
        updatedAt
      }
    }
  ''';

  @override
  Future<Either<Failure, User>> register(RegisterInput input) async {
    try {
      debugPrint('[AuthRepository] 📝 Iniciando registro de usuario: ${input.username}');

      final result = await _client.mutate(
        MutationOptions(
          document: gql(_registerMutation),
          variables: {
            'registerInput': input.toJson(),
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        String errorMessage;

        if (exception.graphqlErrors.isNotEmpty) {
          errorMessage = exception.graphqlErrors.first.message;
          debugPrint('[AuthRepository] ❌ Error GraphQL: $errorMessage');
        } else if (exception.linkException != null) {
          errorMessage = exception.linkException.toString();
          debugPrint('[AuthRepository] ❌ Error de conexión: $errorMessage');
        } else {
          errorMessage = 'Error desconocido en la conexión';
        }

        return Left(ServerFailure(errorMessage));
      }

      final data = result.data?['register'] as Map<String, dynamic>?;
      if (data == null) {
        return Left(ServerFailure('Invalid response from server'));
      }

      final user = User.fromJson(data);
      debugPrint('[AuthRepository] ✅ Usuario registrado exitosamente: ${user.username}');

      return Right(user);
    } catch (e) {
      debugPrint('[AuthRepository] ❌ Error en registro: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthPayload>> login(
    String username,
    String password,
  ) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(_loginMutation),
          variables: {
            'loginInput': {'username': username, 'password': password},
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        String errorMessage;

        if (exception.graphqlErrors.isNotEmpty) {
          errorMessage = exception.graphqlErrors.first.message;
        } else if (exception.linkException != null) {
          errorMessage = exception.linkException.toString();
        } else {
          errorMessage = 'Error desconocido en la conexión';
        }

        return Left(ServerFailure(errorMessage));
      }

      final data = result.data?['login'] as Map<String, dynamic>?;
      if (data == null) {
        return Left(ServerFailure('Invalid response from server'));
      }

      final payload = AuthPayload.fromJson(data);

      debugPrint(
        '[AuthRepository] ✅ Login exitoso - token recibido (len: ${payload.accessToken.length})',
      );

      // Guardar token
      await GraphQLClientService.saveToken(payload.accessToken);

      debugPrint('[AuthRepository] ✅ Token guardado exitosamente');

      return Right(payload);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    debugPrint('[AuthRepository] 🔍 Solicitando currentUser desde GraphQL...');

    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_currentUserQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        debugPrint('[AuthRepository] ❌ Error GraphQL: $exception');

        String errorMessage;
        if (exception.graphqlErrors.isNotEmpty) {
          errorMessage = exception.graphqlErrors.first.message;
        } else if (exception.linkException != null) {
          errorMessage = exception.linkException.toString();
        } else {
          errorMessage = 'Error desconocido en la conexión';
        }

        return Left(ServerFailure(errorMessage));
      }

      final data = result.data?['currentUser'] as Map<String, dynamic>?;
      debugPrint(
        '[AuthRepository] 📊 currentUser data: ${data != null ? 'OK' : 'NULL'}',
      );

      if (data == null) {
        return const Left(ServerFailure('User not found'));
      }

      final user = User.fromJson(data);
      debugPrint(
        '[AuthRepository] ✅ Usuario obtenido: ${user.username} (${user.firstName} ${user.lastName})',
      );

      return Right(user);
    } catch (e) {
      debugPrint('[AuthRepository] ❌ Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await GraphQLClientService.clearToken();
      await ProfileCacheStore.clearCurrentUser();
      await ProfileUpdateQueueStore.clearAll();
      await AppPrefsStore.setPendingProfileUpdatesCount(0);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
