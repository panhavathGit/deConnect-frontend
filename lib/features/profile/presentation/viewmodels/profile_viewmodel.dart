// lib/features/profile/viewmodels/profile_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/profile_status.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../feed/data/models/feed_model.dart';
import '../../../feed/data/repositories/feed_repository.dart';
import '../../../feed/data/repositories/feed_repository_impl.dart';
import '../../../feed/data/datasources/feed_remote_data_source.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository repository;
  final String userId;
  late final FeedRepository _feedRepository;

  ProfileViewModel({
    required this.repository,
    required this.userId,
  }) {
    _feedRepository = FeedRepositoryImpl(
      remoteDataSource: FeedRemoteDataSourceImpl(),
    );
  }

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

  Future<bool> deletePost(String postId) async {
    try {
      await _feedRepository.deletePost(postId);
      _userPosts.removeWhere((post) => post.id == postId);
      if (_stats != null) {
        _stats = ProfileStats(
          postsCount: _stats!.postsCount - 1,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting post: $e");
      return false;
    }
  }

  Future<bool> updatePost(FeedPost updatedPost) async {
    try {
      await _feedRepository.updatePost(updatedPost);
      final index = _userPosts.indexWhere((post) => post.id == updatedPost.id);
      if (index != -1) {
        _userPosts[index] = updatedPost;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error updating post: $e");
      return false;
    }
  }

  Future<void> refresh() async {
    await loadProfile();
  }
}