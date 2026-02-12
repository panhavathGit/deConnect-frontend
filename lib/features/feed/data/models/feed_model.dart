// // lib/features/feed/data/models/feed_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'feed_model.g.dart';

@JsonSerializable()
class FeedPost {
  @JsonKey(includeToJson: false)
  final String id;
  
  final String title;
  final String content;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  
  // These fields come from JOIN - read from JSON but don't write
  // We don't write mean we don't post to database because database does not have
  // author_name field, we use includeToJson flase to prevent error field not found
  @JsonKey(name: 'author_name', includeToJson: false)
  final String? authorName;
  
  @JsonKey(name: 'author_avatar', includeToJson: false)
  final String? authorAvatar;
  
  final List<String> tags;
  
  @JsonKey(name: 'created_at', includeToJson: false)
  final DateTime createdAt;

  const FeedPost({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    this.imageUrl,
    this.authorName,
    this.authorAvatar,
    this.tags = const [],
    required this.createdAt,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) => 
      _$FeedPostFromJson(json);

  Map<String, dynamic> toJson() => _$FeedPostToJson(this);

  String get primaryTag => tags.isNotEmpty ? tags.first : 'General';
}
