// lib/features/chat/data/datasources/chat_remote_data_source.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../models/group_chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatRoom>> getChatRooms();
  Future<ChatRoom?> createDirectChat(String otherUserId);
  Future<ChatMessage> sendMessage(String roomId, String content);
  Future<ChatMessage> sendFileMessage(String roomId, File file, {String? caption});
  Stream<List<ChatMessage>> streamMessages(String roomId);
  Future<void> editMessage(String messageId, String newContent);
  Future<void> deleteMessage(String messageId);
  Future<void> markMessagesAsRead(String roomId);
  Future<void> setTypingIndicator(String roomId, bool isTyping);
  Stream<List<String>> streamTypingUsers(String roomId);

  // // Presence
  // Stream<Map<String, dynamic>> streamUserPresence(String userId);
  // Future<void> updateMyPresence();

  // Group Chat Methods
  Future<CreateGroupResponse> createGroup(String name, {String? description});
  Future<JoinGroupResponse> joinGroupByCode(String code);
  Future<List<GroupChat>> getMyGroups();
  Future<String> regenerateInviteCode(String roomId);

  Future<void> removeMember(String roomId, String userId);

}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;
  String get _currentUserId => _supabase.auth.currentUser!.id;

 @override
Future<List<ChatRoom>> getChatRooms() async {
  debugPrint('📥 Fetching chat rooms for user: $_currentUserId');
  
  // // Update my presence when fetching chats
  // updateMyPresence(); // Don't await - fire and forget
  
  // OPTIMIZED: Single query with all joins
  final response = await _supabase
      .from('room_members')
      .select('''
        room_id,
        chat_rooms!inner (
          id,
          name,
          is_group,
          created_at,
          created_by
        )
      ''')
      .eq('user_id', _currentUserId);

  if (response.isEmpty) {
    debugPrint('✅ No chat rooms found');
    return [];
  }

  // Get all room IDs
  final roomIds = response.map((item) => item['chat_rooms']['id'] as String).toList();

  // BATCH QUERY 1: Get all members for all rooms at once
  final allMembersResponse = await _supabase
      .from('room_members')
      .select('room_id, user_id, profiles(username, avatar_url, last_seen, is_online)')
      .inFilter('room_id', roomIds)
      .neq('user_id', _currentUserId);

  // BATCH QUERY 2: Get last message for all rooms at once using RPC or manual grouping
  final allMessagesResponse = await _supabase
      .from('messages')
      .select('room_id, content, media_url, media_type, created_at, sender_id')
      .inFilter('room_id', roomIds)
      .eq('is_deleted', false)
      .order('created_at', ascending: false);

  // BATCH QUERY 3: Get unread counts for all rooms
  final allUnreadResponse = await _supabase
      .from('messages')
      .select('room_id, id')
      .inFilter('room_id', roomIds)
      .neq('sender_id', _currentUserId)
      .eq('is_read', false)
      .eq('is_deleted', false);

  // Process results into maps for fast lookup
  final membersMap = <String, List<Map<String, dynamic>>>{};
  for (final member in allMembersResponse) {
    final roomId = member['room_id'] as String;
    membersMap.putIfAbsent(roomId, () => []).add(member);
  }

  final lastMessageMap = <String, Map<String, dynamic>>{};
  for (final msg in allMessagesResponse) {
    final roomId = msg['room_id'] as String;
    if (!lastMessageMap.containsKey(roomId)) {
      lastMessageMap[roomId] = msg;
    }
  }

  final unreadCountMap = <String, int>{};
  for (final msg in allUnreadResponse) {
    final roomId = msg['room_id'] as String;
    unreadCountMap[roomId] = (unreadCountMap[roomId] ?? 0) + 1;
  }

  // Build rooms list
  final List<ChatRoom> rooms = [];

  for (final item in response) {
    final roomData = item['chat_rooms'];
    final roomId = roomData['id'] as String;

    // Get members from map
    // final members = membersMap[roomId] ?? [];
    // String? otherUserId;
    // DateTime? otherUserLastSeen;
    // bool otherUserIsOnline = false;
    // String roomName = roomData['name'] ?? 'Chat';
    // String? roomAvatar;

    // if (roomData['is_group'] == false && members.isNotEmpty) {
    //   final otherUser = members.first;
    //   otherUserId = otherUser['user_id'];
    //   if (otherUser['profiles'] != null) {
    //     roomName = otherUser['profiles']['username'] ?? 'User';
    //     roomAvatar = otherUser['profiles']['avatar_url'];
    //     if (otherUser['profiles']['last_seen'] != null) {
    //       otherUserLastSeen = DateTime.parse(otherUser['profiles']['last_seen']);
    //     }
    //     otherUserIsOnline = otherUser['profiles']['is_online'] ?? false;
    //   }
    // }

        // Get members from map
    final members = membersMap[roomId] ?? [];
    String? otherUserId;
    DateTime? otherUserLastSeen;
    bool otherUserIsOnline = false;
    String roomName = roomData['name'] ?? 'Chat';
    String? roomAvatar;

    // Only get user info from members if it's a direct chat (not a group)
    if (roomData['is_group'] == false && members.isNotEmpty) {
      final otherUser = members.first;
      otherUserId = otherUser['user_id'];
      if (otherUser['profiles'] != null) {
        roomName = otherUser['profiles']['username'] ?? 'User';
        roomAvatar = otherUser['profiles']['avatar_url'];
        if (otherUser['profiles']['last_seen'] != null) {
          otherUserLastSeen = DateTime.parse(otherUser['profiles']['last_seen']);
        }
        otherUserIsOnline = otherUser['profiles']['is_online'] ?? false;
      }
    } else if (roomData['is_group'] == true) {
      // For group chats, use the room's name and avatar
      roomName = roomData['name'] ?? 'Group Chat';
      roomAvatar = null; // Groups don't have avatars yet in your schema
    }

    // Get last message from map
    String? lastMessage;
    DateTime? lastMessageTime;
    final lastMsgData = lastMessageMap[roomId];
    if (lastMsgData != null) {
      final content = lastMsgData['content'] ?? '';
      final mediaUrl = lastMsgData['media_url'];
      final mediaType = lastMsgData['media_type'];

      if (mediaUrl != null && content.isEmpty) {
        if (mediaType == 'image' || (mediaUrl as String).contains(RegExp(r'\.(jpg|png|gif|webp)', caseSensitive: false))) {
          lastMessage = '📷 Photo';
        } else if (mediaType == 'video') {
          lastMessage = '🎥 Video';
        } else if (mediaType == 'pdf' || mediaUrl.contains('.pdf')) {
          lastMessage = '📄 PDF';
        } else if (mediaType == 'audio') {
          lastMessage = '🎵 Audio';
        } else {
          lastMessage = '📎 File';
        }
      } else if (mediaUrl != null) {
        lastMessage = '📎 $content';
      } else {
        lastMessage = content;
      }
      lastMessageTime = DateTime.parse(lastMsgData['created_at']);
    }

    // Get unread count from map
    final unreadCount = unreadCountMap[roomId] ?? 0;

    rooms.add(ChatRoom(
      id: roomId,
      name: roomName,
      isGroup: roomData['is_group'] ?? false,
      avatarUrl: roomAvatar,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      createdAt: DateTime.parse(roomData['created_at']),
      otherUserId: otherUserId,
      otherUserLastSeen: otherUserLastSeen,
      otherUserIsOnline: otherUserIsOnline,
    ));
  }

  // Sort by last message time
  rooms.sort((a, b) {
    if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
    if (a.lastMessageTime == null) return 1;
    if (b.lastMessageTime == null) return -1;
    return b.lastMessageTime!.compareTo(a.lastMessageTime!);
  });

  debugPrint('✅ Fetched ${rooms.length} chat rooms (OPTIMIZED)');
  return rooms;
}

  @override
  Future<ChatRoom?> createDirectChat(String otherUserId) async {
    debugPrint('💬 Creating chat room with user: $otherUserId');
    try {
      final myRooms = await _supabase
          .from('room_members')
          .select('room_id')
          .eq('user_id', _currentUserId);

      for (final room in myRooms) {
        final roomId = room['room_id'];
        final roomInfo = await _supabase
            .from('chat_rooms')
            .select()
            .eq('id', roomId)
            .eq('is_group', false)
            .maybeSingle();

        if (roomInfo != null) {
          final otherMember = await _supabase
              .from('room_members')
              .select()
              .eq('room_id', roomId)
              .eq('user_id', otherUserId)
              .maybeSingle();

          if (otherMember != null) {
            debugPrint('✅ Found existing room: $roomId');
            final rooms = await getChatRooms();
            return rooms.firstWhere((r) => r.id == roomId);
          }
        }
      }

      final roomResponse = await _supabase.from('chat_rooms').insert({
        'name': null,
        'is_group': false,
        'created_by': _currentUserId,
      }).select().single();

      final roomId = roomResponse['id'];
      debugPrint('✅ Created room: $roomId');

      await _supabase.from('room_members').insert([
        {'room_id': roomId, 'user_id': _currentUserId},
        {'room_id': roomId, 'user_id': otherUserId},
      ]);

      final rooms = await getChatRooms();
      return rooms.firstWhere((r) => r.id == roomId);
    } catch (e) {
      debugPrint('❌ Error creating room: $e');
      rethrow;
    }
  }

  @override
  Future<ChatMessage> sendMessage(String roomId, String content) async {
    // Update my presence when sending
    // await updateMyPresence();
    
    final response = await _supabase.from('messages').insert({
      'room_id': roomId,
      'sender_id': _currentUserId,
      'content': content,
    }).select('''
      *,
      profiles:sender_id (username, avatar_url)
    ''').single();

    return ChatMessage.fromJson(response);
  }

  @override
  Future<ChatMessage> sendFileMessage(String roomId, File file, {String? caption}) async {
    debugPrint('📤 Sending file message to room: $roomId');
    
    // await updateMyPresence();
    
    try {
      final fileName = path.basename(file.path);
      final fileExt = path.extension(file.path).toLowerCase().replaceAll('.', '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '$roomId/${_currentUserId}_$timestamp.$fileExt';

      String mediaType;
      final imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
      final videoExts = ['mp4', 'mov', 'webm', 'avi', '3gp'];
      final audioExts = ['mp3', 'wav', 'ogg', 'm4a', 'aac'];
      if (imageExts.contains(fileExt)) {
        mediaType = 'image';
      } else if (videoExts.contains(fileExt)) {
        mediaType = 'video';
      } else if (fileExt == 'pdf') {
        mediaType = 'pdf';
      } else if (['doc', 'docx'].contains(fileExt)) {
        mediaType = 'document';
      } else if (['xls', 'xlsx'].contains(fileExt)) {
        mediaType = 'spreadsheet';
      } else if (['ppt', 'pptx'].contains(fileExt)) {
        mediaType = 'presentation';
      } else if (audioExts.contains(fileExt)) {
        mediaType = 'audio';
      } else {
        mediaType = 'file';
      }

      debugPrint('📤 Uploading: $storagePath (type: $mediaType)');

      await _supabase.storage.from('chat-images').uploadBinary(
        storagePath,
        await file.readAsBytes(),
        fileOptions: FileOptions(contentType: _getMimeType(fileExt)),
      );

      final mediaUrl = _supabase.storage.from('chat-images').getPublicUrl(storagePath);

      final response = await _supabase.from('messages').insert({
        'room_id': roomId,
        'sender_id': _currentUserId,
        'content': caption ?? '',
        'media_url': mediaUrl,
        'media_type': mediaType,
        'file_name': fileName,
      }).select('''
        *,
        profiles:sender_id (username, avatar_url)
      ''').single();

      debugPrint('✅ File message sent');
      return ChatMessage.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error sending file: $e');
      rethrow;
    }
  }

  String _getMimeType(String ext) {
    final mimeTypes = {
      'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png',
      'gif': 'image/gif', 'webp': 'image/webp', 'bmp': 'image/bmp',
      'mp4': 'video/mp4', 'mov': 'video/quicktime', 'webm': 'video/webm',
      'avi': 'video/x-msvideo', '3gp': 'video/3gpp',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain', 'csv': 'text/csv',
      'zip': 'application/zip',
      'mp3': 'audio/mpeg', 'wav': 'audio/wav', 'ogg': 'audio/ogg',
      'm4a': 'audio/mp4', 'aac': 'audio/aac',
    };
    return mimeTypes[ext] ?? 'application/octet-stream';
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String roomId) {
    debugPrint('👂 Streaming messages in room: $roomId');
    final controller = StreamController<List<ChatMessage>>();

    _fetchMessages(roomId).then((messages) {
      if (!controller.isClosed) {
        controller.add(messages);
      }
    });

    final channel = _supabase
        .channel('messages:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            debugPrint('📩 Message change: ${payload.eventType}');
            _fetchMessages(roomId).then((messages) {
              if (!controller.isClosed) {
                controller.add(messages);
              }
            });
          },
        )
        .subscribe();

    controller.onCancel = () {
      debugPrint('🛑 Stream cancelled');
      channel.unsubscribe();
    };

    return controller.stream;
  }

  Future<List<ChatMessage>> _fetchMessages(String roomId) async {
    final response = await _supabase
        .from('messages')
        .select('''
          *,
          profiles:sender_id (username, avatar_url)
        ''')
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .limit(100);

    return (response as List).map((json) => ChatMessage.fromJson(json)).toList();
  }

  @override
  Future<void> editMessage(String messageId, String newContent) async {
    debugPrint('✏️ Editing message: $messageId');
    try {
      await _supabase
          .from('messages')
          .update({
            'content': newContent,
            'is_edited': true,
            'edited_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId)
          .eq('sender_id', _currentUserId);
      debugPrint('✅ Message edited');
    } catch (e) {
      debugPrint('❌ Error editing message: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    debugPrint('🗑️ Deleting message: $messageId');
    try {
      await _supabase
          .from('messages')
          .update({
            'is_deleted': true,
            'deleted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId)
          .eq('sender_id', _currentUserId);
      debugPrint('✅ Message deleted');
    } catch (e) {
      debugPrint('❌ Error deleting message: $e');
      rethrow;
    }
  }

  @override
  Future<void> markMessagesAsRead(String roomId) async {
    debugPrint('👁️ Marking messages as read in room: $roomId');
    try {
      // First, get all unread messages from others in this room
      final unreadMessages = await _supabase
          .from('messages')
          .select('id')
          .eq('room_id', roomId)
          .neq('sender_id', _currentUserId)  // Messages FROM others
          .eq('is_read', false)               // That are unread
          .eq('is_deleted', false);
      
      final count = (unreadMessages as List).length;
      debugPrint('📝 Found $count unread messages to mark as read');
      
      if (count == 0) {
        debugPrint('✅ No unread messages');
        return;
      }
      
      // Update all unread messages from others to read
      final result = await _supabase
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('room_id', roomId)
          .neq('sender_id', _currentUserId)
          .eq('is_read', false)
          .select();
      
      debugPrint('✅ Marked ${(result as List).length} messages as read');
    } catch (e) {
      debugPrint('❌ Error marking as read: $e');
      // Don't rethrow - we don't want to break the app if this fails
    }
  }

  @override
  Future<void> setTypingIndicator(String roomId, bool isTyping) async {
    try {
      if (isTyping) {
        await _supabase.from('typing_indicators').upsert({
          'room_id': roomId,
          'user_id': _currentUserId,
          'is_typing': true,
          'started_at': DateTime.now().toIso8601String(),
        }, onConflict: 'room_id,user_id');
      } else {
        await _supabase
            .from('typing_indicators')
            .delete()
            .eq('room_id', roomId)
            .eq('user_id', _currentUserId);
      }
    } catch (e) {
      debugPrint('❌ Error setting typing: $e');
    }
  }

  @override
  Stream<List<String>> streamTypingUsers(String roomId) {
    debugPrint('👂 Streaming typing indicators for room: $roomId');
    final controller = StreamController<List<String>>();

    _fetchTypingUsers(roomId).then((users) {
      if (!controller.isClosed) {
        controller.add(users);
      }
    });

    final channel = _supabase
        .channel('typing:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'typing_indicators',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            debugPrint('⌨️ Typing change detected');
            _fetchTypingUsers(roomId).then((users) {
              if (!controller.isClosed) {
                controller.add(users);
              }
            });
          },
        )
        .subscribe();

    controller.onCancel = () {
      channel.unsubscribe();
    };

    return controller.stream;
  }

  Future<List<String>> _fetchTypingUsers(String roomId) async {
    try {
      final response = await _supabase
          .from('typing_indicators')
          .select('user_id, profiles(username)')
          .eq('room_id', roomId)
          .eq('is_typing', true)
          .neq('user_id', _currentUserId)
          .gt('started_at', DateTime.now().subtract(const Duration(seconds: 10)).toIso8601String());

      final users = (response as List)
          .map((r) => r['profiles']?['username'] as String? ?? 'Someone')
          .toList();
      debugPrint('⌨️ Typing users found: $users');
      return users;
    } catch (e) {
      debugPrint('⚠️ Error fetching typing users: $e');
      return [];
    }
  }

  // // ============================================================
  // // PRESENCE / LAST SEEN
  // // ============================================================
  // @override
  // Future<void> updateMyPresence() async {
  //   try {
  //     await _supabase
  //         .from('profiles')
  //         .update({
  //           'last_seen': DateTime.now().toIso8601String(),
  //           'is_online': true,
  //         })
  //         .eq('id', _currentUserId);
  //   } catch (e) {
  //     debugPrint('❌ Error updating presence: $e');
  //   }
  // }

  // @override
  // Stream<Map<String, dynamic>> streamUserPresence(String userId) {
  //   debugPrint('👂 Streaming presence for user: $userId');
  //   final controller = StreamController<Map<String, dynamic>>();

  //   // Initial fetch
  //   _fetchUserPresence(userId).then((data) {
  //     if (!controller.isClosed && data != null) {
  //       controller.add(data);
  //     }
  //   });

  //   // Subscribe to changes
  //   final channel = _supabase
  //       .channel('presence:$userId')
  //       .onPostgresChanges(
  //         event: PostgresChangeEvent.update,
  //         schema: 'public',
  //         table: 'profiles',
  //         filter: PostgresChangeFilter(
  //           type: PostgresChangeFilterType.eq,
  //           column: 'id',
  //           value: userId,
  //         ),
  //         callback: (payload) {
  //           debugPrint('👤 Presence change for $userId');
  //           if (!controller.isClosed) {
  //             controller.add({
  //               'last_seen': payload.newRecord['last_seen'],
  //               'is_online': payload.newRecord['is_online'],
  //             });
  //           }
  //         },
  //       )
  //       .subscribe();

  //   controller.onCancel = () {
  //     channel.unsubscribe();
  //   };

  //   return controller.stream;
  // }

  // Future<Map<String, dynamic>?> _fetchUserPresence(String userId) async {
  //   try {
  //     final response = await _supabase
  //         .from('profiles')
  //         .select('last_seen, is_online')
  //         .eq('id', userId)
  //         .maybeSingle();
  //     return response;
  //   } catch (e) {
  //     debugPrint('❌ Error getting presence: $e');
  //     return null;
  //   }
  // }

  // ============================================================
  // GROUP CHAT METHODS
  // ============================================================
  
  Future<CreateGroupResponse> createGroup(String name, {String? description}) async {
    debugPrint('👥 Creating group: $name');
    try {
      final response = await _supabase.rpc('create_group_chat', params: {
        'p_name': name,
        'p_description': description,
      }).select().single();

      debugPrint('✅ Group created: ${response['room_id']}');
      return CreateGroupResponse.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error creating group: $e');
      rethrow;
    }
  }

  Future<JoinGroupResponse> joinGroupByCode(String code) async {
    debugPrint('🔑 Joining group with code: $code');
    try {
      final response = await _supabase.rpc('join_group_by_code', params: {
        'p_code': code.trim().toUpperCase(),
      }).select().single();

      debugPrint('✅ Join response: $response');
      return JoinGroupResponse.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error joining group: $e');
      rethrow;
    }
  }

  Future<List<GroupChat>> getMyGroups() async {
    debugPrint('📥 Fetching my groups');
    try {
      final response = await _supabase.rpc('get_my_groups').select();

      final groups = (response as List)
          .map((json) => GroupChat.fromJson(json))
          .toList();

      debugPrint('✅ Fetched ${groups.length} groups');
      return groups;
    } catch (e) {
      debugPrint('❌ Error fetching groups: $e');
      rethrow;
    }
  }

  Future<String> regenerateInviteCode(String roomId) async {
    debugPrint('🔄 Regenerating invite code for room: $roomId');
    try {
      final newCode = await _supabase.rpc('regenerate_invite_code', params: {
        'p_room_id': roomId,
      });

      debugPrint('✅ New code generated: $newCode');
      return newCode as String;
    } catch (e) {
      debugPrint('❌ Error regenerating code: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeMember(String roomId, String userId) async {
    debugPrint('🚫 Removing member $userId from room: $roomId');
    try {
      await _supabase.rpc('remove_member_from_group', params: {
        'target_room_id': roomId,
        'target_user_id': userId,
      });
      debugPrint('✅ Member removed successfully');
    } catch (e) {
      debugPrint('❌ Error removing member: $e');
      rethrow;
    }
  }
}
