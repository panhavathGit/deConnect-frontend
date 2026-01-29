// lib/features/feed/presentation/viewmodels/create_post_viewmodel.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/services/supabase_service.dart';

class CreatePostViewModel extends ChangeNotifier {
  File? _selectedImage;
  List<String> _selectedTags = [];  // Changed from category
  bool _isLoading = false;
  String? _errorMessage;

  File? get selectedImage => _selectedImage;
  List<String> get selectedTags => _selectedTags;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  void setTags(List<String> tags) {
    _selectedTags = tags;
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void removeImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<bool> createPost({
    required String title,
    required String content,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl;

      // 1. Upload image if exists
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      // 2. Call edge function to create post
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await SupabaseService.client.functions.invoke(
        'create-post',
        body: {
          'title': title,
          'content': content,
          'tags': _selectedTags,
          'image_url': imageUrl,
          'user_id': user.id,
        },
      );

      if (response.status == 200) {
        print('✅ Post created successfully');
        _selectedImage = null;
        _selectedTags = [];
        return true;
      } else {
        throw Exception('Failed to create post: ${response.data}');
      }
    } catch (e) {
      print('❌ Error creating post: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.id}_$timestamp.jpg';
      final filePath = 'posts/$fileName';

      await SupabaseService.client.storage
          .from('post-images')
          .upload(filePath, image);

      final imageUrl = SupabaseService.client.storage
          .from('post-images')
          .getPublicUrl(filePath);

      print('✅ Image uploaded: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      rethrow;
    }
  }
}