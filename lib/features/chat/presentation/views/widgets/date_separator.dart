// lib/features/chat/presentation/widgets/date_separator.dart
import 'package:flutter/material.dart';
import '../../../../../core/utils/date_formatter.dart';

class DateSeparator extends StatelessWidget {
  final DateTime dateTime;
  final bool isDark;

  const DateSeparator({
    super.key,
    required this.dateTime,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                DateFormatter.getDateLabel(dateTime),
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          ),
        ],
      ),
    );
  }
}