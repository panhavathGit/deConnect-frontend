import 'package:flutter/material.dart';
import '../data/mock_auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final MockAuthRepository _repo = MockAuthRepository();
  bool _isLoading = false;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repo.login(email, password);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repo.register(email, password, username);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}