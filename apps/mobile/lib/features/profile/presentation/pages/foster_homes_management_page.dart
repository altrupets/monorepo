import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/providers/navigation_provider.dart';
import 'package:altrupets/core/widgets/molecules/foster_home_header_card.dart';
import 'package:altrupets/core/widgets/molecules/foster_homes_management_card_button.dart';
import 'package:altrupets/core/widgets/molecules/section_header.dart';

class FosterHomesManagementPage extends ConsumerWidget {
  const FosterHomesManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final navigation = ref.read(navigationProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Gestión de Casa Cuna',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => navigation.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const FosterHomeHeaderCard(
              name: 'Hogar de Doña María',
              location: 'Heredia, Costa Rica',
            ),
            
            const SizedBox(height: 32),
            
            // Section 1: Activos
            const SectionHeader(
              title: 'GESTIONAR ACTIVOS',
              color: Color(0xFF3B82F6),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                FosterHomesManagementCardButton(emoji: '🥩', label: 'Alimentos', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '💊', label: 'Botiquín', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🏠', label: 'Mobiliario', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🧹', label: 'Limpieza y Aseo', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🧼', label: 'Higiene Animal', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🛏', label: 'Ropa de Cama', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🥣', label: 'Utensilios', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🎾', label: 'Juguetes', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🚗', label: 'Transporte', onTap: () {}),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Section 2: Pasivos
            const SectionHeader(
              title: 'GESTIONAR PASIVOS',
              color: Color(0xFFF97316),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                FosterHomesManagementCardButton(emoji: '⚡', label: 'Servicios Públicos', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🚛', label: 'Gastos de Logística', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🛒', label: 'Compras de Activos', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🏛️', label: 'Impuestos', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '🩺', label: 'Veterinaria', onTap: () {}),
                FosterHomesManagementCardButton(emoji: '✂️', label: 'Estéticos', onTap: () {}),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
