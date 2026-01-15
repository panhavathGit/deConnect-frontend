import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repo.login(email, password);
      // Navigation is handled in main.dart via Auth State changes, 
      // or you can return true here to let View handle navigation.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}