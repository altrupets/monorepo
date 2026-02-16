import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/molecules/app_service_card.dart';

class RescuesPage extends StatelessWidget {
  const RescuesPage({this.onBack, super.key});

  final VoidCallback? onBack;

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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (onBack != null) ...[
                          IconButton(
                            onPressed: onBack,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.surfaceContainer,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RESCATES',
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    AppServiceCard(
                      title: 'Informar de un\nanimal vulnerable',
                      icon: Icons.campaign_rounded,
                      gradientColors: const [Color(0xFF9333EA), Color(0xFF9333EA)], // Purple-600
                      onTap: () {},
                    ),
                    AppServiceCard(
                      title: 'Captar a un\nanimal vulnerable',
                      icon: Icons.directions_car_rounded,
                      gradientColors: const [Color(0xFFDC2626), Color(0xFFDC2626)], // Red-600
                      onTap: () {},
                    ),
                    AppServiceCard(
                      title: 'Aceptar nuevo animal\nen mi casa cuna',
                      icon: Icons.night_shelter_rounded,
                      gradientColors: const [Color(0xFF3B82F6), Color(0xFF3B82F6)], // Blue-500
                      onTap: () {},
                    ),
                    AppServiceCard(
                      title: 'Dar seguimiento a\nrescates activos',
                      icon: Icons.manage_search_rounded,
                      gradientColors: const [Color(0xFF0D9488), Color(0xFF0D9488)], // Teal-600
                      onTap: () {},
                    ),
                    AppServiceCard(
                      title: 'Entregar en\nadopción',
                      icon: Icons.volunteer_activism_rounded,
                      gradientColors: const [Color(0xFF65A30D), Color(0xFF65A30D)], // Lime-600
                      onTap: () {},
                    ),
                    AppServiceCard(
                      title: 'Registrarme como\nrescatista',
                      icon: Icons.edit_note_rounded,
                      gradientColors: const [
                        Color(0xFF1E40AF), // Blue-800/700
                        Color(0xFF2563EB), // Blue-600
                      ],
                      onTap: () {},
                    ),
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
}
