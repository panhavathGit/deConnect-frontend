import 'package:flutter/material.dart';
import '../data/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repo = ChatRepository();
  
  // Logic to enter a room
  Future<void> openChatWithUser(String userId, Function(String roomId) onSuccess) async {
    try {
      final roomId = await _repo.getOrCreatePrivateRoom(userId);
      onSuccess(roomId); // Callback to UI to navigate
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> sendMessage(String roomId, String text) async {
    if (text.trim().isEmpty) return;
    await _repo.sendMessage(roomId, text);
  }

  // Expose the Repo's stream directly or process it here
  Stream<List<Map<String, dynamic>>> getMessages(String roomId) {
    return _repo.getMessagesStream(roomId);
  }
}