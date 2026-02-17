import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/features/organizations/data/models/organization.dart';
import 'package:altrupets/features/organizations/data/models/organization_membership.dart';
import 'package:altrupets/features/organizations/data/models/register_organization_input.dart';
import 'package:altrupets/features/organizations/data/models/search_organizations_input.dart';
import 'package:altrupets/features/organizations/data/repositories/organizations_repository.dart';

final organizationsRepositoryProvider = Provider<OrganizationsRepository>((ref) {
  return OrganizationsRepository();
});

class OrganizationsState {
  final List<Organization> organizations;
  final Organization? selectedOrganization;
  final List<OrganizationMembership> memberships;
  final List<OrganizationMembership> myMemberships;
  final bool isLoading;
  final String? error;

  OrganizationsState({
    this.organizations = const [],
    this.selectedOrganization,
    this.memberships = const [],
    this.myMemberships = const [],
    this.isLoading = false,
    this.error,
  });

  OrganizationsState copyWith({
    List<Organization>? organizations,
    Organization? selectedOrganization,
    List<OrganizationMembership>? memberships,
    List<OrganizationMembership>? myMemberships,
    bool? isLoading,
    String? error,
  }) {
    return OrganizationsState(
      organizations: organizations ?? this.organizations,
      selectedOrganization: selectedOrganization ?? this.selectedOrganization,
      memberships: memberships ?? this.memberships,
      myMemberships: myMemberships ?? this.myMemberships,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrganizationsNotifier extends StateNotifier<OrganizationsState> {
  final OrganizationsRepository _repository;

  OrganizationsNotifier(this._repository) : super(OrganizationsState());

  Future<void> registerOrganization(RegisterOrganizationInput input) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.registerOrganization(input);

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (organization) {
        debugPrint('[OrganizationsNotifier] ✅ Organización registrada: ${organization.name}');
        state = state.copyWith(
          isLoading: false,
          selectedOrganization: organization,
          organizations: [...state.organizations, organization],
        );
      },
    );
  }

  Future<void> searchOrganizations(SearchOrganizationsInput input) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.searchOrganizations(input);

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (organizations) {
        debugPrint('[OrganizationsNotifier] ✅ ${organizations.length} organizaciones encontradas');
        state = state.copyWith(
          isLoading: false,
          organizations: organizations,
        );
      },
    );
  }

  Future<void> getOrganization(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getOrganization(id);

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (organization) {
        debugPrint('[OrganizationsNotifier] ✅ Organización obtenida: ${organization.name}');
        state = state.copyWith(
          isLoading: false,
          selectedOrganization: organization,
        );
      },
    );
  }

  Future<void> requestMembership({
    required String organizationId,
    String? requestMessage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.requestMembership(
      organizationId: organizationId,
      requestMessage: requestMessage,
    );

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (membership) {
        debugPrint('[OrganizationsNotifier] ✅ Membresía solicitada');
        state = state.copyWith(
          isLoading: false,
          myMemberships: [...state.myMemberships, membership],
        );
      },
    );
  }

  Future<void> approveMembership({
    required String membershipId,
    OrganizationRole? role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.approveMembership(
      membershipId: membershipId,
      role: role,
    );

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (membership) {
        debugPrint('[OrganizationsNotifier] ✅ Membresía aprobada');
        // Update memberships list
        final updatedMemberships = state.memberships.map((m) {
          return m.id == membership.id ? membership : m;
        }).toList();
        state = state.copyWith(
          isLoading: false,
          memberships: updatedMemberships,
        );
      },
    );
  }

  Future<void> rejectMembership({
    required String membershipId,
    String? rejectionReason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.rejectMembership(
      membershipId: membershipId,
      rejectionReason: rejectionReason,
    );

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (membership) {
        debugPrint('[OrganizationsNotifier] ✅ Membresía rechazada');
        // Update memberships list
        final updatedMemberships = state.memberships.map((m) {
          return m.id == membership.id ? membership : m;
        }).toList();
        state = state.copyWith(
          isLoading: false,
          memberships: updatedMemberships,
        );
      },
    );
  }

  Future<void> assignRole({
    required String membershipId,
    required OrganizationRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.assignRole(
      membershipId: membershipId,
      role: role,
    );

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (membership) {
        debugPrint('[OrganizationsNotifier] ✅ Rol asignado');
        // Update memberships list
        final updatedMemberships = state.memberships.map((m) {
          return m.id == membership.id ? membership : m;
        }).toList();
        state = state.copyWith(
          isLoading: false,
          memberships: updatedMemberships,
        );
      },
    );
  }

  Future<void> getOrganizationMemberships(String organizationId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getOrganizationMemberships(organizationId);

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (memberships) {
        debugPrint('[OrganizationsNotifier] ✅ ${memberships.length} membresías obtenidas');
        state = state.copyWith(
          isLoading: false,
          memberships: memberships,
        );
      },
    );
  }

  Future<void> getMyMemberships() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getMyMemberships();

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (memberships) {
        debugPrint('[OrganizationsNotifier] ✅ ${memberships.length} membresías obtenidas');
        state = state.copyWith(
          isLoading: false,
          myMemberships: memberships,
        );
      },
    );
  }
}

final organizationsProvider =
    StateNotifierProvider<OrganizationsNotifier, OrganizationsState>((ref) {
  final repository = ref.watch(organizationsRepositoryProvider);
  return OrganizationsNotifier(repository);
});
