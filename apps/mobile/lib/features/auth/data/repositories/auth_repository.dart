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

class AuthRepository implements AuthRepositoryInterface {
  GraphQLClient get _client => GraphQLClientService.getClient();

  static const String _loginMutation = '''
    mutation Login(\$loginInput: LoginInput!) {
      login(loginInput: \$loginInput) {
        access_token
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
        return Left(
          ServerFailure(result.exception!.graphqlErrors.first.message),
        );
      }

      final data = result.data?['login'] as Map<String, dynamic>?;
      if (data == null) {
        return Left(ServerFailure('Invalid response from server'));
      }

      final payload = AuthPayload.fromJson(data);

      // Guardar token
      await GraphQLClientService.saveToken(payload.accessToken);

      return Right(payload);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final result = await _client.query(
        QueryOptions(document: gql(_currentUserQuery)),
      );

      if (result.hasException) {
        return Left(
          ServerFailure(result.exception!.graphqlErrors.first.message),
        );
      }

      final data = result.data?['currentUser'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('User not found'));
      }

      final user = User.fromJson(data);
      return Right(user);
    } catch (e) {
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
