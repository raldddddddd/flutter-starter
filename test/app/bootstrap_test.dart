import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/app/bootstrap.dart';
import 'package:flutter_starter/core/persistence/app_preferences.dart';
import 'package:flutter_starter/core/persistence/fresh_install_policy.dart';

import '../errors/provider_error_test.dart' show RecordingLogger;
import '../persistence/app_preferences_test.dart' show MemoryPreferences;
import '../persistence/fresh_install_policy_test.dart'
    show RecordingSecureStorage;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'startup installs hooks, logs cleanup failure, and still starts UI',
    () async {
      final previousFlutterHook = FlutterError.onError;
      final previousPlatformHook = PlatformDispatcher.instance.onError;
      addTearDown(() {
        FlutterError.onError = previousFlutterHook;
        PlatformDispatcher.instance.onError = previousPlatformHook;
      });
      final preferences = AppPreferences(MemoryPreferences());
      final storage = RecordingSecureStorage()..failClear = true;
      final policy = FreshInstallPolicy(preferences, storage);
      final logger = RecordingLogger();
      var started = false;
      await bootstrap(
        logger: logger,
        initializeInstallation: () async {
          expect(FlutterError.onError, isNot(same(previousFlutterHook)));
          expect(PlatformDispatcher.instance.onError, isNotNull);
          await policy.ensureInitialized();
        },
        runApplication: () => started = true,
      );
      expect(started, isTrue);
      expect(logger.errors, hasLength(1));
      expect(logger.errors.single.error, isA<StateError>());
      expect(logger.errors.single.stackTrace, isA<StackTrace>());
      expect(await preferences.hasInstallationMarker, isFalse);
      storage.failClear = false;
      expect(await policy.ensureInitialized(), isTrue);
    },
  );
}
