// // lib/features/profile/data/datasources/profile_remote_data_source.dart


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
//       final response = await _supabase
//           .from('posts')
//           .select()
//           .eq('user_id', userId);
      
//       final postsCount = (response as List).length;
      
//       return ProfileStats(
//         postsCount: postsCount,
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
// lib/features/profile/data/datasources/profile_remote_data_source.dart
import '../../../../core/services/supabase_service.dart';
import '../../../auth/data/models/user_model.dart' as UserModel;
import '../../../feed/data/models/feed_model.dart';
import '../models/profile_status.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel.User> getUserProfile(String userId);
  Future<ProfileStats> getProfileStats(String userId);
  Future<List<FeedPost>> getUserPosts(String userId);
  Future<void> updateProfile(UserModel.User user);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final _supabase = SupabaseService.client;

  @override
  Future<UserModel.User> getUserProfile(String userId) async {
    try {
      print('📥 Fetching user profile from Supabase: $userId');
      
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      print('✅ Profile data received: $response');
      
      // Get email from auth user
      final authUser = _supabase.auth.currentUser;
      
      return UserModel.User(
        id: response['id'],
        name: response['username'] ?? 'Unknown',
        email: authUser?.email ?? '',
        firstName: response['first_name'],      // Add
        lastName: response['last_name'],        // Add
        gender: response['gender'],             // Add
        avatarUrl: response['avatar_url'],
        bio: response['bio'],
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      print('❌ Error fetching profile: $e');
      rethrow;
    }
  }
  
  @override
  Future<ProfileStats> getProfileStats(String userId) async {
    try {
      print('📊 Fetching profile stats for: $userId');
      
      // Count user posts - simply get the list and count it
      final response = await _supabase
          .from('posts')
          .select('id')
          .eq('user_id', userId);

      final count = (response as List).length;
      print('✅ User has $count posts');
      
      return ProfileStats(
        postsCount: count,
      );
    } catch (e) {
      print('❌ Error fetching stats: $e');
      // Return default stats on error
      return ProfileStats(
        postsCount: 0,
      );
    }
  }

  @override
  Future<List<FeedPost>> getUserPosts(String userId) async {
    try {
      print('📝 Fetching user posts from Supabase: $userId');
      
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles:user_id (
              username,
              avatar_url
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ Fetched ${response.length} posts');

      return (response as List).map((post) {
        final profile = post['profiles'];
        return FeedPost(
          id: post['id'],
          title: post['title'] ?? '',
          content: post['content'] ?? '',
          userId: post['user_id'],
          category: post['category'] ?? 'General',
          authorName: profile?['username'] ?? 'Unknown',
          authorAvatar: profile?['avatar_url'],
          createdAt: DateTime.parse(post['created_at']),
          imageUrl: post['image_url'],
          commentCount: post['comment_count'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching user posts: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateProfile(UserModel.User user) async {
    try {
      print('💾 Updating profile in Supabase: ${user.id}');
      
      await _supabase.from('profiles').update({
        'username': user.name,
        'avatar_url': user.avatarUrl,
        'bio': user.bio,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      print('✅ Profile updated successfully');
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }
}