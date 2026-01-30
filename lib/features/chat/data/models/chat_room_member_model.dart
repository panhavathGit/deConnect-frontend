// lib/features/chat/data/models/chat_room_member_model.dart
class ChatRoomMember {
  final String id;
  final String roomId;
  final String userId;
  final DateTime joinedAt;
  final String? username;
  final String? avatarUrl;

  ChatRoomMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.joinedAt,
    this.username,
    this.avatarUrl,
  });

  factory ChatRoomMember.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    return ChatRoomMember(
      id: json['id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      joinedAt: DateTime.parse(json['joined_at']),
      username: profile?['username'],
      avatarUrl: profile?['avatar_url'],
    );
  }
}