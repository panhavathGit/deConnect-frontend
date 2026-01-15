import '../../../../core/services/supabase_service.dart';
import 'feed_model.dart';

class FeedRepository {
  final _supabase = SupabaseService.client;

  Future<List<FeedPost>> fetchPosts() async {
    final response = await _supabase.from('posts').select().order('created_at', ascending: false);
    return (response as List).map((x) => FeedPost.fromJson(x)).toList();
  }
}