// lib/features/feed/data/datasources/comment_mock_data_source.dart
import '../models/comment_model.dart';

abstract class CommentMockDataSource {
  Future<List<CommentModel>> getCommentsByPostId(String postId);
  Future<CommentModel> createComment(String postId, String content);
  Future<void> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
}

class CommentMockDataSourceImpl implements CommentMockDataSource {
  // Mock data storage
  static final List<CommentModel> _mockComments = [
    CommentModel(
      id: 'comment1',
      postId: '1',
      userId: 'user2',
      content: 'Great post! I visited Phnom Penh last year and it was amazing.',
      authorName: 'John Doe',
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
    ),
    CommentModel(
      id: 'comment2',
      postId: '1',
      userId: 'user3',
      content: 'Thanks for sharing this. Very informative!',
      authorName: 'Sarah Smith',
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
    ),
    CommentModel(
      id: 'comment3',
      postId: '1',
      userId: 'user4',
      content: 'I agree! The city has so much to offer. Can\'t wait to go back.',
      authorName: 'Mike Johnson',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    CommentModel(
      id: 'comment4',
      postId: '2',
      userId: 'user5',
      content: 'These restaurants look amazing! Adding to my bucket list.',
      authorName: 'Emily Chen',
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
    ),
    CommentModel(
      id: 'comment5',
      postId: '2',
      userId: 'user6',
      content: 'Have you tried the fish amok? It\'s my favorite Khmer dish!',
      authorName: 'David Wong',
      createdAt: DateTime.now().subtract(Duration(hours: 8)),
    ),
  ];

  @override
  Future<List<CommentModel>> getCommentsByPostId(String postId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    return _mockComments
        .where((comment) => comment.postId == postId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<CommentModel> createComment(String postId, String content) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));

    // Validate content
    final validationError = CommentModel.validateContent(content);
    if (validationError != null) {
      throw Exception(validationError);
    }

    final newComment = CommentModel(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: 'current_user',
      content: content.trim(),
      authorName: 'You',
      createdAt: DateTime.now(),
    );

    _mockComments.insert(0, newComment);
    return newComment;
  }

  @override
  Future<void> updateComment(String commentId, String content) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));

    // Validate content
    final validationError = CommentModel.validateContent(content);
    if (validationError != null) {
      throw Exception(validationError);
    }

    final index = _mockComments.indexWhere((c) => c.id == commentId);
    if (index == -1) {
      throw Exception('Comment not found');
    }

    final oldComment = _mockComments[index];
    _mockComments[index] = CommentModel(
      id: oldComment.id,
      postId: oldComment.postId,
      userId: oldComment.userId,
      content: content.trim(),
      authorName: oldComment.authorName,
      authorAvatar: oldComment.authorAvatar,
      createdAt: oldComment.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteComment(String commentId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));

    _mockComments.removeWhere((comment) => comment.id == commentId);
  }
}