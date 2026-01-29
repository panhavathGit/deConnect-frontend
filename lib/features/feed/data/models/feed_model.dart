// lib/features/feed/data/models/feed_model.dart
class FeedPost {
  final String id;
  final String title;
  final String content;
  final String userId;
  final String? imageUrl;
  final String authorName;
  final String? authorAvatar;
  final List<String> tags;  // Changed from category
  final DateTime createdAt;

  FeedPost({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    this.imageUrl,
    required this.authorName,
    this.authorAvatar,
    this.tags = const [],  // Changed from category and commentCount
    required this.createdAt,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      userId: json['user_id'],
      imageUrl: json['image_url'],
      authorName: json['author_name'] ?? 'Unknown',
      authorAvatar: json['author_avatar'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user_id': userId,
      'image_url': imageUrl,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper to get first tag or default
  String get primaryTag => tags.isNotEmpty ? tags.first : 'General';
}