import 'package:logger/logger.dart';

class Log {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: false,
      excludeBox: {
        Level.debug: true,
        Level.info: true,
        Level.warning: true,
        Level.error: true,
      },
    ),
    level: Level.debug,
  );

  static void d(String message) {
    _logger.d("[${DateTime.now()}] [DEBUG] $message");
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(
      "[${DateTime.now()}] [ERROR] $message",
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void w(String message) {
    _logger.w("[${DateTime.now()}] [WARNING] $message");
  }

  static void i(String message) {
    _logger.i("[${DateTime.now()}] [INFO] $message");
  }
}

