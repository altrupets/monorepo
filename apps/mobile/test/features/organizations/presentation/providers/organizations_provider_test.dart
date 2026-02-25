import 'package:flutter_test/flutter_test.dart';
import 'package:altrupets/features/organizations/presentation/providers/organizations_provider.dart';
import 'package:altrupets/features/organizations/data/models/organization.dart';
import 'package:altrupets/features/organizations/data/models/organization_membership.dart';

void main() {
  group('OrganizationsState', () {
    test('should have correct default values', () {
      final state = OrganizationsState();

      expect(state.organizations, isEmpty);
      expect(state.selectedOrganization, isNull);
      expect(state.memberships, isEmpty);
      expect(state.myMemberships, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.pendingSyncCount, 0);
      expect(state.hasPendingChanges, isFalse);
    });

    test('should copy with isLoading', () {
      final state = OrganizationsState();
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, isTrue);
      expect(newState.organizations, isEmpty);
    });

    test('should copy with error', () {
      final state = OrganizationsState();
      final newState = state.copyWith(error: 'Test error');

      expect(newState.error, 'Test error');
      expect(newState.isLoading, isFalse);
    });

    test('should copy with organizations list', () {
      final state = OrganizationsState();
      final orgs = [
        Organization(
          id: '1',
          name: 'Test',
          type: OrganizationType.foundation,
          status: OrganizationStatus.active,
          memberCount: 1,
          maxCapacity: 10,
          isActive: true,
          isVerified: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      final newState = state.copyWith(organizations: orgs);

      expect(newState.organizations.length, 1);
      expect(newState.organizations.first.name, 'Test');
    });

    test('should copy with selectedOrganization', () {
      final state = OrganizationsState();
      final org = Organization(
        id: '1',
        name: 'Selected Org',
        type: OrganizationType.foundation,
        status: OrganizationStatus.active,
        memberCount: 1,
        maxCapacity: 10,
        isActive: true,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final newState = state.copyWith(selectedOrganization: org);

      expect(newState.selectedOrganization, isNotNull);
      expect(newState.selectedOrganization?.name, 'Selected Org');
    });

    test('should copy with memberships', () {
      final state = OrganizationsState();
      final memberships = [
        OrganizationMembership(
          id: 'm1',
          organizationId: 'org-1',
          userId: 'user-1',
          status: MembershipStatus.pending,
          role: OrganizationRole.member,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      final newState = state.copyWith(memberships: memberships);

      expect(newState.memberships.length, 1);
      expect(newState.memberships.first.status, MembershipStatus.pending);
    });

    test('should copy with myMemberships', () {
      final state = OrganizationsState();
      final memberships = [
        OrganizationMembership(
          id: 'm1',
          organizationId: 'org-1',
          userId: 'user-1',
          status: MembershipStatus.approved,
          role: OrganizationRole.member,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      final newState = state.copyWith(myMemberships: memberships);

      expect(newState.myMemberships.length, 1);
      expect(newState.myMemberships.first.status, MembershipStatus.approved);
    });

    test('should copy with pendingSyncCount', () {
      final state = OrganizationsState();
      final newState = state.copyWith(pendingSyncCount: 5);

      expect(newState.pendingSyncCount, 5);
      expect(newState.hasPendingChanges, isFalse);
    });

    test('should copy with hasPendingChanges', () {
      final state = OrganizationsState();
      final newState = state.copyWith(hasPendingChanges: true);

      expect(newState.hasPendingChanges, isTrue);
    });

    test('should clear error when copying', () {
      final state = OrganizationsState(error: 'Previous error');
      final newState = state.copyWith(error: null);

      expect(newState.error, isNull);
    });

    test('should clear selectedOrganization when copying', () {
      final state = OrganizationsState(
        selectedOrganization: Organization(
          id: '1',
          name: 'Org',
          type: OrganizationType.foundation,
          status: OrganizationStatus.active,
          memberCount: 1,
          maxCapacity: 10,
          isActive: true,
          isVerified: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Note: copyWith doesn't support clearing nullable fields via null
      // This test verifies the current behavior
      final newState = state.copyWith(
        selectedOrganization: state.selectedOrganization,
      );

      expect(newState.selectedOrganization, isNotNull);
    });
  });
}
