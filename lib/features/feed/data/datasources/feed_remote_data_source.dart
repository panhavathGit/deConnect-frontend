// // lib/features/feed/data/datasources/feed_remote_data_source.dart
// import '../../../../core/services/supabase_service.dart';
// import '../models/feed_model.dart';

// abstract class FeedRemoteDataSource {
//   Future<List<FeedPost>> getPosts({String? category});
//   Future<FeedPost> getPostById(String id);
//   Future<void> createPost(FeedPost post);
//   Future<void> updatePost(FeedPost post);
//   Future<void> deletePost(String id);
// }

// class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
//   final _supabase = SupabaseService.client;

//   @override
//   Future<List<FeedPost>> getPosts({String? category}) async {
//     try {
//       final query = _supabase.from('posts').select();
      
//       final filteredQuery = (category != null && category != 'All')
//           ? query.eq('category', category)
//           : query;
      
//       final response = await filteredQuery.order('created_at', ascending: false);
      
//       return (response as List)
//           .map((json) => FeedPost.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to fetch posts: $e');
//     }
//   }

//   @override
//   Future<FeedPost> getPostById(String id) async {
//     try {
//       final response = await _supabase
//           .from('posts')
//           .select()
//           .eq('id', id)
//           .single();
      
//       return FeedPost.fromJson(response);
//     } catch (e) {
//       throw Exception('Failed to fetch post: $e');
//     }
//   }

//   @override
//   Future<void> createPost(FeedPost post) async {
//     try {
//       await _supabase.from('posts').insert(post.toJson());
//     } catch (e) {
//       throw Exception('Failed to create post: $e');
//     }
//   }

//   @override
//   Future<void> updatePost(FeedPost post) async {
//     try {
//       await _supabase
//           .from('posts')
//           .update(post.toJson())
//           .eq('id', post.id);
//     } catch (e) {
//       throw Exception('Failed to update post: $e');
//     }
//   }

//   @override
//   Future<void> deletePost(String id) async {
//     try {
//       await _supabase.from('posts').delete().eq('id', id);
//     } catch (e) {
//       throw Exception('Failed to delete post: $e');
//     }
//   }
// }

// lib/features/feed/data/datasources/feed_remote_data_source.dart
import '../../../../core/services/supabase_service.dart';
import '../models/feed_model.dart';

abstract class FeedRemoteDataSource {
  Future<List<FeedPost>> getPosts({String? category});
  Future<FeedPost> getPostById(String id);
  Future<void> createPost(FeedPost post);
  Future<void> updatePost(FeedPost post);
  Future<void> deletePost(String id);
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
      
      return (response as List).map((json) {
        final profile = json['profiles'];
        
        // Parse tags array
        List<String> tags = [];
        if (json['tags'] != null) {
          tags = List<String>.from(json['tags']);
        }
        
        return FeedPost(
          id: json['id'],
          title: json['title'] ?? 'Untitled Post',
          content: json['content'] ?? '',
          userId: json['user_id'],
          imageUrl: json['image_url'],
          authorName: profile?['username'] ?? 'Unknown',
          authorAvatar: profile?['avatar_url'],
          tags: tags,
          createdAt: DateTime.parse(json['created_at']),
        );
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
      
      final profile = response['profiles'];
      
      // Parse tags array
      List<String> tags = [];
      if (response['tags'] != null) {
        tags = List<String>.from(response['tags']);
      }
      
      return FeedPost(
        id: response['id'],
        title: response['title'] ?? 'Untitled Post',
        content: response['content'] ?? '',
        userId: response['user_id'],
        imageUrl: response['image_url'],
        authorName: profile?['username'] ?? 'Unknown',
        authorAvatar: profile?['avatar_url'],
        tags: tags,
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      print('❌ Error fetching post: $e');
      throw Exception('Failed to fetch post: $e');
    }
  }

  @override
  Future<void> createPost(FeedPost post) async {
    try {
      await _supabase.from('posts').insert(post.toJson());
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
      await _supabase.from('posts').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}