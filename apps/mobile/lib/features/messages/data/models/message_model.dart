import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  const MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.organizationId,
    required this.createdAt,
    this.deepLinkType,
    this.deepLinkId,
  });

  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String organizationId;
  final DateTime createdAt;
  final String? deepLinkType;
  final String? deepLinkId;

  factory MessageModel.fromFirestore(String id, Map<String, dynamic> data) {
    return MessageModel(
      id: id,
      text: data['text'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Unknown',
      senderAvatarUrl: data['senderAvatarUrl'] as String?,
      organizationId: data['organizationId'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((data['createdAt'] as int))
          : DateTime.now(),
      deepLinkType: data['deepLinkType'] as String?,
      deepLinkId: data['deepLinkId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'organizationId': organizationId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'deepLinkType': deepLinkType,
      'deepLinkId': deepLinkId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    text,
    senderId,
    senderName,
    senderAvatarUrl,
    organizationId,
    createdAt,
    deepLinkType,
    deepLinkId,
  ];
}
