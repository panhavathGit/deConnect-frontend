class FeedPost {
  final String id;
  final String content;
  final String userId;
  final String? username;
  final String? createdAt;
  final int? likes;

  FeedPost({
    required this.id,
    required this.content,
    required this.userId,
    this.username,
    this.createdAt,
    this.likes,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'],
      content: json['content'],
      userId: json['user_id'],
      username: json['username'],
      createdAt: json['created_at'],
      likes: json['likes'],
    );
  }
}