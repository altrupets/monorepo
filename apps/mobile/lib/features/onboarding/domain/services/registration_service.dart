import '../../../../core/network/http_client_service.dart';
import '../../../../core/models/user_model.dart';

/// Registration service - CLIENT of backend GraphQL API
/// Handles user registration by calling backend mutations
class RegistrationService {
  final HttpClientService _httpClient;

  RegistrationService({required HttpClientService httpClient})
      : _httpClient = httpClient;

  /// Register individual user
  /// Calls backend GraphQL mutation 'register'
  Future<UserModel> registerIndividual({
    required String username,
    String? email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? identification,
    List<UserRole>? roles,
  }) async {
    const mutation = r'''
      mutation Register(
        $username: String!
        $email: String
        $password: String!
        $firstName: String
        $lastName: String
        $phone: String
        $identification: String
        $roles: [UserRole!]
      ) {
        register(
          registerInput: {
            username: $username
            email: $email
            password: $password
            firstName: $firstName
            lastName: $lastName
            phone: $phone
            identification: $identification
            roles: $roles
          }
        ) {
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
          bio
          organizationId
          latitude
          longitude
          isActive
          isVerified
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await _httpClient.post<Map<String, dynamic>>(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {
          'username': username,
          if (email != null) 'email': email,
          'password': password,
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phone != null) 'phone': phone,
          if (identification != null) 'identification': identification,
          if (roles != null)
            'roles': roles.map((r) => r.toGraphQLString()).toList(),
        },
      },
    );

    if (response.data?['errors'] != null) {
      throw Exception(
        'Registration failed: ${response.data?['errors'][0]['message']}',
      );
    }

    return UserModel.fromJson(
      response.data?['data']['register'] as Map<String, dynamic>,
    );
  }
}
