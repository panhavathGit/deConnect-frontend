// lib/features/auth/data/repositories/auth_repository.dart
import 'package:onboarding_project/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/services/supabase_service.dart';

class AuthRepository {
  final _supabase = SupabaseService.client;

  Future<AuthResponse> login(String email, String password) async {
    try {
      AppLogger.i('Attempting login for: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email, 
        password: password
      );
      AppLogger.i('Login successful: ${response.user?.email}');
      AppLogger.d('User ID: ${response.user?.id}');
      AppLogger.d('User metadata: ${response.user?.userMetadata}');

      return response;
    } catch (e, stackTrace) {
      AppLogger.e('Login failed for $email', e, stackTrace);
      rethrow;
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
    String? firstName,
    String? lastName,
    String? gender,
  }) async {
    final startTime = DateTime.now();
    AppLogger.i('   Starting registration for: $email');
    AppLogger.d('   Username: $username');
    AppLogger.d('   First Name: $firstName');
    AppLogger.d('   Last Name: $lastName');
    AppLogger.d('   Gender: $gender');

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'gender': gender,
        },
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.i('Registration successful for: ${response.user?.email}');
      AppLogger.d('New user ID: ${response.user?.id}');
      AppLogger.d('Registration took: ${duration.inMilliseconds}ms');

      return response;
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      AppLogger.e('❌ Registration failed for $email after ${duration.inMilliseconds}ms', e, stackTrace);
      rethrow;
    }
  }
  
  Future<void> logout() async {
    final startTime = DateTime.now();
    final currentUserEmail = _supabase.auth.currentUser?.email ?? 'unknown user';
    AppLogger.i('Starting logout for: $currentUserEmail');

    try {
      await _supabase.auth.signOut();

      final duration = DateTime.now().difference(startTime);
      AppLogger.i('Logout successful for: $currentUserEmail');
      AppLogger.d('Logout operation took: ${duration.inMilliseconds}ms');
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      AppLogger.e('❌ Logout failed for $currentUserEmail after ${duration.inMilliseconds}ms', e, stackTrace);
      rethrow;
    }
  }
  
  User? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      AppLogger.d('👤 Current user: ${user.email} (ID: ${user.id})');
    } else {
      AppLogger.d('👤 No user currently logged in');
    }
    return user;
  }
}