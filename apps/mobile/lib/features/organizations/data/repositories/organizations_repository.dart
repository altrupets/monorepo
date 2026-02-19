import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:graphql/client.dart';
import 'package:altrupets/core/error/failures.dart';
import 'package:altrupets/core/graphql/graphql_client.dart';
import 'package:altrupets/features/organizations/data/models/organization.dart';
import 'package:altrupets/features/organizations/data/models/organization_membership.dart';
import 'package:altrupets/features/organizations/data/models/register_organization_input.dart';
import 'package:altrupets/features/organizations/data/models/search_organizations_input.dart';

class OrganizationsRepository {
  GraphQLClient get _client => GraphQLClientService.getClient();

  static const String _registerOrganizationMutation = '''
    mutation RegisterOrganization(\$registerOrganizationInput: RegisterOrganizationInput!) {
      registerOrganization(registerOrganizationInput: \$registerOrganizationInput) {
        id
        name
        type
        legalId
        description
        email
        phone
        website
        address
        country
        province
        canton
        district
        status
        legalRepresentativeId
        memberCount
        maxCapacity
        isActive
        isVerified
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _searchOrganizationsQuery = '''
    query SearchOrganizations(\$searchOrganizationsInput: SearchOrganizationsInput!) {
      searchOrganizations(searchOrganizationsInput: \$searchOrganizationsInput) {
        id
        name
        type
        description
        country
        province
        canton
        memberCount
        maxCapacity
        status
        isActive
        isVerified
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _organizationQuery = '''
    query Organization(\$id: ID!) {
      organization(id: \$id) {
        id
        name
        type
        legalId
        description
        email
        phone
        website
        address
        country
        province
        canton
        district
        status
        legalRepresentativeId
        memberCount
        maxCapacity
        isActive
        isVerified
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _requestMembershipMutation = '''
    mutation RequestMembership(\$requestMembershipInput: RequestMembershipInput!) {
      requestMembership(requestMembershipInput: \$requestMembershipInput) {
        id
        organizationId
        userId
        status
        role
        requestMessage
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _approveMembershipMutation = '''
    mutation ApproveMembership(\$approveMembershipInput: ApproveMembershipInput!) {
      approveMembership(approveMembershipInput: \$approveMembershipInput) {
        id
        organizationId
        userId
        status
        role
        approvedBy
        approvedAt
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _rejectMembershipMutation = '''
    mutation RejectMembership(\$rejectMembershipInput: RejectMembershipInput!) {
      rejectMembership(rejectMembershipInput: \$rejectMembershipInput) {
        id
        organizationId
        userId
        status
        rejectionReason
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _assignRoleMutation = '''
    mutation AssignRole(\$assignRoleInput: AssignRoleInput!) {
      assignRole(assignRoleInput: \$assignRoleInput) {
        id
        organizationId
        userId
        role
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _organizationMembershipsQuery = '''
    query OrganizationMemberships(\$organizationId: ID!) {
      organizationMemberships(organizationId: \$organizationId) {
        id
        userId
        status
        role
        requestMessage
        approvedBy
        approvedAt
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _myMembershipsQuery = '''
    query MyMemberships {
      myMemberships {
        id
        organizationId
        status
        role
        createdAt
        updatedAt
      }
    }
  ''';

  Future<Either<Failure, Organization>> registerOrganization(
    RegisterOrganizationInput input,
  ) async {
    try {
      debugPrint(
        '[OrganizationsRepository] 📝 Registrando organización: ${input.name}',
      );

      final result = await _client.mutate(
        MutationOptions(
          document: gql(_registerOrganizationMutation),
          variables: {'registerOrganizationInput': input.toJson()},
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        String errorMessage;

        if (exception.graphqlErrors.isNotEmpty) {
          errorMessage = exception.graphqlErrors.first.message;
          debugPrint(
            '[OrganizationsRepository] ❌ Error GraphQL: $errorMessage',
          );
        } else if (exception.linkException != null) {
          errorMessage = exception.linkException.toString();
          debugPrint(
            '[OrganizationsRepository] ❌ Error de conexión: $errorMessage',
          );
        } else {
          errorMessage = 'Error desconocido en la conexión';
        }

        return Left(ServerFailure(errorMessage));
      }

      final data =
          result.data?['registerOrganization'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Invalid response from server'));
      }

      final organization = Organization.fromJson(data);
      debugPrint(
        '[OrganizationsRepository] ✅ Organización registrada: ${organization.name}',
      );

      return Right(organization);
    } catch (e) {
      debugPrint('[OrganizationsRepository] ❌ Error en registro: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Organization>>> searchOrganizations(
    SearchOrganizationsInput input,
  ) async {
    try {
      debugPrint('[OrganizationsRepository] 🔍 Buscando organizaciones...');

      final result = await _client.query(
        QueryOptions(
          document: gql(_searchOrganizationsQuery),
          variables: {'searchOrganizationsInput': input.toJson()},
          fetchPolicy: FetchPolicy.networkOnly,
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

      final data = result.data?['searchOrganizations'] as List<dynamic>?;
      if (data == null) {
        return const Right([]);
      }

      final organizations = data
          .map((json) => Organization.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint(
        '[OrganizationsRepository] ✅ ${organizations.length} organizaciones encontradas',
      );

      return Right(organizations);
    } catch (e) {
      debugPrint('[OrganizationsRepository] ❌ Error en búsqueda: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Organization>> getOrganization(String id) async {
    try {
      debugPrint('[OrganizationsRepository] 🔍 Obteniendo organización: $id');

      final result = await _client.query(
        QueryOptions(
          document: gql(_organizationQuery),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
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

      final data = result.data?['organization'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Organization not found'));
      }

      final organization = Organization.fromJson(data);
      debugPrint(
        '[OrganizationsRepository] ✅ Organización obtenida: ${organization.name}',
      );

      return Right(organization);
    } catch (e) {
      debugPrint('[OrganizationsRepository] ❌ Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OrganizationMembership>> requestMembership({
    required String organizationId,
    String? requestMessage,
  }) async {
    try {
      debugPrint('[OrganizationsRepository] 📝 Solicitando membresía...');

      final result = await _client.mutate(
        MutationOptions(
          document: gql(_requestMembershipMutation),
          variables: {
            'requestMembershipInput': {
              'organizationId': organizationId,
              'requestMessage': ?requestMessage,
            },
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

      final data = result.data?['requestMembership'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Invalid response from server'));
      }

      final membership = OrganizationMembership.fromJson(data);
      debugPrint('[OrganizationsRepository] ✅ Membresía solicitada');

      return Right(membership);
    } catch (e) {
      debugPrint('[OrganizationsRepository] ❌ Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OrganizationMembership>> approveMembership({
    required String membershipId,
    OrganizationRole? role,
  }) async {
    try {
      debugPrint('[OrganizationsRepository] ✅ Aprobando membresía...');

      final result = await _client.mutate(
        MutationOptions(
          document: gql(_approveMembershipMutation),
          variables: {
            'approveMembershipInput': {
              'membershipId': membershipId,
              if (role != null) 'role': role.name.toUpperCase(),
            },
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

      final data = result.data?['approveMembership'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Invalid response from server'));
      }

      final membership = OrganizationMembership.fromJson(data);
      debugPrint('[OrganizationsRepository] ✅ Membresía aprobada');

      return Right(membership);
    } catch (e) {
      debugPrint('[OrganizationsRepository] ❌ Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OrganizationMembership>> rejectMembership({
    required String membershipId,
    String? rejectionReason,
  }) async {
    try {
      debugPrint('[OrganizationsRepository] ❌ Rechazando membresía...');

      final result = await _client.mutate(
        MutationOptions(
          document: gql(_rejectMembershipMutation),
          variables: {
            'rejectMembershipInput': {
              'membershipId': membershipId,
              'rejectionReason': ?rejectionReason,
            },
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

      final data = result.data?['rejectMembership'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Invalid response from server'));
      }

      final membership = OrganizationMembership.fromJson(data);
      debugPrint('[OrganizationsRepository] ✅ Membresía rechazada');

      return Right(membership);
    } catch (e) {
      debugPrint('[OrganizationsRepository] ❌ Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OrganizationMembership>> assignRole({
    required String membershipId,
    required OrganizationRole role,
  }) async {
    try {
      debugPrint('[OrganizationsRepository] 🔄 Asignando rol...');

      final result = await _client.mutate(
        MutationOptions(
          document: gql(_assignRoleMutation),
          variables: {
            'assignRoleInput': {
              'membershipId': membershipId,
              'role': role.name.toUpperCase(),
            },
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

      final data = result.data?['assignRole'] as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure('Invalid response from server'));
      }

      final membership = OrganizationMembership.fromJson(data);
      debugPrint('[OrganizationsRepository] ✅ Rol asignado');

      return Right(membership);
    } catch (e) {
      debugPrint('[OrganizationsRepository] ❌ Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<OrganizationMembership>>>
  getOrganizationMemberships(String organizationId) async {
    try {
      debugPrint('[OrganizationsRepository] 🔍 Obteniendo membresías...');

      final result = await _client.query(
        QueryOptions(
          document: gql(_organizationMembershipsQuery),
          variables: {'organizationId': organizationId},
          fetchPolicy: FetchPolicy.networkOnly,
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

      final data = result.data?['organizationMemberships'] as List<dynamic>?;
      if (data == null) {
        return const Right([]);
      }

      final memberships = data
          .map(
            (json) =>
                OrganizationMembership.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      debugPrint(
        '[OrganizationsRepository] ✅ ${memberships.length} membresías encontradas',
      );

      return Right(memberships);
    } catch (e) {
      debugPrint('[OrganizationsRepository] ❌ Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<OrganizationMembership>>>
  getMyMemberships() async {
    try {
      debugPrint('[OrganizationsRepository] 🔍 Obteniendo mis membresías...');

      final result = await _client.query(
        QueryOptions(
          document: gql(_myMembershipsQuery),
          fetchPolicy: FetchPolicy.networkOnly,
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

      final data = result.data?['myMemberships'] as List<dynamic>?;
      if (data == null) {
        return const Right([]);
      }

      final memberships = data
          .map(
            (json) =>
                OrganizationMembership.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      debugPrint(
        '[OrganizationsRepository] ✅ ${memberships.length} membresías encontradas',
      );

      return Right(memberships);
    } catch (e) {
      debugPrint('[OrganizationsRepository] ❌ Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
