// lib/features/chat/data/models/message_model.dart
class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String? mediaUrl;
  final bool isRead;
  final DateTime createdAt;
  final String status; // 'sending', 'sent', 'delivered', 'read', 'failed'
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final String? replyToId;
  
  // From joined profiles
  final String? senderName;
  final String? senderAvatar;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    this.mediaUrl,
    required this.isRead,
    required this.createdAt,
    this.status = 'sent',
    this.editedAt,
    this.deletedAt,
    this.replyToId,
    this.senderName,
    this.senderAvatar,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    return ChatMessage(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      content: json['content'],
      mediaUrl: json['media_url'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'sent',
      editedAt: json['edited_at'] != null ? DateTime.parse(json['edited_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      replyToId: json['reply_to_id'],
      senderName: profile?['username'],
      senderAvatar: profile?['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'media_url': mediaUrl,
      'status': status,
      'reply_to_id': replyToId,
    };
  }

  bool get isDeleted => deletedAt != null;
  bool get isEdited => editedAt != null;
}