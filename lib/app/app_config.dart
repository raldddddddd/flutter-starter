import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.g.dart';

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  final AppEnvironment environment;
  final String apiBaseUrl;
}

const _configuredEnvironment = String.fromEnvironment('APP_ENV');
const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => resolveAppConfig(
  configuredEnvironment: _configuredEnvironment,
  configuredApiBaseUrl: _configuredApiBaseUrl,
  nativeFlavor: appFlavor,
  isRelease: kReleaseMode,
);

/// Validate public compile-time settings in every build mode.
AppConfig resolveAppConfig({
  required String configuredEnvironment,
  required String configuredApiBaseUrl,
  required String? nativeFlavor,
  required bool isRelease,
}) {
  if (isRelease && configuredEnvironment.isEmpty) {
    throw StateError('APP_ENV is required in release builds.');
  }
  final environment = AppEnvironment.values.byName(
    configuredEnvironment.isEmpty ? 'dev' : configuredEnvironment,
  );
  if (nativeFlavor != null && nativeFlavor != environment.name) {
    throw StateError('Native flavor and APP_ENV must match.');
  }
  final baseUrl = configuredApiBaseUrl.isNotEmpty
      ? configuredApiBaseUrl
      : 'https://${environment.name}-api.example.invalid';
  return AppConfig(environment: environment, apiBaseUrl: baseUrl);
}
