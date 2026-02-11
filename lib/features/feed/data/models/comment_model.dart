// lib/features/feed/data/models/comment_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  @JsonKey(includeToJson: false)  // Don't send ID
  final String id;
  
  @JsonKey(name: 'post_id')
  final String postId;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  final String content;
  
  @JsonKey(name: 'created_at', includeToJson: false)  // Auto-generated
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at', includeToJson: false)  // Auto-generated
  final DateTime? updatedAt;
  
  // User profile info (from join) - ignore in serialization
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? authorName;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? authorAvatar;

  const CommentModel({
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
    // Handle joined profile data manually
    final profile = json['profiles'];
    final comment = _$CommentModelFromJson(json);
    
    // Return new instance with profile data
    return CommentModel(
      id: comment.id,
      postId: comment.postId,
      userId: comment.userId,
      content: comment.content,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      authorName: profile?['username'],
      authorAvatar: profile?['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
  
  bool isOwnComment(String currentUserId) {
    return userId == currentUserId;
  }

  static String? validateContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return 'Comment content cannot be empty';
    }
    
    if (content.trim().length < 1) {
      return 'Comment must have at least 1 character';
    }
    
    if (content.trim().length > 500) {
      return 'Comment cannot exceed 500 characters';
    }
    
    return null; // Valid
  }


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

}