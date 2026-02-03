// lib/features/chat/data/models/group_member_model.dart
class GroupMember {
  final String userId;
  final String username;
  final String? avatarUrl;
  final bool isAdmin;
  final DateTime joinedAt;

  GroupMember({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.isAdmin,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['user_id'],
      username: json['username'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      isAdmin: json['is_admin'] ?? false,
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }
}