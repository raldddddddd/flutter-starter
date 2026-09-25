import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app/app_root.dart';
import 'package:flutter_starter/core/routing/app_gate.dart';

void main() {
  testWidgets('launches through go_router', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AppRoot()));
    await tester.pumpAndSettle();

    expect(find.text('Flutter Starter'), findsOneWidget);
    expect(find.text('Environment: dev'), findsOneWidget);
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
}
