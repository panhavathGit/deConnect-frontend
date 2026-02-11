import '../../../../core/services/supabase_service.dart';
import '../../../auth/data/models/user_model.dart' as UserModel;
import '../../../feed/data/models/feed_model.dart';
import '../models/profile_status.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel.User> getUserProfile(String userId);
  Future<ProfileStats> getProfileStats(String userId);
  Future<List<FeedPost>> getUserPosts(String userId);
  Future<void> updateProfile(UserModel.User user);
  Future<List<UserModel.User>> getAllUsers();
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
      final data = Map<String, dynamic>.from(response);
      data['email'] = authUser?.email ?? '';
      
      return UserModel.User.fromJson(data);
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

      // Use the same adapter pattern as in FeedRemoteDataSource
      return (response as List).map((json) {
        final profile = json['profiles'] as Map<String, dynamic>?;
        final data = Map<String, dynamic>.from(json);
        
        // Add profile data to top-level
        data['author_name'] = profile?['username'] ?? 'Unknown';
        data['author_avatar'] = profile?['avatar_url'];
        
        return FeedPost.fromJson(data);
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

      // await _supabase.from('profiles').update({
      //   'username': user.name,
      //   'first_name': user.firstName,
      //   'last_name': user.lastName,
      //   'gender': user.gender,
      //   'avatar_url': user.avatarUrl,
      //   'bio': user.bio,
      //   'updated_at': DateTime.now().toIso8601String(),
      // }).eq('id', user.id);

      await _supabase
        .from('profiles')
        .update(user.toJson())
        .eq('id', user.id);

      print('✅ Profile updated successfully');
      
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserModel.User>> getAllUsers() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      print('👥 Fetching all users from Supabase');
      
      final response = await _supabase
          .from('profiles')
          .select()
          .neq('id', currentUserId ?? '') // Exclude current user
          .order('username');

      // final users = (response as List).map((json) {
      //   return UserModel.User(
      //     id: json['id'],
      //     name: json['username'] ?? 'Unknown',
      //     email: json['email'] ?? '',
      //     avatarUrl: json['avatar_url'],
      //     bio: json['bio'],
      //     createdAt: DateTime.parse(json['created_at']),
      //   );
      // }).toList();

      final users = (response as List).map((json) {
        // Add email field (might be null from profiles table)
        final data = Map<String, dynamic>.from(json);
        if (!data.containsKey('email')) {
          data['email'] = '';
        }
        return UserModel.User.fromJson(data);
      }).toList();

      print('✅ Fetched ${users.length} users');
      
      return users;
    } catch (e) {
      print('❌ Error fetching users: $e');
      rethrow;
    }
  }
}