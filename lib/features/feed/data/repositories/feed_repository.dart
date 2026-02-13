import 'dart:io';
import '../models/feed_model.dart';

abstract class FeedRepository {
  // Future<List<FeedPost>> getPosts({String? category});
  Future<List<FeedPost>> getPosts({
    String? category, 
    int offset = 0, 
    int limit = 10,
  });

  Future<FeedPost> getPostById(String id);
  Future<void> createPost(FeedPost post);
  Future<void> updatePost(FeedPost post);
  Future<void> deletePost(String id);
  Future<String> uploadPostImage(File image, String userId);
}