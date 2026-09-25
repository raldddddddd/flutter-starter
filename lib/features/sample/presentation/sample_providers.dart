import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/session/session_providers.dart';
import '../data/sample_data_providers.dart';
import '../sample_item.dart';

part 'sample_providers.g.dart';

@riverpod
Stream<List<SampleItem>> sampleItems(Ref ref) {
  final accountId = ref.watch(sessionStateProvider).value?.accountId;
  if (accountId == null) return Stream.value(const []);
  return ref.watch(sampleRepositoryProvider).watchItems(accountId);
}

@riverpod
Stream<DateTime?> sampleMetadata(Ref ref) {
  final accountId = ref.watch(sessionStateProvider).value?.accountId;
  if (accountId == null) return Stream.value(null);
  return ref
      .watch(sampleRepositoryProvider)
      .watchMetadata(accountId)
      .map((metadata) => metadata?.lastFetchedAt);
}

/// The screen watches this action for the entire refresh operation.
@riverpod
class SampleRefreshAction extends _$SampleRefreshAction {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<Result<void>> refreshIfStale() => _run(force: false);
  Future<Result<void>> forceRefresh() => _run(force: true);

  Future<Result<void>> _run({required bool force}) async {
    if (state.isLoading) return const Success<void>(null);
    state = const AsyncLoading<void>();
    final result = force
        ? await ref.read(sampleRepositoryProvider).forceRefresh()
        : await ref.read(sampleRepositoryProvider).refreshIfStale();
    if (!ref.mounted) return result;
    switch (result) {
      case Success<void>():
        state = const AsyncData<void>(null);
      case Failure<void>(:final failure):
        state = AsyncError<void>(
          failure,
          failure.stackTrace ?? StackTrace.current,
        );
    }
    return result;
  }
}

/// The write uses the same watched action-state convention as refresh.
@riverpod
class SampleSaveAction extends _$SampleSaveAction {
  @override
  AsyncValue<SampleItem?> build() => const AsyncData<SampleItem?>(null);

  Future<Result<SampleItem>> save(String title) async {
    if (state.isLoading) {
      return const Failure<SampleItem>(ValidationFailure());
    }
    state = const AsyncLoading<SampleItem?>();
    final result = await ref.read(sampleRepositoryProvider).createItem(title);
    if (!ref.mounted) return result;
    switch (result) {
      case Success<SampleItem>(:final value):
        state = AsyncData<SampleItem?>(value);
      case Failure<SampleItem>(:final failure):
        state = AsyncError<SampleItem?>(
          failure,
          failure.stackTrace ?? StackTrace.current,
        );
    }
    return result;
  }
}
