import 'package:flutter_riverpod/misc.dart' show ProviderException;

import 'app_failure.dart';

/// Unwraps Riverpod dependency errors before mapping at a presentation edge.
AppFailure normalizeProviderError(Object error, {StackTrace? stackTrace}) {
  var unwrapped = error;
  var originalStackTrace = stackTrace;
  while (unwrapped is ProviderException) {
    originalStackTrace = unwrapped.stackTrace;
    unwrapped = unwrapped.exception;
  }
  if (unwrapped is AppFailure) return unwrapped;
  return UnknownFailure(cause: unwrapped, stackTrace: originalStackTrace);
}
