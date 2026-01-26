// lib/features/profile/data/repositories/profile_repository.dart
import '../../../auth/data/models/user_model.dart';
import '../../../feed/data/models/feed_model.dart';
import '../models/profile_status.dart';

abstract class ProfileRepository {
  Future<User> getUserProfile(String userId);
  Future<ProfileStats> getProfileStats(String userId);
  Future<List<FeedPost>> getUserPosts(String userId);
  Future<void> updateProfile(User user);
}