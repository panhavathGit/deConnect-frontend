// lib/features/feed/data/datasources/feed_remote_data_source.dart
import '../../../../core/services/supabase_service.dart';
import '../models/feed_model.dart';

abstract class FeedRemoteDataSource {
  Future<List<FeedPost>> getPosts({String? category});
  Future<FeedPost> getPostById(String id);
  Future<void> createPost(FeedPost post);
  Future<void> updatePost(FeedPost post);
  Future<void> deletePost(String id);
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final _supabase = SupabaseService.client;

  @override
  Future<List<FeedPost>> getPosts({String? category}) async {
    try {
      final query = _supabase.from('posts').select();
      
      final filteredQuery = (category != null && category != 'All')
          ? query.eq('category', category)
          : query;
      
      final response = await filteredQuery.order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => FeedPost.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  @override
  Future<FeedPost> getPostById(String id) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('id', id)
          .single();
      
      return FeedPost.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch post: $e');
    }
  }

  @override
  Future<void> createPost(FeedPost post) async {
    try {
      await _supabase.from('posts').insert(post.toJson());
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<void> updatePost(FeedPost post) async {
    try {
      await _supabase
          .from('posts')
          .update(post.toJson())
          .eq('id', post.id);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      await _supabase.from('posts').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}