import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_root.dart';

void bootstrap() {
  runApp(const ProviderScope(retry: _noProviderRetry, child: AppRoot()));
}

Duration? _noProviderRetry(int retryCount, Object error) => null;
