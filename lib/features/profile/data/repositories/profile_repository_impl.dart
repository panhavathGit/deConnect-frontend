// lib/features/profile/data/repositories/profile_repository_impl.dart
import '../datasources/profile_remote_data_source.dart';
import '../datasources/profile_mock_data_source.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../feed/data/models/feed_model.dart';
import '../models/profile_status.dart';
import './profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource? remoteDataSource;
  final ProfileMockDataSource? mockDataSource;
  final bool useMockData;

  ProfileRepositoryImpl({
    this.remoteDataSource,
    this.mockDataSource,
    this.useMockData = true, // Set to false when backend is ready
  });

  @override
  Future<User> getUserProfile(String userId) async {
    if (useMockData) {
      return await mockDataSource!.getUserProfile(userId);
    } else {
      return await remoteDataSource!.getUserProfile(userId);
    }
  }

  @override
  Future<ProfileStats> getProfileStats(String userId) async {
    if (useMockData) {
      return await mockDataSource!.getProfileStats(userId);
    } else {
      return await remoteDataSource!.getProfileStats(userId);
    }
  }

  @override
  Future<List<FeedPost>> getUserPosts(String userId) async {
    if (useMockData) {
      return await mockDataSource!.getUserPosts(userId);
    } else {
      return await remoteDataSource!.getUserPosts(userId);
    }
  }

  @override
  Future<void> updateProfile(User user) async {
    if (!useMockData) {
      await remoteDataSource!.updateProfile(user);
    }
  }
}