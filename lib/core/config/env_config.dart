// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// enum Environment {
//   dev,
//   staging,
//   prod,
// }

// class EnvConfig {
//   static Environment _environment = Environment.dev;
//   static Environment get environment => _environment;
//   static void setEnvironment(Environment env) {
//     _environment = env;
//   }
  
//   static String get supabaseUrl {
//     if (kIsWeb) {
//       return 'http://127.0.0.1:54321';
//     }
//     if (Platform.isAndroid) {
//       return 'http://10.0.2.2:54321';
//     }
//     // iOS simulator, macOS, etc.
//     return 'http://127.0.0.1:54321';
//   }

//   static String get supabaseAnonKey =>
//       'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';


//   static bool get isDev => _environment == Environment.dev;
//   static bool get isStaging => _environment == Environment.staging;
//   static bool get isProd => _environment == Environment.prod;
  
//   // Environment variables
//   // static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
//   // static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
//   // Environment name for display/logging
//   static String get environmentName {
//     switch (_environment) {
//       case Environment.dev:
//         return 'Development';
//       case Environment.staging:
//         return 'Staging';
//       case Environment.prod:
//         return 'Production';
//     }
//   }
// }




// lib/core/config/env_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment {
  dev,
  staging,
  prod,
}

class EnvConfig {
  static Environment _environment = Environment.dev;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static bool get isDev => _environment == Environment.dev;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProd => _environment == Environment.prod;

  /// Base URL from .env (host side)
  static String _rawSupabaseUrl() {
    final envUrl = dotenv.env['SUPABASE_URL'];
    if (envUrl == null || envUrl.isEmpty) {
      // Fallback if .env is missing
      return 'http://127.0.0.1:54321';
    }
    return envUrl;
  }

  /// Platform-aware Supabase URL
  static String get supabaseUrl {
    final base = _rawSupabaseUrl();

    // Web runs in browser, can talk to 127.0.0.1 of your Mac
    if (kIsWeb) {
      return base.replaceAll('10.0.2.2', '127.0.0.1');
    }

    // Non-web (mobile / desktop)
    if (Platform.isAndroid) {
      // Android emulator: 10.0.2.2 points to host 127.0.0.1
      return base.replaceAll('127.0.0.1', '10.0.2.2');
    }

    // iOS simulator, macOS, etc. can use 127.0.0.1 directly
    return base.replaceAll('10.0.2.2', '127.0.0.1');
  }

  /// Supabase anon key from .env (with fallback)
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH';

  static String get environmentName {
    switch (_environment) {
      case Environment.dev:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.prod:
        return 'Production';
    }
  }
}
