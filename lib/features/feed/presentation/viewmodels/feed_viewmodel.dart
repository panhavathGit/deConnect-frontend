// lib/features/feed/presentation/viewmodels/feed_viewmodel.dart
import 'package:flutter/material.dart';
import '../../data/models/feed_model.dart';
import '../../data/repositories/feed_repository.dart';

enum FeedStatus { initial, loading, success, error }

class FeedViewModel extends ChangeNotifier {
  final FeedRepository repository;

  FeedViewModel({required this.repository});

  List<FeedPost> _posts = [];
  FeedStatus _status = FeedStatus.initial;
  String? _errorMessage;
  String _selectedCategory = 'All';

  // Getters
  List<FeedPost> get posts => _posts;
  FeedStatus get status => _status;
  bool get isLoading => _status == FeedStatus.loading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  Future<void> loadPosts({String? category}) async {
    _status = FeedStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await repository.getPosts(category: category);
      _status = FeedStatus.success;
    } catch (e) {
      _status = FeedStatus.error;
      _errorMessage = 'Failed to load posts: ${e.toString()}';
      _posts = [];
      debugPrint("Error loading feed: $e");
    }

    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    loadPosts(category: category == 'All' ? null : category);
  }

  Future<FeedPost?> getPostById(String id) async {
    try {
      return await repository.getPostById(id);
    } catch (e) {
      debugPrint("Error loading post: $e");
      return null;
    }
  }
}