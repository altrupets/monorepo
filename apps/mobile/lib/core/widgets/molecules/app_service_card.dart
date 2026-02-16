import 'package:flutter/material.dart';

class AppServiceCard extends StatelessWidget {
  const AppServiceCard({
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: const BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: -0.2,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
