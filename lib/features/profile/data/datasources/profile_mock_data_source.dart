// lib/features/profile/data/datasources/profile_mock_data_source.dart
import '../../../auth/data/models/user_model.dart';
import '../../../feed/data/models/feed_model.dart';
import '../models/profile_status.dart';

abstract class ProfileMockDataSource {
  Future<User> getUserProfile(String userId);
  Future<ProfileStats> getProfileStats(String userId);
  Future<List<FeedPost>> getUserPosts(String userId);
}

class ProfileMockDataSourceImpl implements ProfileMockDataSource {
  static final User _mockUser = User(
    id: 'user1',
    name: 'Alice Jane',
    email: 'alicejane@gmail.com',
    avatarUrl: null,
    bio: 'Travel blogger and tech enthusiast from Phnom Penh',
    createdAt: DateTime.now().subtract(Duration(days: 365)),
  );

  static final ProfileStats _mockStats = ProfileStats(
    postsCount: 3,
  );

  static final List<FeedPost> _mockUserPosts = [
    FeedPost(
      id: '1',
      title: 'The best place to visit in Phnom Penh',
      content: 'Phnom Penh, Cambodia\'s busy capital, sits at the junction of the Mekong and Tonlé Sap rivers. It was a hub for both the Khmer Empire and French colonialists.',
      userId: 'user1',
      imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=800',
      authorName: 'Alice Jane',
      tags: ['Technologies', 'Travel'],
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
    ),
    FeedPost(
      id: '7',
      title: 'My Journey Through Southeast Asia',
      content: 'Over the past year, I\'ve explored the hidden gems of Southeast Asia. From bustling markets to serene temples, every moment has been an adventure.',
      userId: 'user1',
      imageUrl: 'https://images.unsplash.com/photo-1528181304800-259b08848526?w=800',
      authorName: 'Alice Jane',
      tags: ['Business', 'Travel'],
      createdAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    FeedPost(
      id: '8',
      title: 'Top Tech Tools for Digital Nomads',
      content: 'Working remotely while traveling requires the right tools. Here are my must-have apps and gadgets that keep me productive on the road.',
      userId: 'user1',
      imageUrl: 'https://images.unsplash.com/photo-1484788984921-03950022c9ef?w=800',
      authorName: 'Alice Jane',
      tags: ['Technologies'],
      createdAt: DateTime.now().subtract(Duration(days: 7)),
    ),
  ];

  @override
  Future<User> getUserProfile(String userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _mockUser;
  }

  @override
  Future<ProfileStats> getProfileStats(String userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _mockStats;
  }

  @override
  Future<List<FeedPost>> getUserPosts(String userId) async {
    await Future.delayed(Duration(milliseconds: 800));
    return _mockUserPosts;
  }
}