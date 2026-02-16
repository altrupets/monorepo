import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:altrupets/core/graphql/graphql_client.dart';
import 'package:altrupets/features/auth/domain/entities/user.dart';
import 'package:altrupets/core/error/failures.dart';
import 'package:altrupets/core/storage/profile_cache_store.dart';
import 'package:altrupets/core/storage/app_prefs_store.dart';
import 'package:altrupets/core/sync/profile_update_queue_store.dart';
import 'package:dartz/dartz.dart';

const _currentUserQuery = '''
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
      avatarBase64
      createdAt
      updatedAt
    }
  }
''';

const _updateUserMutation = '''
  mutation UpdateUserProfile(\$input: UpdateUserInput!) {
    updateUserProfile(input: \$input) {
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
      avatarBase64
      createdAt
      updatedAt
    }
  }
''';

final currentUserProvider = FutureProvider.autoDispose<User?>((ref) async {
  final client = GraphQLClientService.getClient();
  final isConnected = await InternetConnectionChecker().hasConnection;

  try {
    if (isConnected) {
      await _flushQueuedProfileUpdates(client);
    }

    final result = await client.query(
      QueryOptions(document: gql(_currentUserQuery)),
    );

    if (result.hasException) {
      if (_isUnauthorized(result.exception!)) {
        return null;
      }
      return await ProfileCacheStore.getCurrentUser();
    }

    final data = result.data?['currentUser'] as Map<String, dynamic>?;
    if (data == null) {
      return await ProfileCacheStore.getCurrentUser();
    }

    final user = User.fromJson(data);
    await ProfileCacheStore.saveCurrentUser(user);
    await AppPrefsStore.setLastCurrentUserSyncNow();
    return user;
  } catch (_) {
    return await ProfileCacheStore.getCurrentUser();
  }
});

final updateUserProfileProvider =
    FutureProvider.family<Either<Failure, User>, UpdateUserParams>((
      ref,
      params,
    ) async {
      final client = GraphQLClientService.getClient();
      final input = params.toGraphQLInput();
      final isConnected = await InternetConnectionChecker().hasConnection;

      try {
        if (!isConnected) {
          await ProfileUpdateQueueStore.enqueue(input);
          final pending = await ProfileUpdateQueueStore.all();
          await AppPrefsStore.setPendingProfileUpdatesCount(pending.length);
          final cached = await ProfileCacheStore.getCurrentUser();
          if (cached != null) {
            final optimistic = _mergeUserWithInput(cached, input);
            await ProfileCacheStore.saveCurrentUser(optimistic);
            ref.invalidate(currentUserProvider);
            return Right(optimistic);
          }
          return const Left(
            NetworkFailure('Sin conexión. Cambios guardados para sincronizar.'),
          );
        }

        await _flushQueuedProfileUpdates(client);
        final result = await _executeUpdateMutation(client, input);
        if (result.hasException) {
          final exception = result.exception!;
          final graphQLErrorMessage = exception.graphqlErrors.isNotEmpty
              ? exception.graphqlErrors.first.message
              : null;
          final linkErrorMessage = exception.linkException?.toString();
          return Left(
            ServerFailure(
              graphQLErrorMessage ??
                  linkErrorMessage ??
                  'No se pudo actualizar el perfil',
            ),
          );
        }

        final data = result.data?['updateUserProfile'] as Map<String, dynamic>?;
        if (data == null) {
          return const Left(ServerFailure('Invalid response from server'));
        }

        final user = User.fromJson(data);
        await ProfileCacheStore.saveCurrentUser(user);
        await AppPrefsStore.setLastCurrentUserSyncNow();
        ref.invalidate(currentUserProvider);
        return Right(user);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });

Future<QueryResult<Object?>> _executeUpdateMutation(
  GraphQLClient client,
  Map<String, dynamic> input,
) {
  return client.mutate(
    MutationOptions(
      document: gql(_updateUserMutation),
      variables: {'input': input},
    ),
  );
}

Future<void> _flushQueuedProfileUpdates(GraphQLClient client) async {
  final queued = await ProfileUpdateQueueStore.all();
  if (queued.isEmpty) {
    await AppPrefsStore.setPendingProfileUpdatesCount(0);
    return;
  }

  for (final item in queued) {
    final result = await _executeUpdateMutation(client, item.payload);
    if (result.hasException) {
      break;
    }
    await ProfileUpdateQueueStore.deleteById(item.id);
  }

  final pendingAfterFlush = await ProfileUpdateQueueStore.all();
  await AppPrefsStore.setPendingProfileUpdatesCount(pendingAfterFlush.length);
}

bool _isUnauthorized(OperationException exception) {
  final graphQLUnauthorized = exception.graphqlErrors.any((error) {
    final message = error.message.toLowerCase();
    return message.contains('unauthorized') ||
        message.contains('unauthenticated');
  });
  if (graphQLUnauthorized) {
    return true;
  }
  final link = exception.linkException;
  if (link is ServerException) {
    return link.statusCode == 401 || link.statusCode == 403;
  }
  return false;
}

User _mergeUserWithInput(User base, Map<String, dynamic> input) {
  return base.copyWith(
    firstName: input['firstName'] as String? ?? base.firstName,
    lastName: input['lastName'] as String? ?? base.lastName,
    phone: input['phone'] as String? ?? base.phone,
    identification: input['identification'] as String? ?? base.identification,
    country: input['country'] as String? ?? base.country,
    province: input['province'] as String? ?? base.province,
    canton: input['canton'] as String? ?? base.canton,
    district: input['district'] as String? ?? base.district,
    avatarBase64: input['avatarBase64'] as String? ?? base.avatarBase64,
    updatedAt: DateTime.now(),
  );
}

class UpdateUserParams {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? identification;
  final String? country;
  final String? province;
  final String? canton;
  final String? district;
  final String? avatarBase64;

  UpdateUserParams({
    this.firstName,
    this.lastName,
    this.phone,
    this.identification,
    this.country,
    this.province,
    this.canton,
    this.district,
    this.avatarBase64,
  });

  Map<String, dynamic> toGraphQLInput() {
    return {
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (identification != null) 'identification': identification,
      if (country != null) 'country': country,
      if (province != null) 'province': province,
      if (canton != null) 'canton': canton,
      if (district != null) 'district': district,
      if (avatarBase64 != null) 'avatarBase64': avatarBase64,
    };
  }
}
