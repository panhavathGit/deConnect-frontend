// lib/features/chat/viewmodels/select_user_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/chat_room_model.dart';

enum SelectUserStatus { initial, loading, success, error }

class SelectUserViewModel extends ChangeNotifier {
  final ProfileRemoteDataSource profileDataSource;
  final ChatRepository chatRepository;

  SelectUserViewModel({
    required this.profileDataSource,
    required this.chatRepository,
  });

  List<User> _users = [];
  SelectUserStatus _status = SelectUserStatus.initial;
  String? _errorMessage;

  List<User> get users => _users;
  SelectUserStatus get status => _status;
  bool get isLoading => _status == SelectUserStatus.loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _status = SelectUserStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await profileDataSource.getAllUsers();
      _status = SelectUserStatus.success;
    } catch (e) {
      _status = SelectUserStatus.error;
      _errorMessage = 'Failed to load users: ${e.toString()}';
      _users = [];
      debugPrint("❌ Error loading users: $e");
    }

    notifyListeners();
  }

  Future<ChatRoom?> createChatWithUser(String userId) async {
    try {
      debugPrint("💬 Creating chat room with user: $userId");
      final room = await chatRepository.getOrCreateDirectRoom(userId);
      return room;
    } catch (e) {
      _errorMessage = 'Failed to create chat: ${e.toString()}';
      notifyListeners();
      debugPrint("❌ Error creating chat: $e");
      return null;
    }
  }
}
