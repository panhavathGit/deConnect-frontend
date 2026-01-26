// lib/features/feed/data/feed_model.dart
class FeedPost {
  final String id;
  final String title;
  final String content;
  final String userId;
  final String? imageUrl;
  final String authorName;
  final String? authorAvatar;
  final int commentCount;
  final String category;
  final DateTime createdAt;

  FeedPost({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    this.imageUrl,
    required this.authorName,
    this.authorAvatar,
    required this.commentCount,
    required this.category,
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
      commentCount: json['comment_count'] ?? 0,
      category: json['category'] ?? 'General',
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
      'comment_count': commentCount,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}