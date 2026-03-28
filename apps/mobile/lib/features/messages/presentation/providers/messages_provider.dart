import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/features/messages/data/models/message_model.dart';
import 'package:altrupets/features/messages/data/models/chat_room_model.dart';
import 'package:altrupets/features/messages/data/repositories/messages_repository.dart';
import 'package:altrupets/features/profile/presentation/providers/profile_provider.dart';
import 'package:altrupets/features/auth/domain/entities/user.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepository();
});

final chatRoomsStreamProvider = StreamProvider<List<ChatRoomModel>>((ref) {
  final repository = ref.watch(messagesRepositoryProvider);
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]);
      }
      return repository.getChatRoomsStream(user.id);
    },
    loading: () => Stream.value([]),
    error: (_, _) => Stream.value([]),
  );
});

final messagesStreamProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, organizationId) {
      final repository = ref.watch(messagesRepositoryProvider);
      return repository.getMessagesStream(organizationId);
    });

final sendMessageProvider =
    Provider<
      Future<void> Function({
        required String organizationId,
        required String text,
        String? deepLinkType,
        String? deepLinkId,
      })
    >((ref) {
      return ({
        required String organizationId,
        required String text,
        String? deepLinkType,
        String? deepLinkId,
      }) async {
        final repository = ref.read(messagesRepositoryProvider);
        final userAsync = ref.read(currentUserProvider);
        final user = userAsync.whenData((u) => u).value;

        if (user == null) {
          throw Exception('User not authenticated');
        }

        final displayName = _getDisplayName(user);

        await repository.sendMessage(
          organizationId: organizationId,
          text: text,
          senderId: user.id,
          senderName: displayName,
          senderAvatarUrl: user.avatarBase64,
          deepLinkType: deepLinkType,
          deepLinkId: deepLinkId,
        );
      };
    });

final createChatRoomProvider =
    Provider<
      Future<void> Function({
        required String organizationId,
        required String organizationName,
        String? organizationAvatarUrl,
      })
    >((ref) {
      return ({
        required String organizationId,
        required String organizationName,
        String? organizationAvatarUrl,
      }) async {
        final repository = ref.read(messagesRepositoryProvider);
        final userAsync = ref.read(currentUserProvider);
        final user = userAsync.whenData((u) => u).value;

        if (user == null) {
          throw Exception('User not authenticated');
        }

        await repository.createChatRoom(
          organizationId: organizationId,
          organizationName: organizationName,
          organizationAvatarUrl: organizationAvatarUrl,
          memberIds: [user.id],
        );
      };
    });

final markMessagesAsReadProvider = Provider<Future<void> Function(String)>((
  ref,
) {
  return (String organizationId) async {
    try {
      final repository = ref.read(messagesRepositoryProvider);
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.whenData((u) => u).value;

      if (user == null) return;

      await repository.markMessagesAsRead(organizationId, user.id);
    } catch (_) {}
  };
});

String _getDisplayName(User user) {
  final firstName = user.firstName?.trim() ?? '';
  final lastName = user.lastName?.trim() ?? '';
  if (firstName.isNotEmpty || lastName.isNotEmpty) {
    return '$firstName $lastName'.trim();
  }
  return user.username;
}
