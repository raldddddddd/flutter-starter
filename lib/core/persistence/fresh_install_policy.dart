import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_preferences.dart';

/// Runs before session restoration. This secure store is reserved for session
/// material; a missing installation marker means it must start empty.
class FreshInstallPolicy {
  FreshInstallPolicy(this._preferences, this._secureStorage);

  final AppPreferences _preferences;
  final FlutterSecureStorage _secureStorage;

  /// Returns whether this launch established a new installation.
  Future<bool> ensureInitialized() async {
    if (await _preferences.hasInstallationMarker) return false;
    await _secureStorage.deleteAll();
    await _preferences.markInstalled();
    return true;
  }
}
