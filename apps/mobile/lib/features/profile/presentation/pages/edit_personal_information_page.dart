import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/providers/navigation_provider.dart';
import 'package:altrupets/core/widgets/atoms/app_role_badge.dart';
import 'package:altrupets/core/widgets/molecules/app_input_card.dart';
import 'package:altrupets/core/widgets/molecules/section_header.dart';
import 'package:altrupets/core/widgets/organisms/sticky_action_footer.dart';
import 'package:altrupets/core/widgets/organisms/profile_header.dart';

class EditPersonalInformationPage extends ConsumerWidget {
  const EditPersonalInformationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final navigation = ref.read(navigationProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Organism
                ProfileHeader(
                  title: 'Editar Información Personal',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCq_iWgFzHah59OBIvWrzkg3zd6Db9TdftdNUavNvy6VGk53MEnNpB2Iih6Zn7VNCtIYW3xgWSqBwgtVTJEeuPQLeVgaDdr2L0VYrQ4etjPIFC4N7CHHsUoqD4Zm3jDawc73XeGAXZVshhN0i86f_DYwoGCoCrrKFA5gQK_qu5Mi49vFS3OxGr0iQoW88L-C_AQ-1__z3EeRMigF4hGXVwEF7x8JZ3zxFTIyjuxjOT6BXSjoKuXF-IQAcDQwt6O7IN7YhLRQoIo78Y',
                  onBackTap: () => navigation.pop(context),
                  onCameraTap: () {},
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      // Section 1: Datos Personales
                      const SectionHeader(title: 'DATOS PERSONALES'),
                      const SizedBox(height: 16),
                      const AppInputCard(
                        label: 'NOMBRE',
                        initialValue: 'María',
                        hint: 'Tu nombre',
                      ),
                      const SizedBox(height: 12),
                      const AppInputCard(
                        label: 'APELLIDO',
                        initialValue: 'González',
                        hint: 'Tu apellido',
                      ),
                      const SizedBox(height: 12),
                      const AppInputCard(
                        label: 'TELÉFONO',
                        initialValue: '+506 8888-8888',
                        hint: 'Número',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      const AppInputCard(
                        label: 'CÉDULA',
                        initialValue: '1-2345-6789',
                        hint: 'ID',
                      ),

                      const SizedBox(height: 32),
                      // Section 2: Mis Roles
                      const SectionHeader(title: 'MIS ROLES'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const AppRoleBadge(label: 'Centinela', color: Color(0xFF2B8CEE)),
                          const AppRoleBadge(label: 'Auxiliar', color: Color(0xFFFF8C00)),
                          const AppRoleBadge(label: 'Rescatista', color: Colors.green),
                          const AppRoleBadge(label: 'Adoptante', color: Colors.purple),
                          _buildAddRoleButton(context),
                        ],
                      ),

                      const SizedBox(height: 32),
                      // Section 3: Residencia
                      const SectionHeader(title: 'RESIDENCIA'),
                      const SizedBox(height: 16),
                      const AppInputCard(
                        label: 'PAÍS',
                        initialValue: 'Costa Rica',
                        hint: 'Selecciona país',
                        enabled: false,
                        isDropdown: true,
                      ),
                      const SizedBox(height: 12),
                      const AppInputCard(
                        label: 'PROVINCIA',
                        initialValue: 'Heredia',
                        hint: 'Selecciona provincia',
                        isDropdown: true,
                      ),
                      const SizedBox(height: 12),
                      const AppInputCard(
                        label: 'CANTÓN',
                        initialValue: 'Heredia',
                        hint: 'Selecciona cantón',
                        isDropdown: true,
                      ),
                      const SizedBox(height: 12),
                      const AppInputCard(
                        label: 'DISTRITO',
                        initialValue: 'San Francisco',
                        hint: 'Selecciona distrito',
                        isDropdown: true,
                      ),
                      
                      const SizedBox(height: 120), // Space for sticky footer
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Sticky Footer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyActionFooter(
              onCancel: () => ref.read(navigationProvider).pop(context),
              onSave: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRoleButton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Icon(
        Icons.add_rounded,
        size: 18,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}
