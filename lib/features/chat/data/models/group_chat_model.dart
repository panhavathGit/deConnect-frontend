// lib/features/chat/data/models/group_chat_model.dart

class GroupChat {
  final String roomId;
  final String roomName;
  final String? description;
  final String? avatarUrl;
  final String inviteCode;
  final int memberCount;
  final bool isAdmin;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  GroupChat({
    required this.roomId,
    required this.roomName,
    this.description,
    this.avatarUrl,
    required this.inviteCode,
    required this.memberCount,
    required this.isAdmin,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      roomId: json['room_id'],
      roomName: json['room_name'] ?? 'Group',
      description: json['description'],
      avatarUrl: json['avatar_url'],
      inviteCode: json['invite_code'] ?? '',
      memberCount: json['member_count'] ?? 0,
      isAdmin: json['is_admin'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class CreateGroupResponse {
  final String roomId;
  final String inviteCode;

  CreateGroupResponse({
    required this.roomId,
    required this.inviteCode,
  });

  factory CreateGroupResponse.fromJson(Map<String, dynamic> json) {
    return CreateGroupResponse(
      roomId: json['room_id'],
      inviteCode: json['invite_code'],
    );
  }
}

class JoinGroupResponse {
  final bool success;
  final String? roomId;
  final String? roomName;
  final String message;

  JoinGroupResponse({
    required this.success,
    this.roomId,
    this.roomName,
    required this.message,
  });

  factory JoinGroupResponse.fromJson(Map<String, dynamic> json) {
    return JoinGroupResponse(
      success: json['success'] ?? false,
      roomId: json['room_id'],
      roomName: json['room_name'],
      message: json['message'] ?? '',
    );
  }
}