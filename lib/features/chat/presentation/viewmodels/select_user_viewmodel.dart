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

  List<User> _allUsers = [];
  String _searchQuery = '';

  SelectUserStatus _status = SelectUserStatus.initial;
  String? _errorMessage;

  // List<User> get users => _users;
  SelectUserStatus get status => _status;
  bool get isLoading => _status == SelectUserStatus.loading;
  String? get errorMessage => _errorMessage;

  List<User> get users {
    if (_searchQuery.isEmpty) {
      return _allUsers;
    }
    return _allUsers.where((user) {
      final name = user.name.toLowerCase();
      final bio = user.bio?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || bio.contains(query);
    }).toList();
  }

  String get searchQuery => _searchQuery;

  // Future<void> loadUsers() async {
  //   _status = SelectUserStatus.loading;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     _users = await profileDataSource.getAllUsers();
  //     _status = SelectUserStatus.success;
  //   } catch (e) {
  //     _status = SelectUserStatus.error;
  //     _errorMessage = 'Failed to load users: ${e.toString()}';
  //     _users = [];
  //     debugPrint("❌ Error loading users: $e");
  //   }

  //   notifyListeners();
  // }

  // Update the loadUsers method to store all users
  Future<void> loadUsers() async {
    _status = SelectUserStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _allUsers = await profileDataSource.getAllUsers();
      _status = SelectUserStatus.success;
    } catch (e) {
      _status = SelectUserStatus.error;
      _errorMessage = 'Failed to load users: ${e.toString()}';
      _allUsers = [];
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

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
