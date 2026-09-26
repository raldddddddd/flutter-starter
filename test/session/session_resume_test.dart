import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/app/app_root.dart';
import 'package:flutter_starter/core/errors/app_failure.dart';
import 'package:flutter_starter/core/network/network_providers.dart';
import 'package:flutter_starter/core/persistence/app_database.dart';
import 'package:flutter_starter/core/persistence/app_preferences.dart';
import 'package:flutter_starter/core/routing/app_gate.dart';
import 'package:flutter_starter/core/session/session_manager.dart';
import 'package:flutter_starter/core/session/session_providers.dart';
import 'package:flutter_starter/core/session/session_snapshot.dart';
import 'package:flutter_starter/core/session/token_refresh.dart';

import '../persistence/app_preferences_test.dart' show MemoryPreferences;
import 'session_manager_test.dart' show FixedRefresher, MemorySecureStorage;

class GatedRefresher implements TokenRefresher {
  final result = Completer<RefreshOutcome>();
  int calls = 0;

  @override
  Future<RefreshOutcome> refresh(String refreshToken) {
    calls++;
    return result.future;
  }
}

void main() {
  for (final rejected in [false, true]) {
    testWidgets('resume recovers offline session (rejected: $rejected)', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());
      final preferences = AppPreferences(MemoryPreferences());
      final secure = MemorySecureStorage();
      final session = SessionManager(secure, preferences, database);
      addTearDown(() async {
        await session.close();
        await database.close();
      });
      await session.establishSession(
        accountId: 'alice',
        accessToken: 'a',
        refreshToken: 'r',
      );
      await preferences.setUserString('filter', 'private');
      await database.markFetched('alice', 'feed', DateTime.utc(2026));
      await session.refreshAccessToken(
        FixedRefresher(const RefreshUnavailable(NetworkFailure())),
      );
      expect(session.snapshot.status, SessionStatus.authenticatedOffline);
      final refresher = GatedRefresher();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      void resume() {
        for (final state in [
          AppLifecycleState.inactive,
          AppLifecycleState.hidden,
          AppLifecycleState.paused,
          AppLifecycleState.hidden,
          AppLifecycleState.inactive,
          AppLifecycleState.resumed,
        ]) {
          tester.binding.handleAppLifecycleStateChanged(state);
        }
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionManagerProvider.overrideWith((ref) => session),
            tokenRefresherProvider.overrideWith((ref) => refresher),
            sessionRestorationProvider.overrideWith((ref) async {}),
          ],
          child: const AppRoot(),
        ),
      );
      await tester.pumpAndSettle();
      for (var index = 0; index < 2; index++) {
        resume();
        await tester.pump();
      }
      expect(refresher.calls, 1);
      refresher.result.complete(
        rejected ? const RefreshRejected() : const RefreshAccepted('recovered'),
      );
      await tester.pumpAndSettle();
      expect(
        session.snapshot.status,
        rejected
            ? SessionStatus.unauthenticated
            : SessionStatus.authenticatedOnline,
      );
      expect(
        ProviderScope.containerOf(tester.element(find.byType(AppRoot)))
            .read(appGateProvider),
        rejected
            ? AppGateState.unauthenticated
            : AppGateState.authenticatedOnline,
      );
      expect(session.accessToken, rejected ? isNull : 'recovered');
      expect(
        await preferences.getUserString('filter'),
        rejected ? isNull : 'private',
      );
      expect(
        await database.metadataFor('alice', 'feed'),
        rejected ? isNull : isNotNull,
      );
      // An online or signed-out session should not cause another resume refresh.
      resume();
      await tester.pump();
      expect(refresher.calls, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
