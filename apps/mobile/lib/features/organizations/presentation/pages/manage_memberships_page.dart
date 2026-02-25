import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/widgets/atoms/app_snackbar.dart';
import 'package:altrupets/features/organizations/data/models/organization_membership.dart';
import 'package:altrupets/features/organizations/presentation/providers/organizations_provider.dart';

class ManageMembershipsPage extends ConsumerStatefulWidget {
  const ManageMembershipsPage({
    required this.organizationId,
    required this.organizationName,
    super.key,
  });
  final String organizationId;
  final String organizationName;

  @override
  ConsumerState<ManageMembershipsPage> createState() =>
      _ManageMembershipsPageState();
}

class _ManageMembershipsPageState extends ConsumerState<ManageMembershipsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(organizationsProvider.notifier)
          .getOrganizationMemberships(widget.organizationId);
    });
  }

  Future<void> _approveMembership(OrganizationMembership membership) async {
    final role = await showDialog<OrganizationRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprobar Membresía'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona el rol para el nuevo miembro:'),
            const SizedBox(height: 16),
            ...OrganizationRole.values.map((role) {
              return RadioListTile<OrganizationRole>(
                title: Text(_getRoleLabel(role)),
                subtitle: Text(_getRoleDescription(role)),
                value: role,
                groupValue: OrganizationRole.member,
                onChanged: (value) {
                  Navigator.of(context).pop(value);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (role == null) return;

    await ref
        .read(organizationsProvider.notifier)
        .approveMembership(membershipId: membership.id, role: role);

    if (!mounted) return;

    final state = ref.read(organizationsProvider);

    if (state.error != null) {
      AppSnackbar.error(context: context, message: state.error!);
    } else {
      AppSnackbar.success(
        context: context,
        message: 'Membresía aprobada exitosamente',
      );
    }
  }

  Future<void> _rejectMembership(OrganizationMembership membership) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Membresía'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de rechazar esta solicitud?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Razón del rechazo (opcional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(organizationsProvider.notifier)
        .rejectMembership(
          membershipId: membership.id,
          rejectionReason: reasonController.text.trim().isEmpty
              ? null
              : reasonController.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(organizationsProvider);

    if (state.error != null) {
      AppSnackbar.error(context: context, message: state.error!);
    } else {
      AppSnackbar.info(context: context, message: 'Membresía rechazada');
    }
  }

  Future<void> _assignRole(OrganizationMembership membership) async {
    final role = await showDialog<OrganizationRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asignar Rol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona el nuevo rol:'),
            const SizedBox(height: 16),
            ...OrganizationRole.values.map((role) {
              return RadioListTile<OrganizationRole>(
                title: Text(_getRoleLabel(role)),
                subtitle: Text(_getRoleDescription(role)),
                value: role,
                groupValue: membership.role,
                onChanged: (value) {
                  Navigator.of(context).pop(value);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (role == null || role == membership.role) return;

    await ref
        .read(organizationsProvider.notifier)
        .assignRole(membershipId: membership.id, role: role);

    if (!mounted) return;

    final state = ref.read(organizationsProvider);

    if (state.error != null) {
      AppSnackbar.error(context: context, message: state.error!);
    } else {
      AppSnackbar.success(
        context: context,
        message: 'Rol asignado exitosamente',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(organizationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Membresías - ${widget.organizationName}')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(organizationsProvider.notifier)
                          .getOrganizationMemberships(widget.organizationId);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : state.memberships.isEmpty
          ? const Center(child: Text('No hay membresías registradas'))
          : ListView.builder(
              itemCount: state.memberships.length,
              itemBuilder: (context, index) {
                final membership = state.memberships[index];
                return _MembershipCard(
                  membership: membership,
                  onApprove: () => _approveMembership(membership),
                  onReject: () => _rejectMembership(membership),
                  onAssignRole: () => _assignRole(membership),
                );
              },
            ),
    );
  }

  String _getRoleLabel(OrganizationRole role) {
    switch (role) {
      case OrganizationRole.legalRepresentative:
        return 'Representante Legal';
      case OrganizationRole.userAdmin:
        return 'Administrador de Usuarios';
      case OrganizationRole.member:
        return 'Miembro';
    }
  }

  String _getRoleDescription(OrganizationRole role) {
    switch (role) {
      case OrganizationRole.legalRepresentative:
        return 'Máxima autoridad, puede asignar roles';
      case OrganizationRole.userAdmin:
        return 'Puede aprobar/rechazar membresías';
      case OrganizationRole.member:
        return 'Miembro regular de la organización';
    }
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.membership,
    required this.onApprove,
    required this.onReject,
    required this.onAssignRole,
  });
  final OrganizationMembership membership;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onAssignRole;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(membership.userId.substring(0, 2).toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuario: ${membership.userId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(membership.status),
                            size: 16,
                            color: _getStatusColor(membership.status),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusLabel(membership.status),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(membership.status),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    _getRoleLabel(membership.role),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            if (membership.requestMessage != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Mensaje:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                membership.requestMessage!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (membership.rejectionReason != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Razón del rechazo:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                membership.rejectionReason!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Solicitado: ${_formatDate(membership.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (membership.approvedAt != null)
              Text(
                'Aprobado: ${_formatDate(membership.approvedAt!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (membership.status == MembershipStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                      label: const Text('Rechazar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (membership.status == MembershipStatus.approved) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAssignRole,
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Cambiar Rol'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(MembershipStatus status) {
    switch (status) {
      case MembershipStatus.pending:
        return 'Pendiente';
      case MembershipStatus.approved:
        return 'Aprobada';
      case MembershipStatus.rejected:
        return 'Rechazada';
      case MembershipStatus.revoked:
        return 'Revocada';
    }
  }

  IconData _getStatusIcon(MembershipStatus status) {
    switch (status) {
      case MembershipStatus.pending:
        return Icons.pending;
      case MembershipStatus.approved:
        return Icons.check_circle;
      case MembershipStatus.rejected:
        return Icons.cancel;
      case MembershipStatus.revoked:
        return Icons.block;
    }
  }

  Color _getStatusColor(MembershipStatus status) {
    switch (status) {
      case MembershipStatus.pending:
        return Colors.orange;
      case MembershipStatus.approved:
        return Colors.green;
      case MembershipStatus.rejected:
        return Colors.red;
      case MembershipStatus.revoked:
        return Colors.grey;
    }
  }

  String _getRoleLabel(OrganizationRole role) {
    switch (role) {
      case OrganizationRole.legalRepresentative:
        return 'Rep. Legal';
      case OrganizationRole.userAdmin:
        return 'Admin';
      case OrganizationRole.member:
        return 'Miembro';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
