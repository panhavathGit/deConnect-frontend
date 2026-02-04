// lib/core/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  /// Returns a human-readable date label (Today, Yesterday, weekday, or date)
  static String getDateLabel(DateTime dateTime) {
    final now = DateTime.now();
    final localDate = dateTime.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(localDate.year, localDate.month, localDate.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return DateFormat('EEEE').format(localDate);
    } else if (localDate.year == now.year) {
      return DateFormat('d MMMM').format(localDate);
    } else {
      return DateFormat('d MMMM yyyy').format(localDate);
    }
  }

  /// Formats time as HH:mm
  static String formatTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  /// Checks if a date separator should be shown between two messages
  static bool shouldShowDateSeparator(DateTime current, DateTime previous) {
    final currentDate = current.toLocal();
    final previousDate = previous.toLocal();

    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }
}