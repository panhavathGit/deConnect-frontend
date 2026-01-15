class FeedPost {
  final String id;
  final String content;
  final String userId;

  FeedPost({required this.id, required this.content, required this.userId});

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'],
      content: json['content'],
      userId: json['user_id'],
    );
  }
}