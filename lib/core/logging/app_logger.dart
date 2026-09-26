import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Logging boundary; a product can replace this with a redacting crash hook.
abstract interface class AppLogger {
  void debug(String message);
  void info(String message);
  void warning(String message);
  void error(
    String message, {
    required Object error,
    required StackTrace stackTrace,
  });
}

final class DeveloperLogger implements AppLogger {
  const DeveloperLogger();

  @override
  void debug(String message) =>
      developer.log(message, name: 'flutter_starter', level: 500);

  @override
  void info(String message) =>
      developer.log(message, name: 'flutter_starter', level: 800);

  @override
  void warning(String message) =>
      developer.log(message, name: 'flutter_starter', level: 900);

  @override
  void error(
    String message, {
    required Object error,
    required StackTrace stackTrace,
  }) => developer.log(
    message,
    name: 'flutter_starter',
    level: 1000,
    error: kDebugMode ? error : null,
    // Outside debug, arbitrary exception text may contain credentials or bodies.
    // A product crash hook can inspect and redact [error] before forwarding.
    stackTrace: stackTrace,
  );
}
