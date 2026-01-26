// // lib/features/profile/data/datasources/profile_remote_data_source.dart
// import '../../../../core/services/supabase_service.dart';
// import '../../../auth/data/models/user_model.dart';
// import '../../../feed/data/models/feed_model.dart';
// import '../models/profile_status.dart';

// abstract class ProfileRemoteDataSource {
//   Future<User> getUserProfile(String userId);
//   Future<ProfileStats> getProfileStats(String userId);
//   Future<List<FeedPost>> getUserPosts(String userId);
//   Future<void> updateProfile(User user);
// }

// class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
//   final _supabase = SupabaseService.client;

//   @override
//   Future<User> getUserProfile(String userId) async {
//     try {
//       final response = await _supabase
//           .from('users')
//           .select()
//           .eq('id', userId)
//           .single();
      
//       return User.fromJson(response);
//     } catch (e) {
//       throw Exception('Failed to fetch user profile: $e');
//     }
//   }

//   @override
//   Future<ProfileStats> getProfileStats(String userId) async {
//     try {
//       // Get posts count from posts table
//       final postsCount = await _supabase
//           .from('posts')
//           .select('id', const FetchOptions(count: CountOption.exact))
//           .eq('user_id', userId);
      
//       return ProfileStats(
//         postsCount: postsCount.count ?? 0,
//       );
//     } catch (e) {
//       throw Exception('Failed to fetch profile stats: $e');
//     }
//   }

//   @override
//   Future<List<FeedPost>> getUserPosts(String userId) async {
//     try {
//       final response = await _supabase
//           .from('posts')
//           .select()
//           .eq('user_id', userId)
//           .order('created_at', ascending: false);
      
//       return (response as List)
//           .map((json) => FeedPost.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to fetch user posts: $e');
//     }
//   }

//   @override
//   Future<void> updateProfile(User user) async {
//     try {
//       await _supabase
//           .from('users')
//           .update(user.toJson())
//           .eq('id', user.id);
//     } catch (e) {
//       throw Exception('Failed to update profile: $e');
//     }
//   }
// }


// lib/features/profile/data/datasources/profile_remote_data_source.dart
import '../../../../core/services/supabase_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../feed/data/models/feed_model.dart';
import '../models/profile_status.dart';

abstract class ProfileRemoteDataSource {
  Future<User> getUserProfile(String userId);
  Future<ProfileStats> getProfileStats(String userId);
  Future<List<FeedPost>> getUserPosts(String userId);
  Future<void> updateProfile(User user);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final _supabase = SupabaseService.client;

  @override
  Future<User> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<ProfileStats> getProfileStats(String userId) async {
    try {
      // Get posts count from posts table
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId);
      
      final postsCount = (response as List).length;
      
      return ProfileStats(
        postsCount: postsCount,
      );
    } catch (e) {
      throw Exception('Failed to fetch profile stats: $e');
    }
  }

  @override
  Future<List<FeedPost>> getUserPosts(String userId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => FeedPost.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  @override
  Future<void> updateProfile(User user) async {
    try {
      await _supabase
          .from('users')
          .update(user.toJson())
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}