// lib/features/chat/data/repositories/chat_repository_impl.dart
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import 'chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatRoom>> getChatRooms() async {
    return await remoteDataSource.getChatRooms();
  }

  @override
  Future<ChatRoom> getOrCreateDirectRoom(String otherUserId) async {
    return await remoteDataSource.getOrCreateDirectRoom(otherUserId);
  }

  @override
  Future<List<ChatMessage>> getMessages(String roomId) async {
    return await remoteDataSource.getMessages(roomId);
  }

  @override
  Future<ChatMessage> sendMessage(String roomId, String content) async {
    return await remoteDataSource.sendMessage(roomId, content);
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String roomId) {  // ← CHANGED
    return remoteDataSource.streamMessages(roomId);  // ← CHANGED
  }
}