import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../session/session_providers.dart';
import '../session/session_snapshot.dart';
import '../version/version_policy.dart';

part 'app_gate.g.dart';

enum AppGateState {
  bootstrapping,
  updateRequired,
  unauthenticated,
  authenticatedOffline,
  authenticatedOnline,
}

@Riverpod(keepAlive: true)
AppGateState appGate(Ref ref) {
  ref.watch(sessionRestorationProvider);
  final version = ref.watch(versionPolicyStatusProvider);
  if (version.isLoading || version.hasError) return AppGateState.bootstrapping;
  if (version.value == VersionPolicyStatus.updateRequired) {
    return AppGateState.updateRequired;
  }
  final session = ref.watch(sessionStateProvider);
  return switch (session.value?.status) {
    SessionStatus.unauthenticated => AppGateState.unauthenticated,
    SessionStatus.authenticatedOffline => AppGateState.authenticatedOffline,
    SessionStatus.authenticatedOnline => AppGateState.authenticatedOnline,
    _ => AppGateState.bootstrapping,
  };
}
