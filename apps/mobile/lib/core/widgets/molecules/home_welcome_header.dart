import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/atoms/app_circular_button.dart';

class HomeWelcomeHeader extends StatelessWidget {
  const HomeWelcomeHeader({
    required this.onNotificationTap,
    super.key,
  });

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 32.0,
        bottom: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '¿Cómo podemos ayudarte hoy?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
          AppCircularButton(
            icon: Icons.notifications_none,
            onTap: onNotificationTap,
            size: 44,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            iconSize: 24,
          ),
        ],
      ),
    );
  }
}
