import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/persistence/app_preferences.dart';
import 'package:flutter_starter/core/persistence/fresh_install_policy.dart';

import 'app_preferences_test.dart' show MemoryPreferences;

class RecordingSecureStorage extends Fake implements FlutterSecureStorage {
  int clearCount = 0;
  bool failClear = false;

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    clearCount++;
    if (failClear) throw StateError('secure storage unavailable');
  }
}

void main() {
  test(
    'fresh install clears stale session material once before marking',
    () async {
      final preferences = AppPreferences(MemoryPreferences());
      final secureStorage = RecordingSecureStorage();
      final policy = FreshInstallPolicy(preferences, secureStorage);

      expect(await policy.ensureInitialized(), isTrue);
      expect(secureStorage.clearCount, 1);
      expect(await preferences.hasInstallationMarker, isTrue);
      expect(await policy.ensureInitialized(), isFalse);
      expect(secureStorage.clearCount, 1);
    },
  );

  test('does not mark install complete if secure cleanup fails', () async {
    final preferences = AppPreferences(MemoryPreferences());
    final secureStorage = RecordingSecureStorage()..failClear = true;
    final policy = FreshInstallPolicy(preferences, secureStorage);

    await expectLater(policy.ensureInitialized(), throwsStateError);
    expect(await preferences.hasInstallationMarker, isFalse);
  });
}
