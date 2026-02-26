import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionPage extends StatelessWidget {
  const LocationPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.onSurface.withOpacity(0.05),
                    hoverColor: colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Radar Graphic
                    const _RadarGraphic(),
                    const SizedBox(height: 32),

                    // Text Content
                    Text(
                      '¡Ayúdanos a encontrarlos!',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Necesitamos acceso a tu ubicación para que los rescatistas sepan exactamente dónde buscar al animal vulnerable y llegar lo antes posible.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withOpacity(0.0),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final status = await Permission.location.request();
                        if (context.mounted) {
                          Navigator.of(context).pop(status.isGranted);
                        }
                      },
                      icon: const Icon(Icons.near_me),
                      label: const Text('Permitir acceso a ubicación'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 4,
                        shadowColor: colorScheme.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tu privacidad es importante. Solo compartimos tu ubicación con las organizaciones de rescate verificadas para este reporte.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.4),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarGraphic extends StatelessWidget {
  const _RadarGraphic();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Using a custom color from the Stitch spec mapped to the theme or a specific hex if strictly brand colored.
    // Spec had accent-orange ("#F2994A"). Here we use a tertiary or custom color if not defined.
    final accentOrange = colorScheme.tertiary;

    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: Border.all(
                color: colorScheme.onSurface.withOpacity(0.05),
              ),
            ),
          ),
          // Radar rings
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withOpacity(0.05),
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withOpacity(0.1),
              border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
            ),
          ),

          // Central icons
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Icon(Icons.location_on, size: 80, color: accentOrange),
              const Positioned(
                top: 18,
                child: Icon(
                  Icons.pets,
                  size: 32,
                  color: Colors.black87, // Contrast color from the spec
                ),
              ),
            ],
          ),

          // Floating icon 1 (Search)
          Positioned(
            top: 60,
            right: 30,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.search, color: colorScheme.primary, size: 20),
            ),
          ),

          // Floating icon 2 (Warning)
          Positioned(
            bottom: 60,
            left: 30,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: accentOrange,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
