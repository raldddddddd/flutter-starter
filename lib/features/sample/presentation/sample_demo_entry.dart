import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/app_config.dart';
import '../../../core/network/network_providers.dart';
import '../../../shared/widgets/app_buttons.dart';

part 'sample_demo_entry.g.dart';

/// A dev-only local session so the in-process sample is usable without login.
@riverpod
class SampleDemoSessionAction extends _$SampleDemoSessionAction {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> start() async {
    if (state.isLoading) return;
    if (ref.read(appConfigProvider).environment != AppEnvironment.dev) return;
    state = const AsyncLoading<void>();
    try {
      await ref
          .read(sessionManagerProvider)
          .establishSession(
            accountId: 'sample-demo',
            accessToken: 'sample-demo-access',
            refreshToken: 'sample-demo-refresh',
          );
      if (ref.mounted) state = const AsyncData<void>(null);
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError<void>(error, stackTrace);
    }
  }
}

class SampleDemoEntry extends ConsumerWidget {
  const SampleDemoEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(sampleDemoSessionActionProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sign in is not configured yet.'),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Open sample demo',
              isLoading: action.isLoading,
              onPressed: () =>
                  ref.read(sampleDemoSessionActionProvider.notifier).start(),
            ),
            if (action.hasError) const Text('Unable to start the sample demo.'),
          ],
        ),
      ),
    );
  }
}
