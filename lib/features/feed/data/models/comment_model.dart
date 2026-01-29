// lib/features/feed/data/models/comment_model.dart
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // User profile info (from join)
  final String? authorName;
  final String? authorAvatar;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.authorName,
    this.authorAvatar,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Handle joined profile data
    final profile = json['profiles'];
    
    return CommentModel(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      authorName: profile != null ? profile['username'] : null,
      authorAvatar: profile != null ? profile['avatar_url'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Check if comment belongs to current user
  bool isOwnComment(String currentUserId) {
    return userId == currentUserId;
  }

  // Validation helper
  static String? validateContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return 'Comment cannot be empty';
    }
    if (content.trim().length > 1000) {
      return 'Comment must be 1000 characters or less';
    }
    return null;
  }
}