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
  // Stream<ChatMessage> subscribeToMessages(String roomId);
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

      // Get all room IDs user is member of - CHANGED TABLE NAME
      final memberRooms = await _supabase
          .from('room_members')  // Changed from 'chat_room_members'
          .select('room_id')
          .eq('user_id', currentUserId);

      if (memberRooms.isEmpty) {
        print('✅ No chat rooms found');
        return [];
      }

      final roomIds = (memberRooms as List).map((m) => m['room_id']).toList();

      // Get room details
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

        // For 1-on-1 chats, get other user info - CHANGED TABLE NAME
        if (!isGroup) {
          final otherMembers = await _supabase
              .from('room_members')  // Changed from 'chat_room_members'
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

        // Get last message
        final lastMessages = await _supabase
            .from('messages')
            .select('content, created_at')
            .eq('room_id', roomId)
            .isFilter('deleted_at', null)
            .order('created_at', ascending: false)
            .limit(1);

        // Get unread count - CHANGED TABLE NAME
        final member = await _supabase
            .from('room_members')  // Changed from 'chat_room_members'
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

      // Sort by last message time
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

      // Find existing direct room between these two users - CHANGED TABLE NAME
      final myRooms = await _supabase
          .from('room_members')  // Changed from 'chat_room_members'
          .select('room_id')
          .eq('user_id', currentUserId);

      final myRoomIds = (myRooms as List).map((m) => m['room_id']).toList();

      if (myRoomIds.isNotEmpty) {
        final sharedRooms = await _supabase
            .from('room_members')  // Changed from 'chat_room_members'
            .select('room_id')
            .eq('user_id', otherUserId)
            .inFilter('room_id', myRoomIds);

        if (sharedRooms.isNotEmpty) {
          // Check if it's a direct room (not group)
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

      // Create new room (name can be null for private chats)
      final newRoom = await _supabase
          .from('chat_rooms')
          .insert({
            'name': null,  // Private chats don't need a name
            'is_group': false,
            'created_by': currentUserId,
          })
          .select()
          .single();

      // Add both users as members - CHANGED TABLE NAME
      await _supabase.from('room_members').insert([  // Changed from 'chat_room_members'
        {'room_id': newRoom['id'], 'user_id': currentUserId},
        {'room_id': newRoom['id'], 'user_id': otherUserId},
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

  // @override
  // Stream<ChatMessage> subscribeToMessages(String roomId) {
  //   print('👂 Subscribing to messages in room: $roomId');
    
  //   final controller = StreamController<ChatMessage>.broadcast();

  //   final subscription = _supabase
  //       .from('messages')
  //       .stream(primaryKey: ['id'])
  //       .eq('room_id', roomId)
  //       .order('created_at')
  //       .listen((data) async {
  //         if (data.isNotEmpty) {
  //           final latestMsg = data.last;
  //           // Fetch with profile info
  //           final fullMsg = await _supabase
  //               .from('messages')
  //               .select('''
  //                 *,
  //                 profiles:sender_id(username, avatar_url)
  //               ''')
  //               .eq('id', latestMsg['id'])
  //               .single();
            
  //           controller.add(ChatMessage.fromJson(fullMsg));
  //         }
  //       });

  //   controller.onCancel = () {
  //     subscription.cancel();
  //   };

  //   return controller.stream;
  // }

  @override
Stream<List<ChatMessage>> streamMessages(String roomId) {
  print('👂 Streaming messages in room: $roomId');
  
  return _supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', roomId)
      .order('created_at', ascending: false)
      .map((data) async {
        // Fetch full message data with profiles
        final messageIds = data.map((msg) => msg['id']).toList();
        
        if (messageIds.isEmpty) return <ChatMessage>[];
        
        final fullMessages = await _supabase
            .from('messages')
            .select('''
              *,
              profiles:sender_id(username, avatar_url)
            ''')
            .inFilter('id', messageIds)
            .isFilter('deleted_at', null)
            .order('created_at', ascending: false);
        
        return (fullMessages as List)
            .map((json) => ChatMessage.fromJson(json))
            .toList();
      })
      .asyncMap((future) => future);
}
}