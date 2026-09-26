import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/logging/error_hooks.dart';

import 'provider_error_test.dart' show RecordingLogger;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'debug hooks preserve framework presentation and log original errors',
    () {
      final previousHook = FlutterError.onError;
      final previousPresent = FlutterError.presentError;
      final previousPlatformHook = PlatformDispatcher.instance.onError;
      addTearDown(() {
        FlutterError.onError = previousHook;
        FlutterError.presentError = previousPresent;
        PlatformDispatcher.instance.onError = previousPlatformHook;
      });
      final logger = RecordingLogger();
      FlutterErrorDetails? presented;
      FlutterError.presentError = (details) => presented = details;
      installErrorHooks(logger);
      final error = StateError('framework failure');
      final stack = StackTrace.current;
      final details = FlutterErrorDetails(exception: error, stack: stack);
      FlutterError.reportError(details);
      expect(presented, same(details));
      expect(logger.errors.single.error, same(error));
      expect(logger.errors.single.stackTrace, same(stack));
      expect(PlatformDispatcher.instance.onError!(error, stack), isTrue);
      expect(logger.errors, hasLength(2));
    },
  );
}
