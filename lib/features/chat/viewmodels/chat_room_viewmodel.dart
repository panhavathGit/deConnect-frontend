// lib/features/chat/viewmodels/chat_room_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/message_model.dart';
import '../data/repositories/chat_repository.dart';
import '../../../core/services/supabase_service.dart';

enum ChatRoomStatus { initial, loading, success, error }

class ChatRoomViewModel extends ChangeNotifier {
  final ChatRepository repository;
  final String roomId;

  ChatRoomViewModel({
    required this.repository,
    required this.roomId,
  });

  List<ChatMessage> _messages = [];
  ChatRoomStatus _status = ChatRoomStatus.initial;
  String? _errorMessage;
  bool _isSending = false;
  StreamSubscription? _messageSubscription;

  List<ChatMessage> get messages => _messages;
  ChatRoomStatus get status => _status;
  bool get isLoading => _status == ChatRoomStatus.loading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  String get currentUserId => SupabaseService.client.auth.currentUser?.id ?? '';

  Future<void> loadMessages() async {
    debugPrint('🔄 Starting to load and stream messages for room: $roomId');
    _status = ChatRoomStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Start streaming messages
      _subscribeToMessages();
      _status = ChatRoomStatus.success;
      debugPrint('✅ Successfully started streaming messages');
    } catch (e, stackTrace) {
      _status = ChatRoomStatus.error;
      _errorMessage = 'Failed to load messages: ${e.toString()}';
      _messages = [];
      debugPrint("❌ Error loading messages: $e");
      debugPrint("Stack trace: $stackTrace");
    }

    debugPrint('📢 Notifying listeners with status: $_status');
    notifyListeners();
  }

  void _subscribeToMessages() {
    _messageSubscription?.cancel();
    
    _messageSubscription = repository.streamMessages(roomId).listen(
      (messagesList) {
        debugPrint("📨 Received ${messagesList.length} messages from stream");
        _messages = messagesList;
        if (_status == ChatRoomStatus.loading) {
          _status = ChatRoomStatus.success;
        }
        notifyListeners();
      },
      onError: (error) {
        debugPrint("❌ Real-time stream error: $error");
        _status = ChatRoomStatus.error;
        _errorMessage = 'Stream error: $error';
        notifyListeners();
      },
    );
  }

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty) return false;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final message = await repository.sendMessage(roomId, content);
      
      // Message will be added automatically by the stream
      // No need to manually add it here
      
      _isSending = false;
      notifyListeners();
      
      debugPrint("✅ Message sent successfully");
      return true;
    } catch (e) {
      _isSending = false;
      _errorMessage = 'Failed to send message: ${e.toString()}';
      notifyListeners();
      
      debugPrint("❌ Error sending message: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}