import 'dart:async';
import '../../../core/mock/mock_data.dart';

class MockAuthRepository {
  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Mock login - always succeeds with valid-looking credentials
  Future<Map<String, dynamic>> login(String email, String password) async {
    await _simulateDelay();
    
    // Simple validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }
    
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
    
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Return mock user data
    return {
      'user': {
        'id': MockData.currentUser.id,
        'email': MockData.currentUser.email,
        'user_metadata': {
          'username': MockData.currentUser.username,
        }
      },
      'session': {
        'access_token': 'mock_access_token_12345',
        'refresh_token': 'mock_refresh_token_67890',
      }
    };
  }

  // Mock register - always succeeds
  Future<Map<String, dynamic>> register(String email, String password, String username) async {
    await _simulateDelay();
    
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      throw Exception('All fields are required');
    }
    
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
    
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Return mock user data
    return {
      'user': {
        'id': MockData.currentUser.id,
        'email': email,
        'user_metadata': {
          'username': username,
        }
      },
      'session': {
        'access_token': 'mock_access_token_12345',
        'refresh_token': 'mock_refresh_token_67890',
      }
    };
  }

  // Mock logout
  Future<void> logout() async {
    await _simulateDelay();
    // Just simulate the delay, nothing else needed
  }

  // Get current user
  Map<String, dynamic>? get currentUser => {
    'id': MockData.currentUser.id,
    'email': MockData.currentUser.email,
    'user_metadata': {
      'username': MockData.currentUser.username,
    }
  };
}
