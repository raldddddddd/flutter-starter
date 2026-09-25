import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../sample_item.dart';

sealed class SampleViewState {
  const SampleViewState();
}

final class SampleInitialLoading extends SampleViewState {
  const SampleInitialLoading();
}

final class SampleInitialError extends SampleViewState {
  const SampleInitialError(this.failure);

  final AppFailure failure;
}

final class SampleEmpty extends SampleViewState {
  const SampleEmpty({required this.refreshing, this.refreshFailure});

  final bool refreshing;
  final AppFailure? refreshFailure;
}

final class SampleContent extends SampleViewState {
  const SampleContent(
    this.items, {
    required this.refreshing,
    this.refreshFailure,
  });

  final List<SampleItem> items;
  final bool refreshing;
  final AppFailure? refreshFailure;
}

SampleViewState deriveSampleViewState(
  AsyncValue<List<SampleItem>> rows,
  AsyncValue<DateTime?> metadata,
  AsyncValue<void> refresh,
) {
  if (rows.hasError) {
    return SampleInitialError(_asStorageFailure(rows.error!));
  }
  if (metadata.hasError) {
    return SampleInitialError(_asStorageFailure(metadata.error!));
  }
  if (!rows.hasValue || !metadata.hasValue) {
    return const SampleInitialLoading();
  }
  final refreshFailure = switch (refresh.error) {
    AppFailure failure => failure,
    _ => null,
  };
  if (metadata.value == null) {
    return refreshFailure == null
        ? const SampleInitialLoading()
        : SampleInitialError(refreshFailure);
  }
  final items = rows.value!;
  if (items.isEmpty) {
    return SampleEmpty(
      refreshing: refresh.isLoading,
      refreshFailure: refreshFailure,
    );
  }
  return SampleContent(
    items,
    refreshing: refresh.isLoading,
    refreshFailure: refreshFailure,
  );
}

AppFailure _asStorageFailure(Object error) =>
    error is AppFailure ? error : StorageFailure(cause: error);
