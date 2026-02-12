// lib/features/feed/data/datasources/comment_remote_data_source.dart
import '../../../../core/services/supabase_service.dart';
import '../models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getCommentsByPostId(String postId);
  Future<CommentModel> createComment(String postId, String content);
  Future<void> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final _supabase = SupabaseService.client;

  @override
  Future<List<CommentModel>> getCommentsByPostId(String postId) async {
    try {
      print('📝 Fetching comments for post: $postId');
      
      final response = await _supabase
          .from('comments')
          .select('''
            *,
            profiles:user_id (
              username,
              avatar_url
            )
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: false);

      print('✅ Fetched ${response.length} comments');

      return (response as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching comments: $e');
      throw Exception('Failed to fetch comments: $e');
    }
  }

  @override
  Future<CommentModel> createComment(String postId, String content) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('📝 Creating comment for post: $postId');

      // Validate content
      final validationError = CommentModel.validateContent(content);
      if (validationError != null) {
        throw Exception(validationError);
      }

      final response = await _supabase
          .from('comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'content': content.trim(),
          })
          .select('''
            *,
            profiles:user_id (
              username,
              avatar_url
            )
          ''')
          .single();

      print('✅ Comment created successfully');
      return CommentModel.fromJson(response);
    } catch (e) {
      print('❌ Error creating comment: $e');
      throw Exception('Failed to create comment: $e');
    }
  }

  @override
  Future<void> updateComment(String commentId, String content) async {
    try {
      print('📝 Updating comment: $commentId');

      // Validate content
      final validationError = CommentModel.validateContent(content);
      if (validationError != null) {
        throw Exception(validationError);
      }

      await _supabase
          .from('comments')
          .update({'content': content.trim()})
          .eq('id', commentId);

      print('✅ Comment updated successfully');
    } catch (e) {
      print('❌ Error updating comment: $e');
      throw Exception('Failed to update comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      print('📝 Deleting comment: $commentId');

      await _supabase
          .from('comments')
          .delete()
          .eq('id', commentId);

      print('✅ Comment deleted successfully');
    } catch (e) {
      print('❌ Error deleting comment: $e');
      throw Exception('Failed to delete comment: $e');
    }
  }
}