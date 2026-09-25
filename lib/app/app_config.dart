import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.g.dart';

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  const AppConfig({required this.environment});

  final AppEnvironment environment;
}

const _configuredEnvironment = String.fromEnvironment(
  'APP_ENV',
  defaultValue: 'dev',
);

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) {
  final environment = AppEnvironment.values.byName(_configuredEnvironment);
  assert(
    appFlavor == null || appFlavor == environment.name,
    'Native flavor and APP_ENV must match.',
  );
  return AppConfig(environment: environment);
}
