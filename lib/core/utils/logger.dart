import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {

  // before final 
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // methodCount it for type of printing in each block (0-5)
      stackTraceBeginIndex: 1,  // skip the #x you don't want 
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      levelColors: {
        // ** ANSI Color Codes **
        // Green : 28
        // Red : 1, 9
        Level.info: AnsiColor.fg(28),  
      },
    ),
    // Only log if we are in debug mode
    level: kDebugMode ? Level.all : Level.off,
  );
  
  // i for infor
  static void i(String message) => _logger.i(message);
  // d for debug
  static void d(String message) => _logger.d(message);
  // w for warning
  static void w(String message) => _logger.w(message);
  // e for error
  static void e(String message, [dynamic error, StackTrace? stackTrace]) => 
      _logger.e(message, error: error, stackTrace: stackTrace);
}