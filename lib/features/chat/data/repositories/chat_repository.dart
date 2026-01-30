// lib/features/chat/data/repositories/chat_repository.dart
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

abstract class ChatRepository {
  Future<List<ChatRoom>> getChatRooms();
  Future<ChatRoom> getOrCreateDirectRoom(String otherUserId);
  Future<List<ChatMessage>> getMessages(String roomId);
  Future<ChatMessage> sendMessage(String roomId, String content);
  Stream<List<ChatMessage>> streamMessages(String roomId);
}