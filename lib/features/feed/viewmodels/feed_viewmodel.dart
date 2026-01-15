import 'package:flutter/material.dart';
import '../data/feed_repository.dart';
import '../data/feed_model.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedRepository _repo = FeedRepository();
  List<FeedPost> _posts = [];
  bool _isLoading = true;

  List<FeedPost> get posts => _posts;
  bool get isLoading => _isLoading;

  void loadPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _posts = await _repo.fetchPosts();
    } catch (e) {
      debugPrint("Error loading feed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}