// lib/features/feed/presentation/viewmodels/comment_viewmodel.dart
import 'package:flutter/material.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart';

enum CommentStatus { initial, loading, success, error }

class CommentViewModel extends ChangeNotifier {
  final CommentRepository repository;
  final String postId;

  
  CommentViewModel({
    required this.repository,
    required this.postId,
  });

  List<CommentModel> _comments = [];
  CommentStatus _status = CommentStatus.initial;
  String? _errorMessage;
  bool _isSubmitting = false;

  // Getters
  List<CommentModel> get comments => _comments;
  CommentStatus get status => _status;
  bool get isLoading => _status == CommentStatus.loading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int get commentCount => _comments.length;

  // Load comments for the post
  Future<void> loadComments() async {
    _status = CommentStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await repository.getCommentsByPostId(postId);
      _status = CommentStatus.success;
    } catch (e) {
      _status = CommentStatus.error;
      _errorMessage = 'Failed to load comments: ${e.toString()}';
      _comments = [];
      debugPrint("❌ Error loading comments: $e");
    }

    notifyListeners();
  }

  // Add a new comment
  Future<bool> addComment(String content) async {
    // Validate content
    final validationError = CommentModel.validateContent(content);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newComment = await repository.createComment(postId, content);
      
      // Add to the beginning of the list
      _comments.insert(0, newComment);
      _isSubmitting = false;
      notifyListeners();
      
      debugPrint("✅ Comment added successfully");
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = 'Failed to add comment: ${e.toString()}';
      notifyListeners();
      
      debugPrint("❌ Error adding comment: $e");
      return false;
    }
  }

  // Update a comment
  Future<bool> updateComment(String commentId, String content) async {
    // Validate content
    final validationError = CommentModel.validateContent(content);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.updateComment(commentId, content);
      
      // Update the comment in the list
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final oldComment = _comments[index];
        _comments[index] = CommentModel(
          id: oldComment.id,
          postId: oldComment.postId,
          userId: oldComment.userId,
          content: content,
          authorName: oldComment.authorName,
          authorAvatar: oldComment.authorAvatar,
          createdAt: oldComment.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      
      _isSubmitting = false;
      notifyListeners();
      
      debugPrint("✅ Comment updated successfully");
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = 'Failed to update comment: ${e.toString()}';
      notifyListeners();
      
      debugPrint("❌ Error updating comment: $e");
      return false;
    }
  }

  // Delete a comment
  Future<bool> deleteComment(String commentId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteComment(commentId);
      
      // Remove from the list
      _comments.removeWhere((c) => c.id == commentId);
      
      _isSubmitting = false;
      notifyListeners();
      
      debugPrint("✅ Comment deleted successfully");
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = 'Failed to delete comment: ${e.toString()}';
      notifyListeners();
      
      debugPrint("❌ Error deleting comment: $e");
      return false;
    }
  }

  // Check if comment belongs to current user
  bool isOwnComment(CommentModel comment, String currentUserId) {
    return comment.isOwnComment(currentUserId);
  }
}