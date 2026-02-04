// lib/features/chat/viewmodels/chat_room_viewmodel.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';

enum ChatRoomStatus { initial, loading, success, error }

class ChatRoomViewModel extends ChangeNotifier {
  final ChatRepository repository;
  final String roomId;
  final String? otherUserId;
  final String? initialLastSeenText;
  final bool initialIsOnline;

  ChatRoomViewModel({
    required this.repository,
    required this.roomId,
    this.otherUserId,
    this.initialLastSeenText,
    this.initialIsOnline = false,
  });

  ChatRoomStatus _status = ChatRoomStatus.initial;
  List<ChatMessage> _messages = [];
  String? _errorMessage;
  bool _isSending = false;
  bool _isUploadingImage = false;
  List<String> _typingUsers = [];
  
  // Presence tracking
  String _otherUserStatus = '';
  bool _isOtherUserOnline = false;

  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<List<String>>? _typingSubscription;
  StreamSubscription<Map<String, dynamic>>? _presenceSubscription;
  Timer? _typingTimer;

  ChatRoomStatus get status => _status;
  List<ChatMessage> get messages => _messages;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ChatRoomStatus.loading;
  bool get isSending => _isSending;
  bool get isUploadingImage => _isUploadingImage;
  String get currentUserId => repository.currentUserId;
  List<String> get typingUsers => _typingUsers;
  bool get isOtherUserTyping => _typingUsers.isNotEmpty;
  
  // Presence getters
  String get otherUserStatus {
    if (_isOtherUserOnline) return 'online';
    if (_otherUserStatus.isNotEmpty) return _otherUserStatus;
    return initialLastSeenText ?? '';
  }
  bool get isOtherUserOnline => _isOtherUserOnline || initialIsOnline;

  Future<void> loadMessages() async {
    debugPrint('🔄 Starting to load and stream messages for room: $roomId');
    _status = ChatRoomStatus.loading;
    _errorMessage = null;
    
    _otherUserStatus = initialLastSeenText ?? '';
    _isOtherUserOnline = initialIsOnline;
    
    notifyListeners();

    try {
      // IMPORTANT: Mark messages as read FIRST when entering the chat
      await _markAsRead();
      
      await _messagesSubscription?.cancel();
      _messagesSubscription = repository.streamMessages(roomId).listen(
        (messages) {
          debugPrint('📨 Received ${messages.length} messages from stream');
          _messages = messages;
          _status = ChatRoomStatus.success;
          notifyListeners();
          
          // Also mark as read when new messages come in (in case we're in the chat)
          _markAsRead();
        },
        onError: (error) {
          debugPrint('❌ Stream error: $error');
          _errorMessage = error.toString();
          _status = ChatRoomStatus.error;
          notifyListeners();
        },
      );

      // Stream typing indicators
      await _typingSubscription?.cancel();
      _typingSubscription = repository.streamTypingUsers(roomId).listen(
        (users) {
          debugPrint('⌨️ Typing users: $users');
          _typingUsers = users;
          notifyListeners();
        },
      );
      
      // Stream presence
      // if (otherUserId != null) {
      //   await _presenceSubscription?.cancel();
      //   _presenceSubscription = repository.streamUserPresence(otherUserId!).listen(
      //     (data) {
      //       _updatePresenceStatus(data);
      //     },
      //   );
      // }

      _status = ChatRoomStatus.success;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading messages: $e');
      _errorMessage = e.toString();
      _status = ChatRoomStatus.error;
      notifyListeners();
    }
  }

  void _updatePresenceStatus(Map<String, dynamic> data) {
    final isOnline = data['is_online'] ?? false;
    _isOtherUserOnline = isOnline;
    
    if (isOnline) {
      _otherUserStatus = 'online';
    } else if (data['last_seen'] != null) {
      final lastSeen = DateTime.parse(data['last_seen']);
      _otherUserStatus = _formatLastSeen(lastSeen);
    }
    notifyListeners();
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inMinutes < 1) return 'last seen just now';
    if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'last seen ${diff.inHours}h ago';
    if (diff.inDays == 1) return 'last seen yesterday';
    if (diff.inDays < 7) return 'last seen ${diff.inDays}d ago';
    return 'last seen recently';
  }

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty) return false;
    _isSending = true;
    notifyListeners();

    // Stop typing indicator
    _setTyping(false);

    try {
      await repository.sendMessage(roomId, content);
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      _errorMessage = e.toString();
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendFileMessage(File file, {String? caption}) async {
    debugPrint('📤 Uploading and sending file...');
    _isUploadingImage = true;
    notifyListeners();
    try {
      await repository.sendFileMessage(roomId, file, caption: caption);
      debugPrint('✅ File message sent successfully');
      _isUploadingImage = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error sending file: $e');
      _errorMessage = e.toString();
      _isUploadingImage = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editMessage(String messageId, String newContent) async {
    try {
      await repository.editMessage(messageId, newContent);
      debugPrint('✅ Message edited');
      return true;
    } catch (e) {
      debugPrint('❌ Error editing message: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMessage(String messageId) async {
    try {
      await repository.deleteMessage(messageId);
      debugPrint('✅ Message deleted');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting message: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _markAsRead() async {
    try {
      debugPrint('🔄 Calling markMessagesAsRead...');
      await repository.markMessagesAsRead(roomId);
      debugPrint('✅ markMessagesAsRead completed');
    } catch (e) {
      debugPrint('❌ Error marking as read: $e');
    }
  }

  void onTyping() {
    _setTyping(true);
    // Reset typing timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _setTyping(false);
    });
  }

  Future<void> _setTyping(bool isTyping) async {
    try {
      await repository.setTypingIndicator(roomId, isTyping);
    } catch (e) {
      debugPrint('❌ Error setting typing: $e');
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _presenceSubscription?.cancel();
    _typingTimer?.cancel();
    _setTyping(false);
    super.dispose();
  }
}
