// // // lib/features/feed/presentation/viewmodels/feed_viewmodel.dart
import 'package:flutter/material.dart';
import '../../data/models/feed_model.dart';
import '../../data/repositories/feed_repository.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// enum FeedStatus { initial, loading, success, error }

// class FeedViewModel extends ChangeNotifier {
//   final FeedRepository repository;

//   FeedViewModel({required this.repository});

//   List<FeedPost> _posts = [];
//   FeedStatus _status = FeedStatus.initial;
//   String? _errorMessage;
//   String _selectedCategory = 'All';

//   // Getters
//   List<FeedPost> get posts => _posts;
//   FeedStatus get status => _status;
//   bool get isLoading => _status == FeedStatus.loading;
//   String? get errorMessage => _errorMessage;
//   String get selectedCategory => _selectedCategory;

//   Future<void> loadPosts({String? category}) async {
//     _status = FeedStatus.loading;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       _posts = await repository.getPosts(category: category);
//       _status = FeedStatus.success;
//     } catch (e) {
//       _status = FeedStatus.error;
//       _errorMessage = 'Failed to load posts: ${e.toString()}';
//       _posts = [];
//       debugPrint("Error loading feed: $e");
//     }

//     notifyListeners();
//   }

//   void filterByCategory(String category) {
//     _selectedCategory = category;
//     loadPosts(category: category == 'All' ? null : category);
//   }

//   Future<FeedPost?> getPostById(String id) async {
//     try {
//       return await repository.getPostById(id);
//     } catch (e) {
//       debugPrint("Error loading post: $e");
//       return null;
//     }
//   }
// }


enum FeedStatus { initial, loading, success, error }

class FeedViewModel extends ChangeNotifier {
  final FeedRepository repository;
  late final PagingController<int, FeedPost> pagingController;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  static const int _pageSize = 10; // Items per page

  FeedViewModel({required this.repository}) {
    pagingController = PagingController(
      fetchPage: _fetchPage,
      getNextPageKey: (state) {
        // If no pages fetched yet, start at page 0
        if (state.pages == null || state.pages!.isEmpty) {
          return 0;
        }
        
        // If the last page was empty, no more pages
        if (state.lastPageIsEmpty) return null;
        
        // If the last page had fewer items than the page size, we've reached the end
        final lastPage = state.pages?.lastOrNull;
        if (lastPage != null && lastPage.length < _pageSize) {
          return null; // No more pages
        }
        
        // Otherwise, fetch the next page
        return state.nextIntPageKey;
      },
    );
  }

  Future<List<FeedPost>> _fetchPage(int pageKey) async {
    try {
      debugPrint('📄 Fetching page $pageKey (offset: ${pageKey * _pageSize}, limit: $_pageSize)');
      
      // Add a small delay to make loading indicator visible (remove in production if not needed)
      await Future.delayed(const Duration(milliseconds: 500));
      
      final newItems = await repository.getPosts(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        offset: pageKey * _pageSize, // Convert page number to offset
        limit: _pageSize,
      );
      
      debugPrint('✅ Fetched ${newItems.length} posts for page $pageKey');
      return newItems;
    } catch (e) {
      debugPrint("Error loading feed: $e");
      rethrow;
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    pagingController.refresh();
  }

  Future<FeedPost?> getPostById(String id) async {
    try {
      return await repository.getPostById(id);
    } catch (e) {
      debugPrint("Error loading post: $e");
      return null;
    }
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }
}


        
