import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;

import '../errors/app_failure.dart';
import 'app_logger.dart';

/// Logs only originating unexpected provider failures, with their stack.
final class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver(this.logger);

  final AppLogger logger;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (error is ProviderException || error is AppFailure) return;
    logger.error(
      'Unexpected failure in provider ${context.provider.name ?? '(unnamed)'}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
