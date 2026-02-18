import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:altrupets/features/organizations/data/models/organization.dart';
import 'package:altrupets/features/organizations/data/models/organization_membership.dart';
import 'package:altrupets/features/organizations/data/models/register_organization_input.dart';
import 'package:altrupets/features/organizations/data/models/search_organizations_input.dart';
import 'package:altrupets/features/organizations/data/repositories/organizations_repository.dart';
import 'package:altrupets/core/sync/generic_sync_queue_store.dart';
import 'package:altrupets/core/sync/sync_status_provider.dart';
import 'package:altrupets/core/error/failures.dart';
import 'package:dartz/dartz.dart';

final organizationsRepositoryProvider = Provider<OrganizationsRepository>((
  ref,
) {
  return OrganizationsRepository();
});

class OrganizationsState {
  final List<Organization> organizations;
  final Organization? selectedOrganization;
  final List<OrganizationMembership> memberships;
  final List<OrganizationMembership> myMemberships;
  final bool isLoading;
  final String? error;
  final int pendingSyncCount;
  final bool hasPendingChanges;

  OrganizationsState({
    this.organizations = const [],
    this.selectedOrganization,
    this.memberships = const [],
    this.myMemberships = const [],
    this.isLoading = false,
    this.error,
    this.pendingSyncCount = 0,
    this.hasPendingChanges = false,
  });

  OrganizationsState copyWith({
    List<Organization>? organizations,
    Organization? selectedOrganization,
    List<OrganizationMembership>? memberships,
    List<OrganizationMembership>? myMemberships,
    bool? isLoading,
    String? error,
    int? pendingSyncCount,
    bool? hasPendingChanges,
  }) {
    return OrganizationsState(
      organizations: organizations ?? this.organizations,
      selectedOrganization: selectedOrganization ?? this.selectedOrganization,
      memberships: memberships ?? this.memberships,
      myMemberships: myMemberships ?? this.myMemberships,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
    );
  }
}

class OrganizationsNotifier extends StateNotifier<OrganizationsState> {
  final OrganizationsRepository _repository;

  OrganizationsNotifier(this._repository) : super(OrganizationsState());

  /// Verifica y actualiza el estado de cambios pendientes
  Future<void> _refreshPendingStatus() async {
    final pendingCount = await GenericSyncQueueStore.getPendingCount();
    state = state.copyWith(
      pendingSyncCount: pendingCount,
      hasPendingChanges: pendingCount > 0,
    );
  }

  Future<void> registerOrganization(RegisterOrganizationInput input) async {
    state = state.copyWith(isLoading: true, error: null);

    final isConnected = await InternetConnectionChecker().hasConnection;

    if (!isConnected) {
      // Modo offline: encolar para sincronización posterior
      try {
        await GenericSyncQueueStore.enqueue(
          entityType: SyncEntityType.organization,
          entityId: 'new-${DateTime.now().millisecondsSinceEpoch}',
          operation: 'create',
          payload: input.toJson(),
        );

        await _refreshPendingStatus();

        // Crear organización optimista temporal
        final now = DateTime.now();
        final optimisticOrg = Organization(
          id: 'temp-${now.millisecondsSinceEpoch}',
          name: input.name,
          type: input.type,
          legalId: input.legalId,
          description: input.description,
          email: input.email,
          phone: input.phone,
          address: input.address,
          country: input.country,
          province: input.province,
          canton: input.canton,
          district: input.district,
          status: OrganizationStatus.pendingVerification,
          memberCount: 1,
          maxCapacity: 100,
          isActive: true,
          isVerified: false,
          createdAt: now,
          updatedAt: now,
        );

        state = state.copyWith(
          isLoading: false,
          selectedOrganization: optimisticOrg,
          organizations: [...state.organizations, optimisticOrg],
        );

        debugPrint(
          '[OrganizationsNotifier] ⏳ Organización encolada para sincronización offline',
        );
        return;
      } catch (e) {
        debugPrint('[OrganizationsNotifier] ❌ Error encolando: $e');
        state = state.copyWith(
          isLoading: false,
          error: 'Sin conexión. No se pudo guardar la organización.',
        );
        return;
      }
    }

    final result = await _repository.registerOrganization(input);

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (organization) {
        debugPrint(
          '[OrganizationsNotifier] ✅ Organización registrada: ${organization.name}',
        );
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
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (organizations) {
        debugPrint(
          '[OrganizationsNotifier] ✅ ${organizations.length} organizaciones encontradas',
        );
        state = state.copyWith(isLoading: false, organizations: organizations);
      },
    );
  }

