import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/app/app_config.dart';

void main() {
  for (final isRelease in [false, true]) {
    test(
      'flavor mismatch fails without an assertion (release: $isRelease)',
      () {
        expect(
          () => resolveAppConfig(
            configuredEnvironment: 'dev',
            configuredApiBaseUrl: '',
            nativeFlavor: 'prod',
            isRelease: isRelease,
          ),
          throwsStateError,
        );
      },
    );
  }

  test('release requires explicit APP_ENV even without a native flavor', () {
    for (final flavor in [null, 'dev', 'prod']) {
      expect(
        () => resolveAppConfig(
          configuredEnvironment: '',
          configuredApiBaseUrl: '',
          nativeFlavor: flavor,
          isRelease: true,
        ),
        throwsStateError,
      );
    }
  });

  test('matching release flavors keep their own config', () {
    for (final environment in AppEnvironment.values) {
      final config = resolveAppConfig(
        configuredEnvironment: environment.name,
        configuredApiBaseUrl: 'https://${environment.name}.example.invalid',
        nativeFlavor: environment.name,
        isRelease: true,
      );
      expect(config.environment, environment);
      expect(config.apiBaseUrl, 'https://${environment.name}.example.invalid');
    }
  });

  test('unconfigured local debug run retains the dev default', () {
    expect(
      resolveAppConfig(
        configuredEnvironment: '',
        configuredApiBaseUrl: '',
        nativeFlavor: 'dev',
        isRelease: false,
      ).environment,
      AppEnvironment.dev,
    );
  });
}
