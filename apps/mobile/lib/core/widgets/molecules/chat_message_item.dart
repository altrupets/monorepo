import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:altrupets/core/widgets/atoms/chat_avatar.dart';
import 'package:altrupets/core/widgets/atoms/message_bubble.dart';

class ChatMessageItem extends StatelessWidget {
  const ChatMessageItem({
    required this.text,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.isSentByMe,
    required this.timestamp,
    this.deepLinkType,
    this.deepLinkId,
    super.key,
  });

  final String text;
  final String senderName;
  final String? senderAvatarUrl;
  final bool isSentByMe;
  final DateTime timestamp;
  final String? deepLinkType;
  final String? deepLinkId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: isSentByMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe) ...[
            ChatAvatar(avatarUrl: senderAvatarUrl, name: senderName, size: 36),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isSentByMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isSentByMe)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    senderName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              MessageBubble(
                text: text,
                isSentByMe: isSentByMe,
                deepLinkType: deepLinkType,
                deepLinkId: deepLinkId,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(timestamp),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
          if (isSentByMe) ...[
            const SizedBox(width: 8),
            ChatAvatar(avatarUrl: senderAvatarUrl, name: senderName, size: 36),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat.Hm().format(time);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Ayer ${DateFormat.Hm().format(time)}';
    } else {
      return DateFormat.MMMd().add_Hm().format(time);
    }
  }
}
