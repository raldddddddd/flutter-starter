import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/persistence/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryPreferences extends Fake implements SharedPreferencesAsync {
  final values = <String, Object>{};

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) async =>
      values.keys.toSet().intersection(allowList ?? values.keys.toSet());

  @override
  Future<void> clear({Set<String>? allowList}) async {
    for (final key in allowList ?? values.keys.toSet()) {
      values.remove(key);
    }
  }
}

void main() {
  test('separates device and user keys and clears only user values', () async {
    final store = MemoryPreferences();
    final preferences = AppPreferences(store);
    await preferences.setDeviceString('theme', 'dark');
    await preferences.setUserString('theme', 'light');
    await preferences.markInstalled();

    expect(
      store.values.keys,
      containsAll(['device.theme', 'user.theme', 'device.installationMarker']),
    );
    expect(await preferences.getDeviceString('theme'), 'dark');
    expect(await preferences.getUserString('theme'), 'light');

    await preferences.clearUser();
    expect(await preferences.getUserString('theme'), isNull);
    expect(await preferences.getDeviceString('theme'), 'dark');
    expect(await preferences.hasInstallationMarker, isTrue);
  });
}
