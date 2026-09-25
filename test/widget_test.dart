import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app/app_root.dart';
import 'package:flutter_starter/app/app_config.dart';
import 'package:flutter_starter/app/developer_flags.dart';
import 'package:flutter_starter/core/routing/app_gate.dart';
import 'package:flutter_starter/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('launches through go_router', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AppRoot()));
    await tester.pumpAndSettle();

    expect(find.text('Flutter Starter'), findsOneWidget);
    const environment = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    expect(find.text('Environment: $environment'), findsOneWidget);
    if (kEnableComponentShowcase && environment != 'prod') {
      expect(find.text('Component Showcase'), findsOneWidget);
    } else {
      expect(find.text('Component Showcase'), findsNothing);
    }
  });

  testWidgets('gate sends bootstrapping state to bootstrap route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appGateProvider.overrideWith((ref) => AppGateState.bootstrapping),
        ],
        child: const AppRoot(),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('showcase route is registered only outside production', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final environment = container.read(appConfigProvider).environment;
    final routes = container.read(appRouterProvider).configuration.routes;
    final hasShowcase = routes.whereType<GoRoute>().any(
      (route) => route.path == '/showcase',
    );
    expect(
      hasShowcase,
      kEnableComponentShowcase && environment != AppEnvironment.prod,
    );
  });
}
