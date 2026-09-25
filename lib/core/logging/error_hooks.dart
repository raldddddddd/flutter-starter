import 'package:flutter/foundation.dart';

import 'app_logger.dart';

void installErrorHooks(AppLogger logger) {
  FlutterError.onError = (details) {
    logger.error(
      'Uncaught Flutter framework error',
      error: details.exception,
      stackTrace: details.stack ?? StackTrace.current,
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error(
      'Uncaught platform error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };
}
