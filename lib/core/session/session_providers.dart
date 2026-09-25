import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/network_providers.dart';
import 'session_snapshot.dart';

part 'session_providers.g.dart';

@Riverpod(keepAlive: true)
Stream<SessionSnapshot> sessionState(Ref ref) =>
    ref.watch(sessionManagerProvider).changes;

@Riverpod(keepAlive: true)
Future<void> sessionRestoration(Ref ref) => ref
    .watch(sessionManagerProvider)
    .restore(ref.watch(tokenRefresherProvider));
