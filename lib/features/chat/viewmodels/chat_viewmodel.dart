import 'package:flutter/material.dart';
import '../data/mock_chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final MockChatRepository _repo = MockChatRepository();
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoadingRooms = false;

  List<Map<String, dynamic>> get rooms => _rooms;
  bool get isLoadingRooms => _isLoadingRooms;

  // Load all chat rooms
  Future<void> loadRooms() async {
    _isLoadingRooms = true;
    notifyListeners();
    try {
      _rooms = await _repo.getMyRooms();
    } catch (e) {
      debugPrint("Error loading rooms: $e");
    } finally {
      _isLoadingRooms = false;
      notifyListeners();
    }
  }
  
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

  @override
  void dispose() {
    _repo.dispose();
    super.dispose();
  }
}