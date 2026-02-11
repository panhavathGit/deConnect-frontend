// lib/features/feed/data/datasources/feed_remote_data_source.dart
import '../../../../core/services/supabase_service.dart';
import '../models/feed_model.dart';
import 'dart:io';

abstract class FeedRemoteDataSource {
  Future<List<FeedPost>> getPosts({String? category});
  Future<FeedPost> getPostById(String id);
  Future<void> createPost(FeedPost post);
  Future<void> updatePost(FeedPost post);
  Future<void> deletePost(String id);
  Future<String> uploadPostImage(File image, String userId);
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final _supabase = SupabaseService.client;

  @override
  Future<List<FeedPost>> getPosts({String? category}) async {
    try {
      print('📥 Fetching posts from Supabase...');
      
      // Select posts with user profile info using JOIN
      var query = _supabase.from('posts').select('''
        *,
        profiles:user_id (
          username,
          avatar_url
        )
      ''');
      
      // Filter by category if provided (using tags array)
      if (category != null && category != 'All') {
        query = query.contains('tags', [category]);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      print('✅ Fetched ${response.length} posts');
      
      // return (response as List).map((json) {
      //   final profile = json['profiles'];
        
      //   // Parse tags array
      //   List<String> tags = [];
      //   if (json['tags'] != null) {
      //     tags = List<String>.from(json['tags']);
      //   }
        
      //   return FeedPost(
      //     id: json['id'],
      //     title: json['title'] ?? 'Untitled Post',
      //     content: json['content'] ?? '',
      //     userId: json['user_id'],
      //     imageUrl: json['image_url'],
      //     authorName: profile?['username'] ?? 'Unknown',
      //     authorAvatar: profile?['avatar_url'],
      //     tags: tags,
      //     createdAt: DateTime.parse(json['created_at']),
      //   );
      // }).toList();

       // 1. Use the generated model
      return (response as List).map((json) {
        
        // --- THE BRIDGE ---
        // We manually move the nested profile data to where the generated code expects it
        final profile = json['profiles'] as Map<String, dynamic>?; // Safe cast
        
        // We create a mutable map to modify
        final Map<String, dynamic> data = Map.from(json);
        
        data['author_name'] = profile?['username'] ?? 'Unknown';
        data['author_avatar'] = profile?['avatar_url'];
        // ------------------

        // 2. Now let the generated code do the hard work (parsing dates, lists, types)
        return FeedPost.fromJson(data);
        
      }).toList();

    } catch (e) {
      print('❌ Error fetching posts: $e');
      throw Exception('Failed to fetch posts: $e');
    }
  }

  @override
  Future<FeedPost> getPostById(String id) async {
    try {
      print('📥 Fetching post: $id');
      
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles:user_id (
              username,
              avatar_url
            )
          ''')
          .eq('id', id)
          .single();
      
      // final profile = response['profiles'];
      
      // // Parse tags array
      // List<String> tags = [];
      // if (response['tags'] != null) {
      //   tags = List<String>.from(response['tags']);
      // }
      
      // return FeedPost(
      //   id: response['id'],
      //   title: response['title'] ?? 'Untitled Post',
      //   content: response['content'] ?? '',
      //   userId: response['user_id'],
      //   imageUrl: response['image_url'],
      //   authorName: profile?['username'] ?? 'Unknown',
      //   authorAvatar: profile?['avatar_url'],
      //   tags: tags,
      //   createdAt: DateTime.parse(response['created_at']),
      // );

      // --- THE ADAPTER LOGIC ---
      
      // 1. Create a mutable copy of the response
      final data = Map<String, dynamic>.from(response);
      
      // 2. Extract the nested profile
      final profile = data['profiles'] as Map<String, dynamic>?;
      
      // 3. Move nested fields to top-level keys (matching your JSON annotations)
      data['author_name'] = profile?['username'] ?? 'Unknown';
      data['author_avatar'] = profile?['avatar_url'];
      
      // -------------------------

      // 4. Pass to generated model
      // The generator automatically handles:
      // - Parsing 'tags' list
      // - Parsing 'created_at' DateTime
      // - Null safety checks
      return FeedPost.fromJson(data);

    } catch (e) {
      print('❌ Error fetching post: $e');
      throw Exception('Failed to fetch post: $e');
    }
  }

  @override
  Future<void> createPost(FeedPost post) async {
    try {
      print('📝 Creating post in database...');

      //==============================================
      //The .select() at the end makes Supabase return the newly created row 
      //data after the insert. so we can log to see what we added in the database
      //==============================================
      
      final response = await _supabase.from('posts').insert(post.toJson());

      print('create post from remote data source : $response');
      
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<void> updatePost(FeedPost post) async {
    try {
      await _supabase
          .from('posts')
          .update(post.toJson())
          .eq('id', post.id);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      print('🗑️ Deleting post: $id');
      await _supabase.from('posts').delete().eq('id', id);
      print('✅ Post deleted from database');
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  @override
  Future<String> uploadPostImage(File image, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.jpg';
      final filePath = 'posts/$fileName';

      await _supabase.storage
          .from('post-images')
          .upload(filePath, image);

      final imageUrl = _supabase.storage
          .from('post-images')
          .getPublicUrl(filePath);

      print('✅ Image uploaded: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

}