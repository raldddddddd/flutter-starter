import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';
import '../core/logging/app_provider_observer.dart';
import '../core/logging/error_hooks.dart';
import 'app_root.dart';

Future<void> bootstrap({
  required Future<void> Function() initializeInstallation,
  AppLogger logger = const DeveloperLogger(),
  VoidCallback? runApplication,
}) async {
  installErrorHooks(logger);
  try {
    await initializeInstallation();
  } catch (error, stackTrace) {
    logger.error(
      'Fresh-install cleanup failed; it will be retried next launch',
      error: error,
      stackTrace: stackTrace,
    );
  }
  if (runApplication != null) {
    runApplication();
    return;
  }
  runApp(
    ProviderScope(
      retry: _noProviderRetry,
      observers: [AppProviderObserver(logger)],
      child: const AppRoot(),
    ),
  );
}

Duration? _noProviderRetry(int retryCount, Object error) => null;
