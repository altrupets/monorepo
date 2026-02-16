import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/atoms/app_role_badge.dart';

class ProfileMainHeader extends StatelessWidget {
  const ProfileMainHeader({
    required this.name,
    required this.location,
    required this.role,
    required this.imageUrl,
    this.profileImage,
    super.key,
  });

  final String name;
  final String location;
  final String role;
  final String imageUrl;
  final ImageProvider<Object>? profileImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, bottom: 24, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFEC5B13).withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFEC5B13),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 64,
              backgroundImage: profileImage ?? NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Role Badge (Atom)
          AppRoleBadge(
            label: role.toUpperCase(),
            color: const Color(0xFFEC5B13),
          ),
        ],
      ),
    );
  }
}
