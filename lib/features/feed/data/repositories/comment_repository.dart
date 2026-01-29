import '../models/comment_model.dart';

abstract class CommentRepository {
  Future<List<CommentModel>> getCommentsByPostId(String postId);
  Future<CommentModel> createComment(String postId, String content);
  Future<void> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
}