  Future<void> getOrganization(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getOrganization(id);

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (organization) {
        debugPrint(
          '[OrganizationsNotifier] ✅ Organización obtenida: ${organization.name}',
        );
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
        state = state.copyWith(isLoading: false, error: failure.message);
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
        state = state.copyWith(isLoading: false, error: failure.message);
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
        state = state.copyWith(isLoading: false, error: failure.message);
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
        state = state.copyWith(isLoading: false, error: failure.message);
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
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (memberships) {
        debugPrint(
          '[OrganizationsNotifier] ✅ ${memberships.length} membresías obtenidas',
        );
        state = state.copyWith(isLoading: false, memberships: memberships);
      },
    );
  }

  Future<void> getMyMemberships() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getMyMemberships();

    result.fold(
      (failure) {
        debugPrint('[OrganizationsNotifier] ❌ Error: ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (memberships) {
        debugPrint(
          '[OrganizationsNotifier] ✅ ${memberships.length} membresías obtenidas',
        );
        state = state.copyWith(isLoading: false, myMemberships: memberships);
      },
    );
  }

  /// Sincroniza operaciones pendientes de organizaciones
  /// Se debe llamar cuando se recupera la conexión
  Future<void> syncPendingOperations() async {
    final isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      debugPrint(
        '[OrganizationsNotifier] 📵 Sin conexión, no se puede sincronizar',
      );
      return;
    }

    final pending = await GenericSyncQueueStore.getByEntityType(
      SyncEntityType.organization,
    );

    if (pending.isEmpty) {
      debugPrint('[OrganizationsNotifier] ✅ No hay operaciones pendientes');
      return;
    }

    debugPrint(
      '[OrganizationsNotifier] 🔄 Sincronizando ${pending.length} operaciones...',
    );

    for (final item in pending) {
      try {
        if (item.operation == 'create') {
          final input = RegisterOrganizationInput.fromJson(item.payload);
          final result = await _repository.registerOrganization(input);

          await result.fold(
            (failure) async {
              debugPrint(
                '[OrganizationsNotifier] ❌ Error sync: ${failure.message}',
              );
              await GenericSyncQueueStore.incrementRetryCount(item.id);
            },
            (organization) async {
              debugPrint(
                '[OrganizationsNotifier] ✅ Sincronizado: ${organization.name}',
              );
              await GenericSyncQueueStore.deleteById(item.id);

              // Actualizar lista local si existe org temporal
              final updatedOrgs = state.organizations.map((org) {
                if (org.id == item.entityId) {
                  return organization;
                }
                return org;
              }).toList();

              state = state.copyWith(organizations: updatedOrgs);
            },
          );
        }
      } catch (e) {
        debugPrint('[OrganizationsNotifier] ❌ Error procesando item: $e');
        await GenericSyncQueueStore.incrementRetryCount(item.id);
      }
    }

    // Limpiar items fallidos después de 3 intentos
    await GenericSyncQueueStore.clearFailed(3);
    await _refreshPendingStatus();
  }
}

final organizationsProvider =
    StateNotifierProvider<OrganizationsNotifier, OrganizationsState>((ref) {
      final repository = ref.watch(organizationsRepositoryProvider);
      return OrganizationsNotifier(repository);
    });
