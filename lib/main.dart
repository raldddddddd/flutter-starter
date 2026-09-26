import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/bootstrap.dart';
import 'core/persistence/app_preferences.dart';
import 'core/persistence/fresh_install_policy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final freshInstallPolicy = FreshInstallPolicy(
    AppPreferences(SharedPreferencesAsync()),
    const FlutterSecureStorage(),
  );
  await bootstrap(
    initializeInstallation: () async {
      await freshInstallPolicy.ensureInitialized();
    },
  );
}
