// lib/features/chat/viewmodels/chat_list_viewmodel.dart

import 'package:onboarding_project/core/app_export.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../chat.dart';

enum ChatListStatus { initial, loading, success, error }

class ChatListViewModel extends ChangeNotifier {
  final ChatRepository repository;
  
  ChatListViewModel({required this.repository});

  List<ChatRoom> _chatRooms = [];
  ChatListStatus _status = ChatListStatus.initial;
  String? _errorMessage;
  
  // Realtime subscription
  RealtimeChannel? _messagesChannel;
  final _supabase = Supabase.instance.client;

  List<ChatRoom> get chatRooms => _chatRooms;
  ChatListStatus get status => _status;
  bool get isLoading => _status == ChatListStatus.loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadChatRooms({bool forceRefresh = false}) async {
    _status = ChatListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _chatRooms = await repository.getChatRooms();
      _status = ChatListStatus.success;
      
      // Start listening to realtime changes
      _subscribeToMessages();
    } catch (e) {
      _status = ChatListStatus.error;
      _errorMessage = 'Failed to load chats: ${e.toString()}';
      _chatRooms = [];
      debugPrint('❌ Error loading chat rooms: $e');
    }

    notifyListeners();
  }

  // Subscribe to realtime message changes to update chat list
  void _subscribeToMessages() {
    _messagesChannel?.unsubscribe();
    
    _messagesChannel = _supabase
        .channel('chat_list_messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            debugPrint('📩 Chat list: New message detected, refreshing...');
            _refreshChatRooms();
          },
        )
        .subscribe();
    
    debugPrint('👂 Subscribed to chat list updates');
  }

  // Refresh without showing loading indicator
  Future<void> _refreshChatRooms() async {
    try {
      _chatRooms = await repository.getChatRooms();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error refreshing chat rooms: $e');
    }
  }

  Future<ChatRoom?> createDirectRoom(String otherUserId) async {
  try {
    final room = await repository.getOrCreateDirectRoom(otherUserId);
    
    // DON'T reload all rooms - just add the new room to the list
    if (room != null) {
      // Check if room already exists in list
      final existingIndex = _chatRooms.indexWhere((r) => r.id == room.id);
      if (existingIndex == -1) {
        // Add new room at top
        _chatRooms.insert(0, room);
      }
      _status = ChatListStatus.success;
      notifyListeners();
    }
    
    return room;
  } catch (e) {
    _errorMessage = 'Failed to create chat: ${e.toString()}';
    notifyListeners();
    debugPrint('❌ Error creating room: $e');
    return null;
  }
}


  Future<void> refresh() async {
    debugPrint('🔄 Manual refresh triggered');
    try {
      _chatRooms = await repository.getChatRooms();
      _status = ChatListStatus.success;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error refreshing: $e');
    }
  }

  @override
  void dispose() {
    _messagesChannel?.unsubscribe();
    super.dispose();
  }
}
