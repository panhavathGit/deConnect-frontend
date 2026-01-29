// lib/features/feed/data/repositories/comment_repository_impl.dart
import '../datasources/comment_remote_data_source.dart';
import '../datasources/comment_mock_data_source.dart';
import '../models/comment_model.dart';
import './comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource? remoteDataSource;
  final CommentMockDataSource? mockDataSource;
  final bool useMockData;

  CommentRepositoryImpl({
    this.remoteDataSource,
    this.mockDataSource,
    this.useMockData = false, // Set to true for testing without backend
  });

  @override
  Future<List<CommentModel>> getCommentsByPostId(String postId) async {
    if (useMockData) {
      return await mockDataSource!.getCommentsByPostId(postId);
    } else {
      return await remoteDataSource!.getCommentsByPostId(postId);
    }
  }

  @override
  Future<CommentModel> createComment(String postId, String content) async {
    if (useMockData) {
      return await mockDataSource!.createComment(postId, content);
    } else {
      return await remoteDataSource!.createComment(postId, content);
    }
  }

  @override
  Future<void> updateComment(String commentId, String content) async {
    if (useMockData) {
      await mockDataSource!.updateComment(commentId, content);
    } else {
      await remoteDataSource!.updateComment(commentId, content);
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    if (useMockData) {
      await mockDataSource!.deleteComment(commentId);
    } else {
      await remoteDataSource!.deleteComment(commentId);
    }
  }
}