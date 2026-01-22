import '../../../core/mock/mock_data.dart';
import 'feed_model.dart';

class MockFeedRepository {
  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<List<FeedPost>> fetchPosts() async {
    await _simulateDelay();
    
    // Convert mock posts to FeedPost objects
    return MockData.posts.map((post) => FeedPost.fromJson(post)).toList();
  }

  // Add a new post (just adds to local mock data)
  Future<void> createPost(String content) async {
    await _simulateDelay();
    
    final newPost = {
      'id': 'post-${DateTime.now().millisecondsSinceEpoch}',
      'content': content,
      'user_id': MockData.currentUser.id,
      'username': MockData.currentUser.username,
      'created_at': DateTime.now().toIso8601String(),
      'likes': 0,
    };
    
    MockData.posts.insert(0, newPost);
  }

  // Like a post
  Future<void> likePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final post = MockData.posts.firstWhere((p) => p['id'] == postId);
    post['likes'] = (post['likes'] as int) + 1;
  }
}
