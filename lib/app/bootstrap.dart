import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';
import '../core/logging/app_provider_observer.dart';
import '../core/logging/error_hooks.dart';
import 'app_root.dart';

void bootstrap() {
  const logger = DeveloperLogger();
  installErrorHooks(logger);
  runApp(
    const ProviderScope(
      retry: _noProviderRetry,
      observers: [AppProviderObserver(logger)],
      child: AppRoot(),
    ),
  );
}

Duration? _noProviderRetry(int retryCount, Object error) => null;
