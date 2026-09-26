import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_providers.dart';
import '../../../core/session/session_snapshot.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/presentation/failure_message_key.dart';
import '../../../shared/widgets/app_states.dart';
import 'sample_providers.dart';
import 'sample_view_state.dart';

class SampleScreen extends ConsumerStatefulWidget {
  const SampleScreen({super.key});

  @override
  ConsumerState<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends ConsumerState<SampleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(sampleRefreshActionProvider.notifier).refreshIfStale();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final refresh = ref.watch(sampleRefreshActionProvider);
    final save = ref.watch(sampleSaveActionProvider);
    final view = deriveSampleViewState(
      ref.watch(sampleItemsProvider),
      ref.watch(sampleMetadataProvider),
      refresh,
    );
    final offline =
        ref.watch(sessionStateProvider).value?.status ==
        SessionStatus.authenticatedOffline;

    ref.listen(sampleRefreshActionProvider, (previous, next) {
      if (previous?.isLoading == true && next is AsyncData<void>) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.sampleItemsUpToDate)));
      }
    });
    ref.listen(sampleSaveActionProvider, (previous, next) {
      if (previous?.isLoading == true &&
          next is AsyncData &&
          next.value != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.sampleItemAdded)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sampleItemsTitle),
        actions: [
          IconButton(
            tooltip: l10n.refreshSampleItems,
            onPressed: refresh.isLoading
                ? null
                : () => ref
                      .read(sampleRefreshActionProvider.notifier)
                      .forceRefresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: view is SampleContent || view is SampleEmpty
          ? FloatingActionButton.extended(
              onPressed: save.isLoading
                  ? null
                  : () => ref
                        .read(sampleSaveActionProvider.notifier)
                        .save(l10n.newSampleItem),
              icon: const Icon(Icons.add),
              label: Text(l10n.addSampleItem),
            )
          : null,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (offline)
              ListTile(
                leading: const Icon(Icons.cloud_off_outlined),
                title: Text(l10n.offlineSessionNotice),
              ),
            if (view
                case SampleContent(refreshFailure: _?) ||
                    SampleEmpty(refreshFailure: _?))
              ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(l10n.cachedRefreshError),
              ),
            Expanded(child: _body(view, ref)),
          ],
        ),
      ),
    );
  }

  Widget _body(SampleViewState view, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (view) {
      SampleInitialLoading() => LoadingState(label: l10n.loadingSampleItems),
      SampleInitialError(:final failure) => ErrorState(
        title: l10n.loadSampleItemsError,
        message: localizedFailureMessage(l10n, failure),
        onRetry: () =>
            ref.read(sampleRefreshActionProvider.notifier).forceRefresh(),
      ),
      SampleEmpty(:final refreshing) => Stack(
        children: [
          EmptyState(title: l10n.noSampleItems),
          if (refreshing) LinearProgressIndicator(semanticsLabel: l10n.loading),
        ],
      ),
      SampleContent(:final items, :final refreshing) => Column(
        children: [
          if (refreshing) LinearProgressIndicator(semanticsLabel: l10n.loading),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(l10n.sampleItemCount(items.length)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                key: ValueKey(items[index].id),
                title: Text(items[index].title),
              ),
            ),
          ),
        ],
      ),
    };
  }
}
