// lib/features/chat/viewmodels/create_group_viewmodel.dart

import 'package:flutter/material.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/group_chat_model.dart';

enum CreateGroupStatus { initial, loading, success, error }

class CreateGroupViewModel extends ChangeNotifier {
  final ChatRepository repository;

  CreateGroupViewModel({required this.repository});

  CreateGroupStatus _status = CreateGroupStatus.initial;
  String? _errorMessage;
  CreateGroupResponse? _createdGroup;

  CreateGroupStatus get status => _status;
  bool get isLoading => _status == CreateGroupStatus.loading;
  String? get errorMessage => _errorMessage;
  CreateGroupResponse? get createdGroup => _createdGroup;

  Future<bool> createGroup(String name, {String? description}) async {
    _status = CreateGroupStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _createdGroup = await repository.createGroup(name, description: description);
      _status = CreateGroupStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = CreateGroupStatus.error;
      _errorMessage = e.toString();
      debugPrint('❌ Error creating group: $e');
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = CreateGroupStatus.initial;
    _errorMessage = null;
    _createdGroup = null;
    notifyListeners();
  }
}