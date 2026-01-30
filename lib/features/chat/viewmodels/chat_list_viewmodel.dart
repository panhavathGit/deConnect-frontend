// lib/features/chat/viewmodels/chat_list_viewmodel.dart
import 'package:flutter/material.dart';
import '../data/models/chat_room_model.dart';
import '../data/repositories/chat_repository.dart';

enum ChatListStatus { initial, loading, success, error }

class ChatListViewModel extends ChangeNotifier {
  final ChatRepository repository;

  ChatListViewModel({required this.repository});

  List<ChatRoom> _chatRooms = [];
  ChatListStatus _status = ChatListStatus.initial;
  String? _errorMessage;

  List<ChatRoom> get chatRooms => _chatRooms;
  ChatListStatus get status => _status;
  bool get isLoading => _status == ChatListStatus.loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadChatRooms() async {
    _status = ChatListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _chatRooms = await repository.getChatRooms();
      _status = ChatListStatus.success;
    } catch (e) {
      _status = ChatListStatus.error;
      _errorMessage = 'Failed to load chats: ${e.toString()}';
      _chatRooms = [];
      debugPrint("❌ Error loading chat rooms: $e");
    }

    notifyListeners();
  }

  Future<ChatRoom?> createDirectRoom(String otherUserId) async {
    try {
      final room = await repository.getOrCreateDirectRoom(otherUserId);
      // Reload chat rooms to include the new one
      await loadChatRooms();
      return room;
    } catch (e) {
      _errorMessage = 'Failed to create chat: ${e.toString()}';
      notifyListeners();
      debugPrint("❌ Error creating room: $e");
      return null;
    }
  }

  Future<void> refresh() async {
    await loadChatRooms();
  }
}