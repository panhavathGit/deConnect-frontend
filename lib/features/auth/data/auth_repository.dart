import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class AuthRepository {
  final _supabase = SupabaseService.client;

  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register(String email, String password, String username) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username}, // Triggers the DB function
    );
  }
  
  Future<void> logout() async => await _supabase.auth.signOut();
  
  User? get currentUser => _supabase.auth.currentUser;
}