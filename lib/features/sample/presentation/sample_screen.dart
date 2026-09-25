import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_providers.dart';
import '../../../core/session/session_snapshot.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample items are up to date.')),
        );
      }
    });
    ref.listen(sampleSaveActionProvider, (previous, next) {
      if (previous?.isLoading == true &&
          next is AsyncData &&
          next.value != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Sample item added.')));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample items'),
        actions: [
          IconButton(
            tooltip: 'Refresh sample items',
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
                        .save('New sample item'),
              icon: const Icon(Icons.add),
              label: const Text('Add sample item'),
            )
          : null,
      body: Column(
        children: [
          if (offline)
            const ListTile(
              leading: Icon(Icons.cloud_off_outlined),
              title: Text('Offline session: showing local data'),
            ),
          if (view
              case SampleContent(refreshFailure: _?) ||
                  SampleEmpty(refreshFailure: _?))
            const ListTile(
              leading: Icon(Icons.error_outline),
              title: Text('Refresh failed. Showing cached items.'),
            ),
          Expanded(child: _body(view, ref)),
        ],
      ),
    );
  }

  Widget _body(SampleViewState view, WidgetRef ref) => switch (view) {
    SampleInitialLoading() => const LoadingState(label: 'Loading sample items'),
    SampleInitialError() => ErrorState(
      title: 'Unable to load sample items',
      message: 'Try refreshing again.',
      onRetry: () =>
          ref.read(sampleRefreshActionProvider.notifier).forceRefresh(),
    ),
    SampleEmpty(:final refreshing) => Stack(
      children: [
        const EmptyState(title: 'No sample items yet'),
        if (refreshing) const LinearProgressIndicator(),
      ],
    ),
    SampleContent(:final items, :final refreshing) => Column(
      children: [
        if (refreshing) const LinearProgressIndicator(),
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
