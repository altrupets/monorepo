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
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 20.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenido',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '¿Cómo podemos ayudarte hoy?',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
            ],
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
