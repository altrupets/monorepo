import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/widgets/organisms/chat_room_list_item.dart';
import 'package:altrupets/features/messages/presentation/providers/messages_provider.dart';
import 'package:altrupets/features/messages/presentation/pages/chat_room_page.dart';
import 'package:altrupets/features/profile/presentation/providers/profile_provider.dart';

class MessagesPage extends ConsumerWidget {
  const MessagesPage({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatRoomsAsync = ref.watch(chatRoomsStreamProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mensajes',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        userAsync.when(
                          data: (user) => user != null
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      user.avatarBase64 != null &&
                                          user.avatarBase64!.isNotEmpty
                                      ? MemoryImage(
                                          base64Decode(user.avatarBase64!),
                                        )
                                      : null,
                                  child:
                                      user.avatarBase64 == null ||
                                          user.avatarBase64!.isEmpty
                                      ? Text(user.username[0].toUpperCase())
                                      : null,
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (_, _) => const Icon(Icons.error_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: chatRoomsAsync.when(
                data: (chatRooms) {
                  if (chatRooms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay chats grupales',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Únete a una organización para chatear',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: chatRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = chatRooms[index];
                      return ChatRoomListItem(
                        organizationName: chatRoom.organizationName,
                        organizationAvatarUrl: chatRoom.organizationAvatarUrl,
                        lastMessage: chatRoom.lastMessage.isEmpty
                            ? 'Sin mensajes'
                            : chatRoom.lastMessage,
                        lastMessageTime: chatRoom.lastMessageTime,
                        unreadCount: chatRoom.unreadCount,
                        onTap: () {
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => ChatRoomPage(
                                organizationId: chatRoom.organizationId,
                                organizationName: chatRoom.organizationName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar chats',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.refresh(chatRoomsStreamProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
