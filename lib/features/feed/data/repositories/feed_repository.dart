import '../models/feed_model.dart';

abstract class FeedRepository {
  Future<List<FeedPost>> getPosts({String? category});
  Future<FeedPost> getPostById(String id);
  Future<void> createPost(FeedPost post);
  Future<void> updatePost(FeedPost post);
  Future<void> deletePost(String id);
}