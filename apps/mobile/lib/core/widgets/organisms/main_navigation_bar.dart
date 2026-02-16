import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/molecules/app_nav_item.dart';
import 'package:altrupets/core/widgets/molecules/home_navigation_button.dart';

class MainNavigationBar extends StatelessWidget {
  const MainNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      height: 80 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? theme.colorScheme.surface : Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
      ),
      child: SafeArea(
        left: true,
        right: true,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppNavItem(
              icon: Icons.groups_rounded,
              label: 'Comunidad',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            AppNavItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Mensajes',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _buildCenterHome(context),
            AppNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Perfil',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            AppNavItem(
              icon: Icons.settings_rounded,
              label: 'Ajustes',
              isSelected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterHome(BuildContext context) {
    return HomeNavigationButton(
      onTap: () => onTap(2),
    );
  }
}
