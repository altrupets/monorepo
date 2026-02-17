import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/features/organizations/data/models/organization.dart';
import 'package:altrupets/features/organizations/presentation/providers/organizations_provider.dart';
import 'package:altrupets/features/organizations/presentation/pages/manage_memberships_page.dart';

class OrganizationDetailPage extends ConsumerStatefulWidget {
  final String organizationId;

  const OrganizationDetailPage({
    super.key,
    required this.organizationId,
  });

  @override
  ConsumerState<OrganizationDetailPage> createState() =>
      _OrganizationDetailPageState();
}

class _OrganizationDetailPageState
    extends ConsumerState<OrganizationDetailPage> {
  final _requestMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(organizationsProvider.notifier)
          .getOrganization(widget.organizationId);
    });
  }

  @override
  void dispose() {
    _requestMessageController.dispose();
    super.dispose();
  }

  Future<void> _requestMembership(Organization org) async {
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar Membresía'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Deseas unirte a ${org.name}?'),
            const SizedBox(height: 16),
            TextField(
              controller: _requestMessageController,
              decoration: const InputDecoration(
                labelText: 'Mensaje (opcional)',
                hintText: 'Explica por qué quieres unirte',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(_requestMessageController.text.trim());
            },
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );

    if (message == null) return;

    await ref.read(organizationsProvider.notifier).requestMembership(
          organizationId: widget.organizationId,
          requestMessage: message.isEmpty ? null : message,
        );

    if (!mounted) return;

    final state = ref.read(organizationsProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(organizationsProvider);
    final org = state.selectedOrganization;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Organización'),
        actions: [
          if (org != null)
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ManageMembershipsPage(
                      organizationId: org.id,
                      organizationName: org.name,
                    ),
                  ),
                );
              },
              tooltip: 'Gestionar Membresías',
            ),
        ],
      ),
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
                              .getOrganization(widget.organizationId);
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : org == null
                  ? const Center(child: Text('Organización no encontrada'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Center(
                            child: CircleAvatar(
                              radius: 48,
                              child: Text(
                                org.name[0].toUpperCase(),
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              org.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Chip(
                              label: Text(_getOrganizationTypeLabel(org.type)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(org.status),
                                  size: 20,
                                  color: _getStatusColor(org.status),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getOrganizationStatusLabel(org.status),
                                  style: TextStyle(
                                    color: _getStatusColor(org.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Description
                          if (org.description != null) ...[
                            const Text(
                              'Descripción',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(org.description!),
                            const SizedBox(height: 24),
                          ],

                          // Contact Info
                          const Text(
                            'Información de Contacto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (org.email != null)
                            _InfoRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: org.email!,
                            ),
                          if (org.phone != null)
                            _InfoRow(
                              icon: Icons.phone,
                              label: 'Teléfono',
                              value: org.phone!,
                            ),
                          if (org.website != null)
                            _InfoRow(
                              icon: Icons.language,
                              label: 'Sitio Web',
                              value: org.website!,
                            ),
                          if (org.address != null)
                            _InfoRow(
                              icon: Icons.location_on,
                              label: 'Dirección',
                              value: org.address!,
                            ),
                          const SizedBox(height: 24),

                          // Location
                          if (org.country != null ||
                              org.province != null ||
                              org.canton != null) ...[
                            const Text(
                              'Ubicación',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (org.country != null)
                              _InfoRow(
                                icon: Icons.flag,
                                label: 'País',
                                value: org.country!,
                              ),
                            if (org.province != null)
                              _InfoRow(
                                icon: Icons.map,
                                label: 'Provincia',
                                value: org.province!,
                              ),
                            if (org.canton != null)
                              _InfoRow(
                                icon: Icons.location_city,
                                label: 'Cantón',
                                value: org.canton!,
                              ),
                            if (org.district != null)
                              _InfoRow(
                                icon: Icons.place,
                                label: 'Distrito',
                                value: org.district!,
                              ),
                            const SizedBox(height: 24),
                          ],

                          // Stats
                          const Text(
                            'Estadísticas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.people,
                            label: 'Miembros',
                            value: '${org.memberCount}',
                          ),
                          _InfoRow(
                            icon: Icons.pets,
                            label: 'Capacidad Máxima',
                            value: '${org.maxCapacity} animales',
                          ),
                          const SizedBox(height: 24),

                          // Legal Info
                          if (org.legalId != null) ...[
                            const Text(
                              'Información Legal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.badge,
                              label: 'Cédula Jurídica',
                              value: org.legalId!,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _requestMembership(org),
                              icon: const Icon(Icons.person_add),
                              label: const Text('Solicitar Membresía'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  String _getOrganizationTypeLabel(OrganizationType type) {
    switch (type) {
      case OrganizationType.foundation:
        return 'Fundación';
      case OrganizationType.association:
        return 'Asociación';
      case OrganizationType.ngo:
        return 'ONG';
      case OrganizationType.cooperative:
        return 'Cooperativa';
      case OrganizationType.government:
        return 'Gubernamental';
      case OrganizationType.other:
        return 'Otro';
    }
  }

  String _getOrganizationStatusLabel(OrganizationStatus status) {
    switch (status) {
      case OrganizationStatus.pendingVerification:
        return 'Pendiente de Verificación';
      case OrganizationStatus.active:
        return 'Activa';
      case OrganizationStatus.suspended:
        return 'Suspendida';
      case OrganizationStatus.inactive:
        return 'Inactiva';
    }
  }

  IconData _getStatusIcon(OrganizationStatus status) {
    switch (status) {
      case OrganizationStatus.pendingVerification:
        return Icons.pending;
      case OrganizationStatus.active:
        return Icons.check_circle;
      case OrganizationStatus.suspended:
        return Icons.pause_circle;
      case OrganizationStatus.inactive:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(OrganizationStatus status) {
    switch (status) {
      case OrganizationStatus.pendingVerification:
        return Colors.orange;
      case OrganizationStatus.active:
        return Colors.green;
      case OrganizationStatus.suspended:
        return Colors.red;
      case OrganizationStatus.inactive:
        return Colors.grey;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
