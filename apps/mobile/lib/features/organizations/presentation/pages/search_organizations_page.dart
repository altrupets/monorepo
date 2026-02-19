import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/features/organizations/data/models/organization.dart';
import 'package:altrupets/features/organizations/data/models/search_organizations_input.dart';
import 'package:altrupets/features/organizations/presentation/providers/organizations_provider.dart';
import 'package:altrupets/features/organizations/presentation/pages/organization_detail_page.dart';

class SearchOrganizationsPage extends ConsumerStatefulWidget {
  const SearchOrganizationsPage({super.key});

  @override
  ConsumerState<SearchOrganizationsPage> createState() =>
      _SearchOrganizationsPageState();
}

class _SearchOrganizationsPageState
    extends ConsumerState<SearchOrganizationsPage> {
  final _searchController = TextEditingController();
  OrganizationType? _selectedType;
  OrganizationStatus? _selectedStatus;
  final _countryController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cantonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load all organizations on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _countryController.dispose();
    _provinceController.dispose();
    _cantonController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final input = SearchOrganizationsInput(
      name: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      type: _selectedType,
      status: _selectedStatus,
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      province: _provinceController.text.trim().isEmpty
          ? null
          : _provinceController.text.trim(),
      canton: _cantonController.text.trim().isEmpty
          ? null
          : _cantonController.text.trim(),
    );

    ref.read(organizationsProvider.notifier).searchOrganizations(input);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(organizationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Organizaciones')),
      body: Column(
        children: [
          // Search filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch();
                      },
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<OrganizationType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...OrganizationType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_getOrganizationTypeLabel(type)),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedType = value);
                          _performSearch();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<OrganizationStatus>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...OrganizationStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(_getOrganizationStatusLabel(status)),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                          _performSearch();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Results
          Expanded(
            child: state.isLoading
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
                          onPressed: _performSearch,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : state.organizations.isEmpty
                ? const Center(child: Text('No se encontraron organizaciones'))
                : ListView.builder(
                    itemCount: state.organizations.length,
                    itemBuilder: (context, index) {
                      final org = state.organizations[index];
                      return _OrganizationCard(
                        organization: org,
                        onTap: () {
                          Navigator.of(context).push<dynamic>(
                            MaterialPageRoute<dynamic>(
                              builder: (_) => OrganizationDetailPage(
                                organizationId: org.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
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
        return 'Pendiente';
      case OrganizationStatus.active:
        return 'Activa';
      case OrganizationStatus.suspended:
        return 'Suspendida';
      case OrganizationStatus.inactive:
        return 'Inactiva';
    }
  }
}

class _OrganizationCard extends StatelessWidget {
  const _OrganizationCard({required this.organization, required this.onTap});
  final Organization organization;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(organization.name[0].toUpperCase())),
        title: Text(organization.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getOrganizationTypeLabel(organization.type)),
            if (organization.description != null)
              Text(
                organization.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getStatusIcon(organization.status),
                  size: 16,
                  color: _getStatusColor(organization.status),
                ),
                const SizedBox(width: 4),
                Text(
                  _getOrganizationStatusLabel(organization.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(organization.status),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.people, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${organization.memberCount} miembros',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
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
        return 'Pendiente';
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
