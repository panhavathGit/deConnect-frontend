// lib/core/utils/text_parser.dart
import 'package:flutter/material.dart';

class TextParser {
  static final RegExp _urlRegex = RegExp(
    r'https?://[^\s<>"{}|\\^\[\]`]+',
    caseSensitive: false,
  );

  /// Parses text and returns RichText with clickable URLs
  static Widget buildRichText(
    String text, {
    required bool isMe,
    required bool isDark,
    required Color linkColor,
    required Function(String) onUrlTap,
    double fontSize = 15,
  }) {
    final matches = _urlRegex.allMatches(text);
    
    // if (matches.isEmpty) {
    //   return Text(
    //     text,
    //     style: TextStyle(
    //       color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
    //       fontSize: fontSize,
    //     ),
    //   );
    // }

    if (matches.isEmpty) {
      return SelectableText(
        text,
        style: TextStyle(
          color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
          fontSize: fontSize,
        ),
      );
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before URL
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(
            color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
            fontSize: fontSize,
          ),
        ));
      }

      // Add clickable URL
      final url = match.group(0)!;
      spans.add(WidgetSpan(
        child: GestureDetector(
          onTap: () => onUrlTap(url),
          child: Text(
            url,
            style: TextStyle(
              color: linkColor,
              fontSize: fontSize,
              decoration: TextDecoration.underline,
              decorationColor: linkColor,
            ),
          ),
        ),
      ));
      lastEnd = match.end;
    }

    // Add remaining text after last URL
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(
          color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
          fontSize: fontSize,
        ),
      ));
    }

    // return RichText(text: TextSpan(children: spans));
    return SelectableText.rich(
      TextSpan(children: spans),
      style: TextStyle(
        color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
        fontSize: fontSize,
      ),
    );
  }
}