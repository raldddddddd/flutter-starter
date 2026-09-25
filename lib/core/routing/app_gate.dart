import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../session/session_providers.dart';
import '../session/session_snapshot.dart';

part 'app_gate.g.dart';

enum AppGateState {
  bootstrapping,
  unauthenticated,
  authenticatedOffline,
  authenticatedOnline,
}

@Riverpod(keepAlive: true)
AppGateState appGate(Ref ref) {
  ref.watch(sessionRestorationProvider);
  final session = ref.watch(sessionStateProvider);
  return switch (session.value?.status) {
    SessionStatus.unauthenticated => AppGateState.unauthenticated,
    SessionStatus.authenticatedOffline => AppGateState.authenticatedOffline,
    SessionStatus.authenticatedOnline => AppGateState.authenticatedOnline,
    _ => AppGateState.bootstrapping,
  };
}
