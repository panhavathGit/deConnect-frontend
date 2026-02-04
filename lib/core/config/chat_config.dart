// lib/core/config/chat_config.dart
class ChatConfig {
  // Attachment limits
  static const int maxImages = 100;
  static const int maxFiles = 20;
  static const int maxFileSizeMB = 150;
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;

  // Message constraints
  static const double maxMessageWidth = 0.75; // 75% of screen width

  // Animation durations
  static const Duration typingAnimationDuration = Duration(milliseconds: 200);
  static const Duration scrollAnimationDuration = Duration(milliseconds: 300);
}