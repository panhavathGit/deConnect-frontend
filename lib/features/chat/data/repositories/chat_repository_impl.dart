// // lib/features/chat/data/repositories/chat_repository_impl.dart

// import 'dart:io';
// import '../datasources/chat_remote_data_source.dart';
// import '../models/chat_room_model.dart';
// import '../models/message_model.dart';
// import 'chat_repository.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ChatRepositoryImpl implements ChatRepository {
//   final ChatRemoteDataSource remoteDataSource;

//   ChatRepositoryImpl({required this.remoteDataSource});

//   @override
//   String get currentUserId => Supabase.instance.client.auth.currentUser!.id;

//   @override
//   Future<List<ChatRoom>> getChatRooms() => remoteDataSource.getChatRooms();

//   @override
//   Future<ChatRoom?> getOrCreateDirectRoom(String otherUserId) =>
//       remoteDataSource.createDirectChat(otherUserId);

//   @override
//   Future<void> sendMessage(String roomId, String content) =>
//       remoteDataSource.sendMessage(roomId, content);

//   @override
//   Future<void> sendFileMessage(String roomId, File file, {String? caption}) =>
//       remoteDataSource.sendFileMessage(roomId, file, caption: caption);

//   @override
//   Stream<List<ChatMessage>> streamMessages(String roomId) =>
//       remoteDataSource.streamMessages(roomId);

//   @override
//   Future<void> editMessage(String messageId, String newContent) =>
//       remoteDataSource.editMessage(messageId, newContent);

//   @override
//   Future<void> deleteMessage(String messageId) =>
//       remoteDataSource.deleteMessage(messageId);

//   @override
//   Future<void> markMessagesAsRead(String roomId) =>
//       remoteDataSource.markMessagesAsRead(roomId);

//   @override
//   Future<void> setTypingIndicator(String roomId, bool isTyping) =>
//       remoteDataSource.setTypingIndicator(roomId, isTyping);

//   @override
//   Stream<List<String>> streamTypingUsers(String roomId) =>
//       remoteDataSource.streamTypingUsers(roomId);

//   @override
//   Stream<Map<String, dynamic>> streamUserPresence(String userId) =>
//       remoteDataSource.streamUserPresence(userId);
// }


// lib/features/chat/data/repositories/chat_repository_impl.dart

import 'dart:io';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../models/group_chat_model.dart';
import 'chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  String get currentUserId => Supabase.instance.client.auth.currentUser!.id;

  @override
  Future<List<ChatRoom>> getChatRooms() => remoteDataSource.getChatRooms();

  @override
  Future<ChatRoom?> getOrCreateDirectRoom(String otherUserId) =>
      remoteDataSource.createDirectChat(otherUserId);

  @override
  Future<void> sendMessage(String roomId, String content) =>
      remoteDataSource.sendMessage(roomId, content);

  @override
  Future<void> sendFileMessage(String roomId, File file, {String? caption}) =>
      remoteDataSource.sendFileMessage(roomId, file, caption: caption);

  @override
  Stream<List<ChatMessage>> streamMessages(String roomId) =>
      remoteDataSource.streamMessages(roomId);

  @override
  Future<void> editMessage(String messageId, String newContent) =>
      remoteDataSource.editMessage(messageId, newContent);

  @override
  Future<void> deleteMessage(String messageId) =>
      remoteDataSource.deleteMessage(messageId);

  @override
  Future<void> markMessagesAsRead(String roomId) =>
      remoteDataSource.markMessagesAsRead(roomId);

  @override
  Future<void> setTypingIndicator(String roomId, bool isTyping) =>
      remoteDataSource.setTypingIndicator(roomId, isTyping);

  @override
  Stream<List<String>> streamTypingUsers(String roomId) =>
      remoteDataSource.streamTypingUsers(roomId);

  @override
  Stream<Map<String, dynamic>> streamUserPresence(String userId) =>
      remoteDataSource.streamUserPresence(userId);

  // Group Chat Methods
  @override
  Future<CreateGroupResponse> createGroup(String name, {String? description}) =>
      remoteDataSource.createGroup(name, description: description);

  @override
  Future<JoinGroupResponse> joinGroupByCode(String code) =>
      remoteDataSource.joinGroupByCode(code);

  @override
  Future<List<GroupChat>> getMyGroups() => remoteDataSource.getMyGroups();

  @override
  Future<String> regenerateInviteCode(String roomId) =>
      remoteDataSource.regenerateInviteCode(roomId);
}