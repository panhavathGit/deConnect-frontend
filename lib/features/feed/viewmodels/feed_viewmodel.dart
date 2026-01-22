import 'package:flutter/material.dart';
import '../data/mock_feed_repository.dart';
import '../data/feed_model.dart';

class FeedViewModel extends ChangeNotifier {
  final MockFeedRepository _repo = MockFeedRepository();
  List<FeedPost> _posts = [];
  bool _isLoading = true;

  List<FeedPost> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _posts = await _repo.fetchPosts();
    } catch (e) {
      debugPrint("Error loading feed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(String content) async {
    try {
      await _repo.createPost(content);
      await loadPosts(); // Reload posts after creating
    } catch (e) {
      debugPrint("Error creating post: $e");
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _repo.likePost(postId);
      // Update local state
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = FeedPost(
          id: post.id,
          content: post.content,
          userId: post.userId,
          username: post.username,
          createdAt: post.createdAt,
          likes: (post.likes ?? 0) + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error liking post: $e");
    }
  }
}