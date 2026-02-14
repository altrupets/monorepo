import 'package:flutter/material.dart';

class RescuesPage extends StatelessWidget {
  const RescuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Rescates',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestiona tus actividades de rescate',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildActionCard(
                      context,
                      title: 'Informar de un\nanimal vulnerable',
                      icon: Icons.campaign_rounded,
                      color: const Color(0xFF9333EA), // Purple-600
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      context,
                      title: 'Captar a un\nanimal vulnerable',
                      icon: Icons.directions_car_rounded,
                      color: const Color(0xFFDC2626), // Red-600
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      context,
                      title: 'Aceptar nuevo animal\nen mi casa cuna',
                      icon: Icons.night_shelter_rounded,
                      color: const Color(0xFF3B82F6), // Blue-500
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      context,
                      title: 'Dar seguimiento a\nrescates activos',
                      icon: Icons.manage_search_rounded,
                      color: const Color(0xFF0D9488), // Teal-600
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      context,
                      title: 'Entregar en\nadopción',
                      icon: Icons.volunteer_activism_rounded,
                      color: const Color(0xFF65A30D), // Lime-600
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildRescatistaCard(context),
                    const SizedBox(height: 120), // Bottom padding for nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(minHeight: 110),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRescatistaCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E40AF), // Blue-800/700 for a darker premium look
            Color(0xFF2563EB), // Blue-600
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(minHeight: 110),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Registrarme como\nrescatista',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
