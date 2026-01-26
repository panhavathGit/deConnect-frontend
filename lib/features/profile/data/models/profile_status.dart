// lib/features/profile/data/models/profile_stats_model.dart
class ProfileStats {
  final int postsCount;

  ProfileStats({
    required this.postsCount,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      postsCount: json['posts_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts_count': postsCount,
    };
  }
}