import '../../../../core/services/supabase_service.dart';

class ChatRepository {
  final _supabase = SupabaseService.client;

  // CALLS YOUR BACKEND RPC
  Future<String> getOrCreatePrivateRoom(String targetUserId) async {
    final roomId = await _supabase.rpc('create_or_get_private_chat', params: {
      'target_user_id': targetUserId
    });
    return roomId; // Returns UUID
  }

  // Gets rooms I belong to (Protected by RLS)
  Future<List<Map<String, dynamic>>> getMyRooms() async {
    final List<dynamic> response = await _supabase.from('rooms').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Sends message
  Future<void> sendMessage(String roomId, String content) async {
    await _supabase.from('messages').insert({
      'room_id': roomId,
      'sender_id': _supabase.auth.currentUser!.id,
      'content': content,
    });
  }

  // Realtime Stream
  Stream<List<Map<String, dynamic>>> getMessagesStream(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at');
  }
}