import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/widgets/molecules/profile_menu_option.dart';
import 'package:altrupets/core/widgets/organisms/profile_main_header.dart';
import 'package:altrupets/core/widgets/organisms/sync_status_banner.dart';
import 'package:altrupets/core/widgets/molecules/sync_badge.dart';
import 'package:altrupets/features/auth/presentation/pages/login_page.dart';
import 'package:altrupets/features/auth/presentation/providers/auth_provider.dart';
import 'package:altrupets/features/profile/presentation/pages/edit_personal_information_page.dart';
import 'package:altrupets/features/profile/presentation/pages/foster_homes_management_page.dart';
import 'package:altrupets/features/profile/presentation/providers/profile_provider.dart';
import 'package:altrupets/core/providers/navigation_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUserAsync = ref.watch(currentUserProvider);

    final user = currentUserAsync.valueOrNull;
    final fullName = [
      user?.firstName?.trim() ?? '',
      user?.lastName?.trim() ?? '',
    ].where((value) => value.isNotEmpty).join(' ');
    final displayName = fullName.isNotEmpty
        ? fullName
        : (user?.username ?? 'Usuario');
    final locationParts = [
      user?.district?.trim() ?? '',
      user?.canton?.trim() ?? '',
      user?.province?.trim() ?? '',
      user?.country?.trim() ?? '',
    ].where((value) => value.isNotEmpty).toList();
    final displayLocation = locationParts.isNotEmpty
        ? locationParts.join(', ')
        : 'Sin ubicacion';
    final displayRole = user?.roles?.isNotEmpty == true
        ? user!.roles!.first.replaceAll('_', ' ')
        : 'Sin rol';
    ImageProvider<Object>? profileImage;
    if (user?.avatarBase64 != null && user!.avatarBase64!.isNotEmpty) {
      try {
        profileImage = MemoryImage(base64Decode(user.avatarBase64!));
      } catch (_) {
        profileImage = null;
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          const SyncStatusBanner(),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 48), // Space for banner
            child: Column(
              children: [
                // Sync status badge in header area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [const SyncBadge(compact: true)],
                  ),
                ),
                ProfileMainHeader(
                  name: displayName,
                  location: displayLocation,
                  role: displayRole,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDewHnSjAOHz99DJQjDllzYf3AgXQST019_jrays0NgNdSDNYFxOMDEivzqbVFInb23TW4WhzQOxgzRdWf2TBsdBvjaqVNn6pHmt6aKkdePvbTSFR_89ypKVWEpt4cWev7wQXBnYvJRL8DDHw_jFpL8IMzQg5fBYGZe_aj2DHmxo-Hhk6kGaHtOZ1M711l3vzY_3nC0VXKwjneZ13pR6F0o1QzCnA1HGSs5BvZny6515xa2Uj-SIfvhTG-Awe_xdRMXNbKQVw6xx8g',
                  profileImage: profileImage,
                ),

                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = (constraints.maxWidth / 180)
                                  .floor()
                                  .clamp(2, 8);
                              return GridView.count(
                                crossAxisCount: columns,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.1,
                                children: [
                                  ProfileMenuOption(
                                    icon: Icons.person_rounded,
                                    label: 'Editar Información Personal',
                                    iconColor: const Color(0xFF2B8CEE),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        AppPageRoute<void>(
                                          builder: (context) =>
                                              const EditPersonalInformationPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  ProfileMenuOption(
                                    icon: Icons.home_rounded,
                                    label: 'Administrar Casas Cuna',
                                    iconColor: const Color(0xFFEC5B13),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        AppPageRoute<void>(
                                          builder: (context) =>
                                              const FosterHomesManagementPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  ProfileMenuOption(
                                    icon: Icons.history_rounded,
                                    label: 'Revisar Historial de Rescates',
                                    iconColor: const Color(0xFFFF8C00),
                                    onTap: () {},
                                  ),
                                  ProfileMenuOption(
                                    icon: Icons.gavel_rounded,
                                    label: 'Consultar Mis Denuncias',
                                    iconColor: Colors.red,
                                    onTap: () {},
                                  ),
                                  ProfileMenuOption(
                                    icon: Icons.volunteer_activism_rounded,
                                    label: 'Seguir Mis Donaciones',
                                    iconColor: const Color(0xFF2B8CEE),
                                    onTap: () {},
                                  ),
                                  ProfileMenuOption(
                                    icon: Icons.shield_rounded,
                                    label: 'Ajustar Seguridad y Privacidad',
                                    iconColor: Colors.grey.shade500,
                                    onTap: () {},
                                  ),
                                  ProfileMenuOption(
                                    icon: Icons.payments_rounded,
                                    label: 'Gestionar Métodos de Pago',
                                    iconColor: const Color(0xFFFF8C00),
                                    onTap: () {},
                                  ),
                                  ProfileMenuOption(
                                    icon: Icons.support_agent_rounded,
                                    label: 'Obtener Ayuda y Soporte',
                                    iconColor: const Color(0xFFEC5B13),
                                    onTap: () {},
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await ref.read(authProvider.notifier).logout();
                                if (!context.mounted) {
                                  return;
                                }
                                ref
                                    .read(navigationProvider)
                                    .navigateAndRemoveAll(
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 100), // Space for bottom nav
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onBack != null)
            Positioned(
              top: 60,
              left: 24,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
