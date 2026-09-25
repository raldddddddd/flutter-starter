import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/errors/app_failure.dart';
import 'package:flutter_starter/features/sample/presentation/sample_view_state.dart';
import 'package:flutter_starter/features/sample/sample_item.dart';

void main() {
  const rows = AsyncData<List<SampleItem>>([]);
  const neverFetched = AsyncData<DateTime?>(null);
  final fetched = AsyncData<DateTime?>(DateTime.utc(2026));
  const loading = AsyncLoading<void>();
  const failure = AuthenticationFailure();
  final failed = AsyncError<void>(failure, StackTrace.current);

  test('never fetched and refreshing means initial loading', () {
    expect(
      deriveSampleViewState(rows, neverFetched, loading),
      isA<SampleInitialLoading>(),
    );
  });
  test('never fetched and failed means initial error', () {
    expect(
      deriveSampleViewState(rows, neverFetched, failed),
      isA<SampleInitialError>(),
    );
  });
  test('fetched zero rows is empty', () {
    expect(
      deriveSampleViewState(rows, fetched, const AsyncData<void>(null)),
      isA<SampleEmpty>(),
    );
  });
  test('cached rows remain visible during refresh and after failure', () {
    const cached = AsyncData<List<SampleItem>>([
      SampleItem(id: 'one', title: 'One'),
    ]);
    final refreshing = deriveSampleViewState(cached, fetched, loading);
    expect(refreshing, isA<SampleContent>());
    expect((refreshing as SampleContent).refreshing, isTrue);
    final withError = deriveSampleViewState(cached, fetched, failed);
    expect(withError, isA<SampleContent>());
    expect((withError as SampleContent).items.single.id, 'one');
    expect(withError.refreshFailure, same(failure));
  });
}
