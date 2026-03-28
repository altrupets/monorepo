import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.text,
    required this.isSentByMe,
    this.deepLinkType,
    this.deepLinkId,
    super.key,
  });

  final String text;
  final bool isSentByMe;
  final String? deepLinkType;
  final String? deepLinkId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isSentByMe
        ? theme.colorScheme.primary
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade200);

    final textColor = isSentByMe
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isSentByMe ? 20 : 4),
          bottomRight: Radius.circular(isSentByMe ? 4 : 20),
        ),
      ),
      child: Column(
        crossAxisAlignment: isSentByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(text, style: TextStyle(color: textColor, fontSize: 15)),
          if (deepLinkType != null && deepLinkId != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? Colors.white.withValues(alpha: 0.2)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    deepLinkType == 'capture_request'
                        ? Icons.camera_alt
                        : Icons.pets,
                    size: 14,
                    color: isSentByMe
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    deepLinkType == 'capture_request'
                        ? 'Solicitud de captura'
                        : 'Rescate',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSentByMe
                          ? Colors.white
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
