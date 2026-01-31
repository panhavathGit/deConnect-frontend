// lib/features/chat/data/datasources/chat_remote_data_source.dart
import 'dart:async';
import '../../../../core/services/supabase_service.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatRoom>> getChatRooms();
  Future<ChatRoom> getOrCreateDirectRoom(String otherUserId);
  Future<List<ChatMessage>> getMessages(String roomId);
  Future<ChatMessage> sendMessage(String roomId, String content);
  Stream<List<ChatMessage>> streamMessages(String roomId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final _supabase = SupabaseService.client;

  @override
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('Not authenticated');

      print('📥 Fetching chat rooms for user: $currentUserId');

      final memberRooms = await _supabase
          .from('room_members')
          .select('room_id')
          .eq('user_id', currentUserId);

      if (memberRooms.isEmpty) {
        print('✅ No chat rooms found');
        return [];
      }

      final roomIds = (memberRooms as List).map((m) => m['room_id']).toList();

      final rooms = await _supabase
          .from('chat_rooms')
          .select()
          .inFilter('id', roomIds);

      List<ChatRoom> chatRooms = [];

      for (var roomData in rooms) {
        final roomId = roomData['id'];
        final isGroup = roomData['is_group'];

        String? otherUserName;
        String? otherUserAvatar;

        if (!isGroup) {
          final otherMembers = await _supabase
              .from('room_members')
              .select('''
                user_id,
                profiles!inner(username, avatar_url)
              ''')
              .eq('room_id', roomId)
              .neq('user_id', currentUserId)
              .limit(1);

          if (otherMembers.isNotEmpty) {
            final profile = otherMembers[0]['profiles'];
            otherUserName = profile['username'];
            otherUserAvatar = profile['avatar_url'];
          }
        }

        final lastMessages = await _supabase
            .from('messages')
            .select('content, created_at')
            .eq('room_id', roomId)
            .isFilter('deleted_at', null)
            .order('created_at', ascending: false)
            .limit(1);

        final member = await _supabase
            .from('room_members')
            .select('last_read_at')
            .eq('room_id', roomId)
            .eq('user_id', currentUserId)
            .single();

        final lastReadAt = member['last_read_at'] != null
            ? DateTime.parse(member['last_read_at'])
            : DateTime.now();

        final unreadMessages = await _supabase
            .from('messages')
            .select('id')
            .eq('room_id', roomId)
            .neq('sender_id', currentUserId)
            .gt('created_at', lastReadAt.toIso8601String());

        final unreadCount = (unreadMessages as List).length;

        chatRooms.add(ChatRoom(
          id: roomId,
          name: roomData['name'],
          isGroup: isGroup,
          createdBy: roomData['created_by'],
          createdAt: DateTime.parse(roomData['created_at']),
          updatedAt: DateTime.parse(roomData['updated_at']),
          inviteCode: roomData['invite_code'],
          maxMembers: roomData['max_members'],
          inviteLinkEnabled: roomData['invite_link_enabled'] ?? true,
          inviteExpiresAt: roomData['invite_expires_at'] != null
              ? DateTime.parse(roomData['invite_expires_at'])
              : null,
          otherUserName: otherUserName,
          otherUserAvatar: otherUserAvatar,
          lastMessage: lastMessages.isNotEmpty ? lastMessages[0]['content'] : null,
          lastMessageTime: lastMessages.isNotEmpty
              ? DateTime.parse(lastMessages[0]['created_at'])
              : null,
          unreadCount: unreadCount,
        ));
      }

      chatRooms.sort((a, b) {
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      print('✅ Fetched ${chatRooms.length} chat rooms');
      return chatRooms;
    } catch (e) {
      print('❌ Error fetching chat rooms: $e');
      throw Exception('Failed to fetch chat rooms: $e');
    }
  }

  @override
  Future<ChatRoom> getOrCreateDirectRoom(String otherUserId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('Not authenticated');

      print('🔍 Looking for existing room with user: $otherUserId');

      final myRooms = await _supabase
          .from('room_members')
          .select('room_id')
          .eq('user_id', currentUserId);

      final myRoomIds = (myRooms as List).map((m) => m['room_id']).toList();

      if (myRoomIds.isNotEmpty) {
        final sharedRooms = await _supabase
            .from('room_members')
            .select('room_id')
            .eq('user_id', otherUserId)
            .inFilter('room_id', myRoomIds);

        if (sharedRooms.isNotEmpty) {
          for (var room in sharedRooms) {
            final roomData = await _supabase
                .from('chat_rooms')
                .select()
                .eq('id', room['room_id'])
                .eq('is_group', false)
                .maybeSingle();

            if (roomData != null) {
              print('✅ Found existing room: ${roomData['id']}');
              final rooms = await getChatRooms();
              return rooms.firstWhere((r) => r.id == roomData['id']);
            }
          }
        }
      }

      print('📝 Creating new chat room');

      final newRoom = await _supabase
          .from('chat_rooms')
          .insert({
            'name': null,
            'is_group': false,
            'created_by': currentUserId,
          })
          .select()
          .single();

      await _supabase.from('room_members').insert([
        {
          'room_id': newRoom['id'],
          'user_id': currentUserId,
          'is_admin': false,
          'admin_order': 999999,
          'joined_at': DateTime.now().toIso8601String(),
        },
        {
          'room_id': newRoom['id'],
          'user_id': otherUserId,
          'is_admin': false,
          'admin_order': 999999,
          'joined_at': DateTime.now().toIso8601String(),
        },
      ]);

      print('✅ Created new room: ${newRoom['id']}');

      final rooms = await getChatRooms();
      return rooms.firstWhere((r) => r.id == newRoom['id']);
    } catch (e) {
      print('❌ Error creating room: $e');
      throw Exception('Failed to create chat room: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String roomId) async {
    try {
      print('📥 Fetching messages for room: $roomId');

      final response = await _supabase
          .from('messages')
          .select('''
            *,
            profiles:sender_id(username, avatar_url)
          ''')
          .eq('room_id', roomId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(50);

      final messages = (response as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();

      print('✅ Fetched ${messages.length} messages');
      return messages;
    } catch (e) {
      print('❌ Error fetching messages: $e');
      throw Exception('Failed to fetch messages: $e');
    }
  }

  @override
  Future<ChatMessage> sendMessage(String roomId, String content) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('Not authenticated');

      print('📤 Sending message to room: $roomId');

      final response = await _supabase
          .from('messages')
          .insert({
            'room_id': roomId,
            'sender_id': currentUserId,
            'content': content.trim(),
            'status': 'sent',
          })
          .select('''
            *,
            profiles:sender_id(username, avatar_url)
          ''')
          .single();

      print('✅ Message sent');
      return ChatMessage.fromJson(response);
    } catch (e) {
      print('❌ Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // ✅ FIXED: Simplified stream without async issues
  @override
  Stream<List<ChatMessage>> streamMessages(String roomId) {
    print('👂 Streaming messages in room: $roomId');

    // Use a StreamController to handle async operations properly
    final controller = StreamController<List<ChatMessage>>.broadcast();

    final subscription = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .listen((data) async {
          try {
            if (data.isEmpty) {
              controller.add(<ChatMessage>[]);
              return;
            }

            // Fetch messages with profile data
            final messageIds = data.map((msg) => msg['id']).toList();

            final fullMessages = await _supabase
                .from('messages')
                .select('''
                  *,
                  profiles:sender_id(username, avatar_url)
                ''')
                .inFilter('id', messageIds)
                .isFilter('deleted_at', null)
                .order('created_at', ascending: false);

            final messages = (fullMessages as List)
                .map((json) => ChatMessage.fromJson(json))
                .toList();

            print('📨 Stream emitting ${messages.length} messages');
            controller.add(messages);
          } catch (e) {
            print('❌ Error in stream: $e');
            controller.addError(e);
          }
        }, onError: (error) {
          print('❌ Stream error: $error');
          controller.addError(error);
        });

    controller.onCancel = () {
      print('🛑 Stream cancelled');
      subscription.cancel();
    };

    return controller.stream;
  }
}