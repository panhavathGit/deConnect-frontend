// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedPost _$FeedPostFromJson(Map<String, dynamic> json) => FeedPost(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  userId: json['user_id'] as String,
  imageUrl: json['image_url'] as String?,
  authorName: json['author_name'] as String?,
  authorAvatar: json['author_avatar'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$FeedPostToJson(FeedPost instance) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'user_id': instance.userId,
  'image_url': instance.imageUrl,
  'tags': instance.tags,
};
