import 'package:shared_preferences/shared_preferences.dart';

/// Small, non-sensitive values. User keys are cleared when the session ends.
class AppPreferences {
  AppPreferences(this._store);

  final SharedPreferencesAsync _store;

  static const _devicePrefix = 'device.';
  static const _userPrefix = 'user.';
  static const _installationMarker = 'device.installationMarker';

  Future<String?> getDeviceString(String key) =>
      _store.getString('$_devicePrefix$key');

  Future<void> setDeviceString(String key, String value) =>
      _store.setString('$_devicePrefix$key', value);

  Future<String?> getUserString(String key) =>
      _store.getString('$_userPrefix$key');

  Future<void> setUserString(String key, String value) =>
      _store.setString('$_userPrefix$key', value);

  Future<bool> get hasInstallationMarker async =>
      await _store.getBool(_installationMarker) == true;

  Future<void> markInstalled() => _store.setBool(_installationMarker, true);

  Future<void> clearUser() async {
    final userKeys = (await _store.getKeys())
        .where((key) => key.startsWith(_userPrefix))
        .toSet();
    if (userKeys.isNotEmpty) {
      await _store.clear(allowList: userKeys);
    }
  }
}
