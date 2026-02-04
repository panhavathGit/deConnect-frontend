// lib/features/chat/presentation/widgets/typing_indicator.dart
import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final bool isDark;
  final String message;

  const TypingIndicator({
    super.key,
    required this.isDark,
    this.message = 'typing...',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (index) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 600 + (index * 200)),
            builder: (context, value, child) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey[400] : Colors.grey)!
                    .withValues(alpha: 0.3 + (0.7 * value)),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}