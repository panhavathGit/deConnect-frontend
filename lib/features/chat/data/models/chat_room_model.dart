// lib/features/chat/data/models/chat_room_model.dart
class ChatRoom {
  final String id;
  final String? name;
  final bool isGroup;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? inviteCode;
  final int? maxMembers;
  final bool inviteLinkEnabled;
  final DateTime? inviteExpiresAt;
  
  // Additional fields from joined data
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatRoom({
    required this.id,
    this.name,
    required this.isGroup,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.inviteCode,
    this.maxMembers,
    required this.inviteLinkEnabled,
    this.inviteExpiresAt,
    this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      isGroup: json['is_group'] ?? false,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      inviteCode: json['invite_code'],
      maxMembers: json['max_members'],
      inviteLinkEnabled: json['invite_link_enabled'] ?? true,
      inviteExpiresAt: json['invite_expires_at'] != null
          ? DateTime.parse(json['invite_expires_at'])
          : null,
      otherUserName: json['other_user_name'],
      otherUserAvatar: json['other_user_avatar'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  String get displayName {
    if (isGroup) return name ?? 'Group Chat';
    return otherUserName ?? 'Unknown User';
  }

  String get displayAvatar => otherUserAvatar ?? '';
}