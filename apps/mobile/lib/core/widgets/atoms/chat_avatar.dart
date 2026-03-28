import 'dart:convert';
import 'package:flutter/material.dart';

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({this.avatarUrl, this.name, this.size = 40, super.key});

  final String? avatarUrl;
  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('data:')) {
        try {
          final base64String = avatarUrl!.split(',').last;
          final imageBytes = base64Decode(base64String);
          return CircleAvatar(
            radius: size / 2,
            backgroundImage: MemoryImage(imageBytes),
          );
        } catch (_) {
          return _buildInitialsAvatar(context);
        }
      } else {
        return CircleAvatar(
          radius: size / 2,
          backgroundImage: NetworkImage(avatarUrl!),
        );
      }
    }

    return _buildInitialsAvatar(context);
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _getInitials(name ?? '?');

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
