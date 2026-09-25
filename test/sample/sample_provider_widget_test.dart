import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/persistence/app_database.dart'
    show AppDatabase;
import 'package:flutter_starter/core/persistence/app_preferences.dart';
import 'package:flutter_starter/core/persistence/persistence_providers.dart';
import 'package:flutter_starter/core/network/network_providers.dart';
import 'package:flutter_starter/core/design/app_theme.dart';
import 'package:flutter_starter/core/session/session_manager.dart';
import 'package:flutter_starter/features/sample/data/fake_sample_api_service.dart';
import 'package:flutter_starter/features/sample/data/sample_data_providers.dart';
import 'package:flutter_starter/features/sample/presentation/sample_providers.dart';
import 'package:flutter_starter/features/sample/presentation/sample_screen.dart';
import 'package:flutter_starter/features/sample/sample_item.dart';

import '../persistence/app_preferences_test.dart' show MemoryPreferences;
import '../session/session_manager_test.dart' show MemorySecureStorage;

void main() {
  late AppDatabase database;
  late SessionManager session;
  late FakeSampleApiService api;
  late ProviderContainer container;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    session = SessionManager(
      MemorySecureStorage(),
      AppPreferences(MemoryPreferences()),
      database,
    );
    await session.establishSession(
      accountId: 'alice',
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    api = FakeSampleApiService(latency: Duration.zero);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => database),
        sessionManagerProvider.overrideWith((ref) => session),
        sampleApiServiceProvider.overrideWith((ref) => api),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await session.close();
    await database.close();
  });

  test(
    'Riverpod stream observes cache and watched actions report completion',
    () async {
      final rows = container.listen(sampleItemsProvider, (_, _) {});
      final refresh = container.listen(sampleRefreshActionProvider, (_, _) {});
      await container.read(sampleItemsProvider.future);
      expect(rows.read().value, isEmpty);
      await container.read(sampleRefreshActionProvider.notifier).forceRefresh();
      await Future<void>.delayed(Duration.zero);
      expect(rows.read().value?.length, 2);
      expect(refresh.read(), isA<AsyncData<void>>());
      final save = container.listen(sampleSaveActionProvider, (_, _) {});
      await container.read(sampleSaveActionProvider.notifier).save('Third');
      await Future<void>.delayed(Duration.zero);
      expect(rows.read().value?.last.title, 'Third');
      expect(save.read().value?.title, 'Third');
      rows.close();
      refresh.close();
      save.close();
    },
  );

  testWidgets('screen explicitly refreshes then keeps cached data on failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const SampleScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.requestCount, 1);
    expect(find.text('First sample item'), findsOneWidget);
    api.outcome = FakeSampleOutcome.networkFailure;
    await tester.tap(find.byTooltip('Refresh sample items'));
    await tester.pumpAndSettle();
    expect(find.text('First sample item'), findsOneWidget);
    expect(find.text('Refresh failed. Showing cached items.'), findsOneWidget);
  });

  testWidgets(
    'screen distinguishes a successful empty list from initial load',
    (tester) async {
      api.items = const <SampleItem>[];
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light, home: const SampleScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No sample items yet'), findsOneWidget);
    },
  );
}
