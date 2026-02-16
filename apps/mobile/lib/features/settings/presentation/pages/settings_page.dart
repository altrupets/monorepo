import 'package:altrupets/core/providers/navigation_provider.dart';
import 'package:altrupets/features/auth/presentation/pages/login_page.dart';
import 'package:altrupets/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Ajustes',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.person_outline_rounded),
                    title: Text('Cuenta'),
                    subtitle: Text('Configuración de tu perfil'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.security_rounded),
                    title: Text('Privacidad y seguridad'),
                    subtitle: Text('Opciones de acceso y privacidad'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (!context.mounted) {
                    return;
                  }
                  ref.read(navigationProvider).navigateAndRemoveAll(
                        context,
                        const LoginPage(),
                      );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar Sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(
                    color: Colors.red.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
