import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_database.dart';
import 'app_preferences.dart';

part 'persistence_providers.g.dart';

@Riverpod(keepAlive: true)
AppPreferences appPreferences(Ref ref) =>
    AppPreferences(SharedPreferencesAsync());

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage();

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}
