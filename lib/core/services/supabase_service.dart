import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';

//Connect flutter to backend, behind the scenes: This is when Supabase sets up SharedPreferences for session storage
//Creates a single shared instance of the Supabase client, so we can use .client everywhere

class SupabaseService {
  // The Single Source of Truth
  static final client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }
}