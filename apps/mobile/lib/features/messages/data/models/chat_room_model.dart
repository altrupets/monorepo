import 'package:equatable/equatable.dart';

class ChatRoomModel extends Equatable {
  const ChatRoomModel({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.organizationAvatarUrl,
  });

  final String id;
  final String organizationId;
  final String organizationName;
  final String? organizationAvatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  factory ChatRoomModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatRoomModel(
      id: id,
      organizationId: data['organizationId'] as String? ?? '',
      organizationName: data['organizationName'] as String? ?? 'Unknown',
      organizationAvatarUrl: data['organizationAvatarUrl'] as String?,
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTime: data['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['lastMessageTime'] as int),
            )
          : DateTime.now(),
      unreadCount: data['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'organizationId': organizationId,
      'organizationName': organizationName,
      'organizationAvatarUrl': organizationAvatarUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'unreadCount': unreadCount,
    };
  }

  ChatRoomModel copyWith({
    String? id,
    String? organizationId,
    String? organizationName,
    String? organizationAvatarUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      organizationAvatarUrl:
          organizationAvatarUrl ?? this.organizationAvatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    organizationId,
    organizationName,
    organizationAvatarUrl,
    lastMessage,
    lastMessageTime,
    unreadCount,
  ];
}
