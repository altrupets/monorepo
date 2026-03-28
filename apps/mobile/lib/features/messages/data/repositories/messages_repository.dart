import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:altrupets/features/messages/data/models/message_model.dart';
import 'package:altrupets/features/messages/data/models/chat_room_model.dart';

class MessagesRepository {
  MessagesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _chatsCollection = 'chats';
  static const String _chatRoomsCollection = 'chat_rooms';

  Stream<List<MessageModel>> getMessagesStream(String organizationId) {
    return _firestore
        .collection(_chatsCollection)
        .doc(organizationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  Future<void> sendMessage({
    required String organizationId,
    required String text,
    required String senderId,
    required String senderName,
    String? senderAvatarUrl,
    String? deepLinkType,
    String? deepLinkId,
  }) async {
    final messageRef = _firestore
        .collection(_chatsCollection)
        .doc(organizationId)
        .collection('messages')
        .doc();

    final message = MessageModel(
      id: messageRef.id,
      text: text,
      senderId: senderId,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      organizationId: organizationId,
      createdAt: DateTime.now(),
      deepLinkType: deepLinkType,
      deepLinkId: deepLinkId,
    );

    await messageRef.set(message.toFirestore());

    await _updateChatRoomLastMessage(
      organizationId: organizationId,
      lastMessage: text,
      lastMessageTime: DateTime.now(),
    );
  }

  Stream<List<ChatRoomModel>> getChatRoomsStream(String userId) {
    return _firestore
        .collection(_chatRoomsCollection)
        .where('memberIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatRoomModel.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  Future<void> createChatRoom({
    required String organizationId,
    required String organizationName,
    required List<String> memberIds,
    String? organizationAvatarUrl,
  }) async {
    final chatRoomRef = _firestore
        .collection(_chatRoomsCollection)
        .doc(organizationId);

    final existingDoc = await chatRoomRef.get();
    if (!existingDoc.exists) {
      await chatRoomRef.set({
        'organizationId': organizationId,
        'organizationName': organizationName,
        'organizationAvatarUrl': organizationAvatarUrl,
        'memberIds': memberIds,
        'lastMessage': '',
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'unreadCount': 0,
      });
    }
  }

  Future<void> _updateChatRoomLastMessage({
    required String organizationId,
    required String lastMessage,
    required DateTime lastMessageTime,
  }) async {
    await _firestore
        .collection(_chatRoomsCollection)
        .doc(organizationId)
        .update({
          'lastMessage': lastMessage,
          'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
        });
  }

  Future<void> markMessagesAsRead(String organizationId, String userId) async {
    await _firestore
        .collection(_chatRoomsCollection)
        .doc(organizationId)
        .update({'unreadCount': 0});
  }

  Future<ChatRoomModel?> getChatRoom(String organizationId) async {
    final doc = await _firestore
        .collection(_chatRoomsCollection)
        .doc(organizationId)
        .get();

    if (doc.exists) {
      return ChatRoomModel.fromFirestore(doc.id, doc.data()!);
    }
    return null;
  }
}
