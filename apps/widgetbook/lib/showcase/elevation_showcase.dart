import 'package:flutter/material.dart';
import 'design_system_state.dart';

class ElevationShowcase extends StatelessWidget {
  final DesignSystemManager manager;
  const ElevationShowcase({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.layers_rounded, size: 32),
              const SizedBox(width: 16),
              Text(
                'Elevation',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Elevation is the relative distance between two surfaces along the z-axis.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            children: [
              _ElevationCard(level: 0, elevation: 0),
              _ElevationCard(level: 1, elevation: 1),
              _ElevationCard(level: 2, elevation: 3),
              _ElevationCard(level: 3, elevation: 6),
              _ElevationCard(level: 4, elevation: 8),
              _ElevationCard(level: 5, elevation: 12),
            ],
          ),
          const SizedBox(height: 64),
          _SurfaceTintSection(),
        ],
      ),
    );
  }
}

class _ElevationCard extends StatelessWidget {
  final int level;
  final double elevation;

  const _ElevationCard({
    required this.level,
    required this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: elevation,
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainer,
          shadowColor: Theme.of(context).colorScheme.shadow,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Level $level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${elevation.toInt()} dp',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SurfaceTintSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Surface Tint & Tonal Elevation',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'In Material 3, elevation is also expressed through a surface tint color that overlays the surface color.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            _TintCard(level: 0, color: Theme.of(context).colorScheme.surface),
            const SizedBox(width: 16),
            _TintCard(level: 1, color: Theme.of(context).colorScheme.surfaceContainerLow),
            const SizedBox(width: 16),
            _TintCard(level: 2, color: Theme.of(context).colorScheme.surfaceContainer),
            const SizedBox(width: 16),
            _TintCard(level: 3, color: Theme.of(context).colorScheme.surfaceContainerHigh),
            const SizedBox(width: 16),
            _TintCard(level: 4, color: Theme.of(context).colorScheme.surfaceContainerHighest),
          ],
        ),
      ],
    );
  }
}

class _TintCard extends StatelessWidget {
  final int level;
  final Color color;

  const _TintCard({
    required this.level,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: level == 0 ? Border.all(color: Theme.of(context).colorScheme.outlineVariant) : null,
        ),
        child: Center(
          child: Text(
            'Surface $level',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}
