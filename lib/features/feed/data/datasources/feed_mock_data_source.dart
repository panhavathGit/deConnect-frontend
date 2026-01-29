// lib/features/feed/data/datasources/feed_mock_data_source.dart
import '../models/feed_model.dart';

abstract class FeedMockDataSource {
  Future<List<FeedPost>> getPosts({String? category});
  Future<FeedPost> getPostById(String id);
}

class FeedMockDataSourceImpl implements FeedMockDataSource {
  // Mock data for development
  static final List<FeedPost> _mockPosts = [
    FeedPost(
      id: '1',
      title: 'The best place to visit in Phnom Penh',
      content: 'Phnom Penh, Cambodia\'s busy capital, sits at the junction of the Mekong and Tonlé Sap rivers. It was a hub for both the Khmer Empire and French colonialists. The city is known for its beautiful architecture and rich history that draws visitors from around the world.',
      userId: 'user1',
      imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=800',
      authorName: 'Alice Jane',
      tags: ['Technologies', 'Travel'],
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
    ),
    FeedPost(
      id: '2',
      title: 'Top 10 Restaurants in Siem Reap',
      content: 'Siem Reap is not just about temples. The city has an incredible food scene with both traditional Khmer cuisine and international restaurants. Here are my top picks for dining in this amazing city that will tantalize your taste buds.',
      userId: 'user2',
      imageUrl: 'https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=800',
      authorName: 'John Smith',
      tags: ['Business', 'Entertainment'],
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
    ),
    FeedPost(
      id: '3',
      title: 'Cambodia\'s Tech Startup Scene is Booming',
      content: 'The technology sector in Cambodia is experiencing rapid growth. Young entrepreneurs are creating innovative solutions for local and regional problems. The future looks bright for tech in Southeast Asia with increasing investment and support.',
      userId: 'user3',
      imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800',
      authorName: 'Sarah Chen',
      tags: ['Technologies', 'Business'],
      createdAt: DateTime.now().subtract(Duration(hours: 8)),
    ),
    FeedPost(
      id: '4',
      title: 'Political Reforms and Economic Growth',
      content: 'Recent political developments in Cambodia are shaping the country\'s economic future. Experts discuss the impact of new policies on business and investment opportunities in the region, highlighting the importance of stability.',
      userId: 'user4',
      imageUrl: 'https://images.unsplash.com/photo-1541872703-74c36f90c83d?w=800',
      authorName: 'David Wong',
      tags: ['Politics'],
      createdAt: DateTime.now().subtract(Duration(hours: 12)),
    ),
    FeedPost(
      id: '5',
      title: 'Sustainable Business Practices in Cambodia',
      content: 'More companies are adopting sustainable practices. From eco-tourism to green manufacturing, businesses are finding ways to grow while protecting the environment. This shift is crucial for long-term development.',
      userId: 'user5',
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
      authorName: 'Emily Taylor',
      tags: ['Business'],
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    FeedPost(
      id: '6',
      title: 'Hidden Beaches of Koh Rong',
      content: 'Discover the pristine beaches and crystal-clear waters of Koh Rong island. This paradise is perfect for those looking to escape the hustle and bustle of city life and immerse themselves in natural beauty.',
      userId: 'user6',
      imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
      authorName: 'Michael Brown',
      tags: ['Technologies', 'Travel'],
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
  ];

  @override
  Future<List<FeedPost>> getPosts({String? category}) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));

    if (category != null && category != 'All') {
      return _mockPosts.where((post) => post.tags.contains(category)).toList();
    }
    return _mockPosts;
  }

  @override
  Future<FeedPost> getPostById(String id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    try {
      return _mockPosts.firstWhere((post) => post.id == id);
    } catch (e) {
      throw Exception('Post not found');
    }
  }
}