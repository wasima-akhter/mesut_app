import 'dart:developer' as developer;

abstract final class AppLogger {
  static void debug(String message, {String name = 'APP'}) {
    developer.log(message, name: name);
  }

  static void info(String message, {String name = 'APP'}) {
    developer.log(message, name: name);
  }

  static void warning(String message, {String name = 'APP'}) {
    developer.log(message, name: name, level: 900);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'APP',
  }) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
