import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.g.dart';

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  final AppEnvironment environment;
  final String apiBaseUrl;
}

const _configuredEnvironment = String.fromEnvironment(
  'APP_ENV',
  defaultValue: 'dev',
);
const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) {
  final environment = AppEnvironment.values.byName(_configuredEnvironment);
  assert(
    appFlavor == null || appFlavor == environment.name,
    'Native flavor and APP_ENV must match.',
  );
  final baseUrl = _configuredApiBaseUrl.isNotEmpty
      ? _configuredApiBaseUrl
      : 'https://${environment.name}-api.example.invalid';
  return AppConfig(environment: environment, apiBaseUrl: baseUrl);
}
