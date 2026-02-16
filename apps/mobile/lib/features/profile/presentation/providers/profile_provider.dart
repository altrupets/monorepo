import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import 'package:altrupets/core/graphql/graphql_client.dart';
import 'package:altrupets/features/auth/domain/entities/user.dart';
import 'package:altrupets/core/error/failures.dart';
import 'package:dartz/dartz.dart';

final currentUserProvider = FutureProvider.autoDispose<User?>((ref) async {
  final client = GraphQLClientService.getClient();
  
  const query = '''
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

  try {
    final result = await client.query(
      QueryOptions(
        document: gql(query),
      ),
    );

    if (result.hasException) {
      return null;
    }

    final data = result.data?['currentUser'] as Map<String, dynamic>?;
    if (data == null) {
      return null;
    }

    return User.fromJson(data);
  } catch (e) {
    return null;
  }
});

final updateUserProfileProvider =
    FutureProvider.family<Either<Failure, User>, UpdateUserParams>(
  (ref, params) async {
    final client = GraphQLClientService.getClient();

    const mutation = '''
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
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              if (params.firstName != null) 'firstName': params.firstName,
              if (params.lastName != null) 'lastName': params.lastName,
              if (params.phone != null) 'phone': params.phone,
              if (params.identification != null)
                'identification': params.identification,
              if (params.country != null) 'country': params.country,
              if (params.province != null) 'province': params.province,
              if (params.canton != null) 'canton': params.canton,
              if (params.district != null) 'district': params.district,
            },
          },
        ),
      );

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
      // Invalidar el provider de currentUser para refrescar
      ref.invalidate(currentUserProvider);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  },
);

class UpdateUserParams {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? identification;
  final String? country;
  final String? province;
  final String? canton;
  final String? district;

  UpdateUserParams({
    this.firstName,
    this.lastName,
    this.phone,
    this.identification,
    this.country,
    this.province,
    this.canton,
    this.district,
  });
}
