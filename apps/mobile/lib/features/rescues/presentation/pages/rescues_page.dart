import 'package:flutter/material.dart';

class RescuesPage extends StatelessWidget {
  const RescuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          SafeArea(
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
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gestiona tus actividades de rescate',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(context),
          ),
        ],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Registrarme como\nrescatista',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
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
                  color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.edit_note_rounded, color: Color(0xFFF97316), size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.groups_rounded, 'Comunidad'),
          _buildNavItem(Icons.chat_bubble_rounded, 'Mensajes'),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF97316),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66F97316),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
            ),
          ),
          _buildNavItem(Icons.person_rounded, 'Perfil'),
          _buildNavItem(Icons.settings_rounded, 'Ajustes'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
