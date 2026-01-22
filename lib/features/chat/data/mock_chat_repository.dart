import 'dart:async';
import '../../../core/mock/mock_data.dart';

class MockChatRepository {
  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Get or create a private room with another user
  Future<String> getOrCreatePrivateRoom(String targetUserId) async {
    await _simulateDelay();
    
    // Find existing room with this user
    final existingRoom = MockData.rooms.firstWhere(
      (room) => room.memberIds.contains(targetUserId) && room.memberIds.contains(MockData.currentUser.id),
      orElse: () {
        // Create new room if doesn't exist
        final newRoom = MockRoom(
          id: 'room-${DateTime.now().millisecondsSinceEpoch}',
          name: MockData.users.firstWhere((u) => u.id == targetUserId).username,
          lastMessage: null,
          lastMessageTime: null,
          memberIds: [MockData.currentUser.id, targetUserId],
        );
        MockData.rooms.add(newRoom);
        MockData.messagesByRoom[newRoom.id] = [];
        return newRoom;
      },
    );
    
    return existingRoom.id;
  }

  // Get all rooms for current user
  Future<List<Map<String, dynamic>>> getMyRooms() async {
    await _simulateDelay();
    
    return MockData.rooms
        .where((room) => room.memberIds.contains(MockData.currentUser.id))
        .map((room) => room.toMap())
        .toList();
  }

  // Send a message
  Future<void> sendMessage(String roomId, String content) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newMessage = MockMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: MockData.currentUser.id,
      content: content,
      createdAt: DateTime.now(),
    );
    
    // Add message to the room
    if (MockData.messagesByRoom.containsKey(roomId)) {
      MockData.messagesByRoom[roomId]!.add(newMessage);
    } else {
      MockData.messagesByRoom[roomId] = [newMessage];
    }
    
    // Update room's last message
    final roomIndex = MockData.rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      final room = MockData.rooms[roomIndex];
      MockData.rooms[roomIndex] = MockRoom(
        id: room.id,
        name: room.name,
        lastMessage: content,
        lastMessageTime: DateTime.now(),
        memberIds: room.memberIds,
      );
    }
    
    // Trigger stream update
    _messageStreamController.add(roomId);
  }

  // Stream controller for realtime updates
  final _messageStreamController = StreamController<String>.broadcast();

  // Get messages stream for a room (simulated realtime)
  Stream<List<Map<String, dynamic>>> getMessagesStream(String roomId) async* {
    // Yield initial messages
    final messages = MockData.messagesByRoom[roomId] ?? [];
    yield messages.reversed.map((msg) => msg.toMap()).toList();
    
    // Listen for new messages
    await for (final updatedRoomId in _messageStreamController.stream) {
      if (updatedRoomId == roomId) {
        final updatedMessages = MockData.messagesByRoom[roomId] ?? [];
        yield updatedMessages.reversed.map((msg) => msg.toMap()).toList();
      }
    }
  }

  // Clean up
  void dispose() {
    _messageStreamController.close();
  }
}
