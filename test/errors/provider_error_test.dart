import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/errors/app_failure.dart';
import 'package:flutter_starter/core/errors/provider_error.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';
import 'package:flutter_starter/core/logging/app_provider_observer.dart';

class RecordedError {
  RecordedError(this.message, this.error, this.stackTrace);

  final String message;
  final Object error;
  final StackTrace stackTrace;
}

class RecordingLogger implements AppLogger {
  final errors = <RecordedError>[];

  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}

  @override
  void error(
    String message, {
    required Object error,
    required StackTrace stackTrace,
  }) => errors.add(RecordedError(message, error, stackTrace));
}

void main() {
  test('normalizes a failed provider dependency to its AppFailure', () {
    const expected = StorageFailure();
    final origin = Provider<int>((ref) => throw expected, name: 'origin');
    final dependent = Provider<int>(
      (ref) => ref.watch(origin),
      name: 'dependent',
    );
    final container = ProviderContainer(retry: (count, error) => null);
    addTearDown(container.dispose);

    Object? observed;
    try {
      container.read(dependent);
    } catch (error) {
      observed = error;
    }
    expect(observed, isNotNull);
    expect(normalizeProviderError(observed!), same(expected));
  });

  test('unknown dependency error preserves original cause and stack', () {
    final cause = StateError('broken');
    final origin = Provider<int>((ref) => throw cause, name: 'origin');
    final dependent = Provider<int>(
      (ref) => ref.watch(origin),
      name: 'dependent',
    );
    final container = ProviderContainer(retry: (count, error) => null);
    addTearDown(container.dispose);

    Object? observed;
    try {
      container.read(dependent);
    } catch (error) {
      observed = error;
    }
    final normalized = normalizeProviderError(observed!);
    expect(normalized, isA<UnknownFailure>());
    expect(normalized.cause, same(cause));
    expect(normalized.stackTrace, isNotNull);
  });

  test(
    'observer reports unexpected origin once and skips dependency wrapper',
    () {
      final logger = RecordingLogger();
      final cause = StateError('broken');
      final origin = Provider<int>((ref) => throw cause, name: 'origin');
      final dependent = Provider<int>(
        (ref) => ref.watch(origin),
        name: 'dependent',
      );
      final container = ProviderContainer(
        observers: [AppProviderObserver(logger)],
        retry: (count, error) => null,
      );
      addTearDown(container.dispose);

      try {
        container.read(dependent);
      } catch (_) {}
      expect(logger.errors, hasLength(1));
      expect(logger.errors.single.error, same(cause));
      expect(logger.errors.single.message, contains('origin'));
      expect(logger.errors.single.stackTrace, isA<StackTrace>());
    },
  );

  test('observer does not log expected operational failures', () {
    final logger = RecordingLogger();
    final origin = Provider<int>(
      (ref) => throw const NetworkFailure(),
      name: 'origin',
    );
    final container = ProviderContainer(
      observers: [AppProviderObserver(logger)],
      retry: (count, error) => null,
    );
    addTearDown(container.dispose);

    try {
      container.read(origin);
    } catch (_) {}
    expect(logger.errors, isEmpty);
  });

  test('observer logs UnknownFailure with its original cause and stack', () {
    final logger = RecordingLogger();
    final cause = StateError('unexpected');
    final stack = StackTrace.current;
    final origin = Provider<int>(
      (ref) => throw UnknownFailure(cause: cause, stackTrace: stack),
      name: 'origin',
    );
    final dependent = Provider<int>((ref) => ref.watch(origin));
    final container = ProviderContainer(
      observers: [AppProviderObserver(logger)],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    try {
      container.read(dependent);
    } catch (_) {}
    expect(logger.errors, hasLength(1));
    expect(logger.errors.single.error, same(cause));
    expect(logger.errors.single.stackTrace, same(stack));
  });
}
