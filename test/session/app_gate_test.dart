import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/routing/app_gate.dart';
import 'package:flutter_starter/core/session/session_providers.dart';
import 'package:flutter_starter/core/session/session_snapshot.dart';
import 'package:flutter_starter/core/version/version_policy.dart';

final class FixedVersionPolicy implements VersionPolicySource {
  const FixedVersionPolicy(this.status);

  final VersionPolicyStatus status;

  @override
  Future<VersionPolicyStatus> evaluate() async => status;
}

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
      await container.read(versionPolicyStatusProvider.future);
      expect(container.read(appGateProvider), expected);
    });
  }

  for (final (policy, expected) in [
    (VersionPolicyStatus.allowed, AppGateState.unauthenticated),
    (VersionPolicyStatus.updateRecommended, AppGateState.unauthenticated),
    (VersionPolicyStatus.updateRequired, AppGateState.updateRequired),
  ]) {
    test('version policy $policy produces $expected', () async {
      final container = ProviderContainer(
        overrides: [
          sessionRestorationProvider.overrideWith((ref) async {}),
          sessionStateProvider.overrideWith(
            (ref) => Stream.value(
              const SessionSnapshot(
                status: SessionStatus.unauthenticated,
                epoch: 1,
              ),
            ),
          ),
          versionPolicySourceProvider.overrideWith(
            (ref) => FixedVersionPolicy(policy),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(appGateProvider, (_, _) {});
      addTearDown(subscription.close);
      await container.read(versionPolicyStatusProvider.future);
      if (policy != VersionPolicyStatus.updateRequired) {
        await container.read(sessionStateProvider.future);
      }
      expect(container.read(appGateProvider), expected);
    });
  }
}
