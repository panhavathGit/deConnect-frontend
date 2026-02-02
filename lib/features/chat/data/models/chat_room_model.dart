// lib/features/chat/data/models/chat_room_model.dart

class ChatRoom {
  final String id;
  final String name;
  final bool isGroup;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? inviteCode;
  final int? maxMembers;
  final bool inviteLinkEnabled;
  final DateTime? inviteExpiresAt;
  final String? otherUserName;
  final String? otherUserAvatar;
  // NEW: For last seen
  final String? otherUserId;
  final DateTime? otherUserLastSeen;
  final bool otherUserIsOnline;

  ChatRoom({
    required this.id,
    required this.name,
    required this.isGroup,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.inviteCode,
    this.maxMembers,
    this.inviteLinkEnabled = true,
    this.inviteExpiresAt,
    this.otherUserName,
    this.otherUserAvatar,
    this.otherUserId,
    this.otherUserLastSeen,
    this.otherUserIsOnline = false,
  });

  // Add these getters for display
  String get displayName => otherUserName ?? name;
  String? get displayAvatar => otherUserAvatar ?? avatarUrl;

  // Format last seen like Telegram
  String get lastSeenText {
    if (otherUserIsOnline) return 'online';
    if (otherUserLastSeen == null) return '';
    
    final now = DateTime.now();
    final diff = now.difference(otherUserLastSeen!);
    
    if (diff.inMinutes < 1) return 'last seen just now';
    if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'last seen ${diff.inHours}h ago';
    if (diff.inDays == 1) return 'last seen yesterday';
    if (diff.inDays < 7) return 'last seen ${diff.inDays}d ago';
    return 'last seen recently';
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'] ?? 'Chat',
      isGroup: json['is_group'] ?? false,
      avatarUrl: json['avatar_url'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      createdBy: json['created_by'],
      inviteCode: json['invite_code'],
      maxMembers: json['max_members'],
      inviteLinkEnabled: json['invite_link_enabled'] ?? true,
      inviteExpiresAt: json['invite_expires_at'] != null
          ? DateTime.parse(json['invite_expires_at'])
          : null,
      otherUserName: json['other_user_name'],
      otherUserAvatar: json['other_user_avatar'],
      otherUserId: json['other_user_id'],
      otherUserLastSeen: json['other_user_last_seen'] != null
          ? DateTime.parse(json['other_user_last_seen'])
          : null,
      otherUserIsOnline: json['other_user_is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_group': isGroup,
      'avatar_url': avatarUrl,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'invite_code': inviteCode,
      'max_members': maxMembers,
      'invite_link_enabled': inviteLinkEnabled,
      'invite_expires_at': inviteExpiresAt?.toIso8601String(),
    };
  }
}
