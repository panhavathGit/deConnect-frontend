// lib/features/auth/data/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/services/supabase_service.dart';

class AuthRepository {
  final _supabase = SupabaseService.client;

  Future<AuthResponse> login(String email, String password) async {
    try {
      print('🔐 Attempting login for: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email, 
        password: password
      );
      print('✅ Login successful: ${response.user?.email}');
      print('📝 User ID: ${response.user?.id}');
      print('📊 User metadata: ${response.user?.userMetadata}');
      return response;
    } catch (e) {
      print('❌ Login error: $e');
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
    try {
      print('📝 Registering user: $email');
      print('   Username: $username');
      print('   First Name: $firstName');
      print('   Last Name: $lastName');
      print('   Gender: $gender');
      
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
      
      print('✅ Registration successful!');
      return response;
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }
  
  Future<void> logout() async {
    print('🚪 Logging out...');
    await _supabase.auth.signOut();
    print('✅ Logout successful');
  }
  
  User? get currentUser {
    final user = _supabase.auth.currentUser;
    print('👤 Current user: ${user?.email ?? "No user logged in"}');
    return user;
  }
}