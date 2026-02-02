// lib/features/chat/viewmodels/your_groups_viewmodel.dart

import 'package:flutter/material.dart';
import '../data/repositories/chat_repository.dart';
import '../data/models/group_chat_model.dart';

class YourGroupsViewModel extends ChangeNotifier {
  final ChatRepository repository;

  YourGroupsViewModel({required this.repository});

  List<GroupChat> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GroupChat> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadGroups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = await repository.getMyGroups();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load groups: ${e.toString()}';
      debugPrint('❌ Error loading groups: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}