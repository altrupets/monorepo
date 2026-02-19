import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:altrupets/core/graphql/graphql_client.dart';
import 'package:altrupets/features/auth/domain/entities/user.dart';
import 'package:altrupets/core/error/failures.dart';
import 'package:altrupets/core/storage/profile_cache_store.dart';
import 'package:altrupets/core/storage/app_prefs_store.dart';
import 'package:altrupets/core/sync/profile_update_queue_store.dart';
import 'package:altrupets/core/sync/sync_status_provider.dart';
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

final currentUserProvider = FutureProvider<User?>((ref) async {
  debugPrint('[currentUserProvider] 🔄 INICIANDO...');

  final client = GraphQLClientService.getClient();
  final connectivityResult = await Connectivity().checkConnectivity();
  final isConnected = !connectivityResult.contains(ConnectivityResult.none);

  debugPrint('[currentUserProvider] 📡 Conexión a internet: $isConnected');

  // Actualizar estado de sincronización
  ref.read(syncStatusProvider.notifier).setSyncing(isConnected);

  // Primero intentar leer del cache para tener fallback inmediato
  User? cachedUser;
  try {
    cachedUser = await ProfileCacheStore.getCurrentUser();
    debugPrint(
      '[currentUserProvider] 💾 Cache leída: ${cachedUser != null ? 'Usuario encontrado (${cachedUser.username})' : 'VACÍA'}',
    );
    if (cachedUser != null) {
      debugPrint(
        '[currentUserProvider]   ├─ firstName: ${cachedUser.firstName}',
      );
      debugPrint('[currentUserProvider]   ├─ lastName: ${cachedUser.lastName}');
      debugPrint('[currentUserProvider]   └─ username: ${cachedUser.username}');
    }
  } catch (e) {
    debugPrint('[currentUserProvider] ❌ Error leyendo cache: $e');
  }

  try {
    if (isConnected) {
      debugPrint(
        '[currentUserProvider] 📤 Ejecutando flush de updates en cola...',
      );
      try {
        await _flushQueuedProfileUpdates(client);
        // Marcar como sincronizado exitosamente
        await ref.read(syncStatusProvider.notifier).markSynced();
      } catch (flushError) {
        debugPrint(
          '[currentUserProvider] ⚠️ Error en flush (no crítico): $flushError',
        );
        // Continuar de todos modos - el flush es secundario
      }
    }

    // Actualizar conteo de pendientes
    await ref.read(syncStatusProvider.notifier).refreshPendingCount();

    debugPrint('[currentUserProvider] 🌐 Ejecutando query GraphQL...');

    final result = await client.query(
      QueryOptions(
        document: gql(_currentUserQuery),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    debugPrint(
      '[currentUserProvider] 📥 Query completada. hasException: ${result.hasException}',
    );

    if (result.hasException) {
      debugPrint(
        '[currentUserProvider] ⚠️ GraphQL Exception: ${result.exception}',
      );
      if (_isUnauthorized(result.exception!)) {
        debugPrint('[currentUserProvider] 🚫 Unauthorized - retornando null');
        return null;
      }
      debugPrint('[currentUserProvider] ↩️ Fallback a cache por excepción');
      return cachedUser;
    }

    final data = result.data?['currentUser'] as Map<String, dynamic>?;

    debugPrint(
      '[currentUserProvider] 📊 Datos recibidos de GraphQL: ${data != null ? 'OK' : 'NULL'}',
    );

    if (data != null) {
      debugPrint(
        '[currentUserProvider] 📋 Campos recibidos: ${data.keys.toList()}',
      );
      debugPrint('[currentUserProvider]   ├─ id: ${data['id']}');
      debugPrint('[currentUserProvider]   ├─ username: ${data['username']}');
      debugPrint('[currentUserProvider]   ├─ firstName: ${data['firstName']}');
      debugPrint('[currentUserProvider]   ├─ lastName: ${data['lastName']}');
    }

    if (data == null) {
      debugPrint(
        '[currentUserProvider] ⚠️ currentUser es NULL - usando cache fallback',
      );
      return cachedUser;
    }

    final user = User.fromJson(data);
    debugPrint(
      '[currentUserProvider] ✅ Usuario parseado exitosamente: ${user.username}',
    );

    await ProfileCacheStore.saveCurrentUser(user);
    await AppPrefsStore.setLastCurrentUserSyncNow();

    debugPrint('[currentUserProvider] 💾 Usuario guardado en cache');

    return user;
  } catch (e, stackTrace) {
    debugPrint('[currentUserProvider] ❌ ERROR: $e');
    debugPrint('[currentUserProvider] Stack: $stackTrace');
    debugPrint('[currentUserProvider] ↩️ Fallback a cache por error');
    return cachedUser;
  }
});

final updateUserProfileProvider =
    FutureProvider.family<Either<Failure, User>, UpdateUserParams>((
      ref,
      params,
    ) async {
      final client = GraphQLClientService.getClient();
      final input = params.toGraphQLInput();
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);

      try {
        if (!isConnected) {
          // En desktop (Linux), la cola sqflite puede fallar
          try {
            await ProfileUpdateQueueStore.enqueue(input);
            final pending = await ProfileUpdateQueueStore.all();
            await AppPrefsStore.setPendingProfileUpdatesCount(pending.length);
          } catch (queueError) {
            debugPrint(
              '[updateUserProfileProvider] ⚠️ Cola no disponible: $queueError',
            );
          }
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

        try {
          await _flushQueuedProfileUpdates(client);
        } catch (flushError) {
          debugPrint(
            '[updateUserProfileProvider] ⚠️ Flush no disponible: $flushError',
          );
        }
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
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? identification;
  final String? country;
  final String? province;
  final String? canton;
  final String? district;
  final String? avatarBase64;

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
