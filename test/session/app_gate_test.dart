import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/routing/app_gate.dart';
import 'package:flutter_starter/core/session/session_providers.dart';
import 'package:flutter_starter/core/session/session_snapshot.dart';

void main() {
  for (final (status, expected) in [
    (SessionStatus.restoring, AppGateState.bootstrapping),
    (SessionStatus.unauthenticated, AppGateState.unauthenticated),
    (SessionStatus.authenticatedOffline, AppGateState.authenticatedOffline),
    (SessionStatus.authenticatedOnline, AppGateState.authenticatedOnline),
  ]) {
    test('gate derives $expected from $status', () async {
      final container = ProviderContainer(
        overrides: [
          sessionRestorationProvider.overrideWith((ref) async {}),
          sessionStateProvider.overrideWith(
            (ref) => Stream.value(
              SessionSnapshot(
                status: status,
                epoch: 1,
                accountId:
                    status == SessionStatus.authenticatedOffline ||
                        status == SessionStatus.authenticatedOnline
                    ? 'alice'
                    : null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        appGateProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await container
          .read(sessionStateProvider.future)
          .timeout(const Duration(seconds: 2));
      expect(container.read(appGateProvider), expected);
    });
  }
}
