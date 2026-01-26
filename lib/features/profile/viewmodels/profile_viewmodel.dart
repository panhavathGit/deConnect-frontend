// lib/features/profile/viewmodels/profile_viewmodel.dart
import 'package:flutter/material.dart';
import '../../auth/data/models/user_model.dart';
import '../data/models/profile_status.dart';
import '../data/repositories/profile_repository.dart';
import '../../feed/data/models/feed_model.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository repository;
  final String userId;

  ProfileViewModel({
    required this.repository,
    required this.userId,
  });

  User? _user;
  ProfileStats? _stats;
  List<FeedPost> _userPosts = [];
  ProfileStatus _status = ProfileStatus.initial;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  ProfileStats? get stats => _stats;
  List<FeedPost> get userPosts => _userPosts;
  ProfileStatus get status => _status;
  bool get isLoading => _status == ProfileStatus.loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await repository.getUserProfile(userId);
      _stats = await repository.getProfileStats(userId);
      _userPosts = await repository.getUserPosts(userId);
      _status = ProfileStatus.success;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = 'Failed to load profile: ${e.toString()}';
      debugPrint("Error loading profile: $e");
    }

    notifyListeners();
  }

  Future<void> updateProfile(User user) async {
    try {
      await repository.updateProfile(user);
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating profile: $e");
      rethrow;
    }
  }

  Future<void> refresh() async {
    await loadProfile();
  }
}