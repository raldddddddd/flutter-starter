import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_gate.g.dart';

// Phase 1 only: later phases derive this from version, onboarding and session.
enum AppGateState { bootstrapping, ready }

@Riverpod(keepAlive: true)
AppGateState appGate(Ref ref) => AppGateState.ready;
