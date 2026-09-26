import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/app_config.dart';
import '../../../core/network/network_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.signInNotConfigured),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: l10n.openSampleDemo,
                  isLoading: action.isLoading,
                  onPressed: () => ref
                      .read(sampleDemoSessionActionProvider.notifier)
                      .start(),
                ),
                if (action.hasError) Text(l10n.sampleDemoError),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
