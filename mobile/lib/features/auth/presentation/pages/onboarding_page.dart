import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Página de onboarding inicial de AltruPets
/// Permite elegir entre:
/// - Hacer Denuncia Anónima (sin autenticación)
/// - Registrarse como Usuario Individual
/// - Registrar Nueva Organización
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo y título
              const Spacer(),
              Icon(
                Icons.pets,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'AltruPets',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Protección Animal en Toda Latinoamérica',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const Spacer(),

              // Opciones principales
              _OnboardingOption(
                icon: Icons.report_problem,
                title: 'Hacer Denuncia Anónima',
                description:
                    'Reporta un animal en situación vulnerable sin necesidad de registrarte',
                onTap: () {
                  // TODO: Navegar a página de denuncia anónima
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Denuncias anónimas'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _OnboardingOption(
                icon: Icons.person_add,
                title: 'Registrarse como Usuario Individual',
                description:
                    'Crea una cuenta para participar como Centinela, Auxiliar, Rescatista, Adoptante o Donante',
                onTap: () {
                  // TODO: Navegar a registro individual
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Registro individual'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _OnboardingOption(
                icon: Icons.business,
                title: 'Registrar Nueva Organización',
                description:
                    'Registra una organización (rescatistas, casas cuna, etc.) con representante legal',
                onTap: () {
                  // TODO: Navegar a registro organizacional
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Registro organizacional'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Opción de iniciar sesión
              TextButton(
                onPressed: () {
                  // TODO: Navegar a login
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Iniciar sesión'),
                    ),
                  );
                },
                child: Text(
                  'Ya tengo una cuenta',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de opción de onboarding
class _OnboardingOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _OnboardingOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
