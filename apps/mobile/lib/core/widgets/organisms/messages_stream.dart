import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/molecules/chat_message_item.dart';
import 'package:altrupets/features/messages/data/models/message_model.dart';

class MessagesStream extends StatelessWidget {
  const MessagesStream({
    required this.messages,
    required this.currentUserId,
    required this.onDeepLinkTap,
    super.key,
  });

  final List<MessageModel> messages;
  final String currentUserId;
  final void Function(String deepLinkType, String deepLinkId)? onDeepLinkTap;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
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
              'No hay mensajes aún',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Sé el primero en enviar un mensaje',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isSentByMe = message.senderId == currentUserId;

        return GestureDetector(
          onLongPress:
              message.deepLinkType != null && message.deepLinkId != null
              ? () {
                  if (onDeepLinkTap != null &&
                      message.deepLinkType != null &&
                      message.deepLinkId != null) {
                    onDeepLinkTap!(message.deepLinkType!, message.deepLinkId!);
                  }
                }
              : null,
          child: ChatMessageItem(
            text: message.text,
            senderName: message.senderName,
            senderAvatarUrl: message.senderAvatarUrl,
            isSentByMe: isSentByMe,
            timestamp: message.createdAt,
            deepLinkType: message.deepLinkType,
            deepLinkId: message.deepLinkId,
          ),
        );
      },
    );
  }
}
