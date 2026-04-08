import 'package:flutter/material.dart';
import '../theme/altrupets_tokens.dart';

/// Empty state placeholder widget.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AltruPetsTokens.textSecondary),
          const SizedBox(height: AltruPetsTokens.spacing12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AltruPetsTokens.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AltruPetsTokens.spacing4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AltruPetsTokens.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
