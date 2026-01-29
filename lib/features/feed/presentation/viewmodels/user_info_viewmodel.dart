// lib/features/feed/presentation/viewmodels/user_info_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../../core/services/supabase_service.dart';

class UserInfoViewModel extends ChangeNotifier {
  String _userName = 'User';
  String? _avatarUrl;
  String? _userId;
  bool _isLoading = true;

  String get userName => _userName;
  String? get avatarUrl => _avatarUrl;
  String? get userId => _userId;
  bool get isLoading => _isLoading;

  Future<void> loadUserInfo() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        _userId = user.id;
        
        // Get user profile from database
        final profile = await SupabaseService.client
            .from('profiles')
            .select('username, first_name, last_name, avatar_url')
            .eq('id', user.id)
            .single();

        _userName = profile['first_name'] ?? profile['username'] ?? 'User';
        _avatarUrl = profile['avatar_url'];
        
        print('✅ User info loaded: $_userName');
      }
    } catch (e) {
      print('❌ Error loading user info: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUserInfo() {
    _userName = 'User';
    _avatarUrl = null;
    _userId = null;
    _isLoading = false;
    notifyListeners();
  }
}