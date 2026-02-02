// // lib/features/chat/data/repositories/chat_repository.dart

// import 'dart:io';
// import '../models/chat_room_model.dart';
// import '../models/message_model.dart';

// abstract class ChatRepository {
//   String get currentUserId;
//   Future<List<ChatRoom>> getChatRooms();
//   Future<ChatRoom?> getOrCreateDirectRoom(String otherUserId);
//   Future<void> sendMessage(String roomId, String content);
//   Future<void> sendFileMessage(String roomId, File file, {String? caption});
//   Stream<List<ChatMessage>> streamMessages(String roomId);
//   Future<void> editMessage(String messageId, String newContent);
//   Future<void> deleteMessage(String messageId);
//   Future<void> markMessagesAsRead(String roomId);
//   Future<void> setTypingIndicator(String roomId, bool isTyping);
//   Stream<List<String>> streamTypingUsers(String roomId);
//   // NEW: Presence
//   Stream<Map<String, dynamic>> streamUserPresence(String userId);
// }
// lib/features/chat/data/repositories/chat_repository.dart

import 'dart:io';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../models/group_chat_model.dart';

abstract class ChatRepository {
  String get currentUserId;
  Future<List<ChatRoom>> getChatRooms();
  Future<ChatRoom?> getOrCreateDirectRoom(String otherUserId);
  Future<void> sendMessage(String roomId, String content);
  Future<void> sendFileMessage(String roomId, File file, {String? caption});
  Stream<List<ChatMessage>> streamMessages(String roomId);
  Future<void> editMessage(String messageId, String newContent);
  Future<void> deleteMessage(String messageId);
  Future<void> markMessagesAsRead(String roomId);
  Future<void> setTypingIndicator(String roomId, bool isTyping);
  Stream<List<String>> streamTypingUsers(String roomId);
  Stream<Map<String, dynamic>> streamUserPresence(String userId);
  
  // Group Chat Methods
  Future<CreateGroupResponse> createGroup(String name, {String? description});
  Future<JoinGroupResponse> joinGroupByCode(String code);
  Future<List<GroupChat>> getMyGroups();
  Future<String> regenerateInviteCode(String roomId);
}