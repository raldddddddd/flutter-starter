// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionState)
final sessionStateProvider = SessionStateProvider._();

final class SessionStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionSnapshot>,
          SessionSnapshot,
          Stream<SessionSnapshot>
        >
    with $FutureModifier<SessionSnapshot>, $StreamProvider<SessionSnapshot> {
  SessionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionStateHash();

  @$internal
  @override
  $StreamProviderElement<SessionSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SessionSnapshot> create(Ref ref) {
    return sessionState(ref);
  }
}

String _$sessionStateHash() => r'088665324ad53af473cdf85b5bb92273f56885df';

@ProviderFor(sessionRestoration)
final sessionRestorationProvider = SessionRestorationProvider._();

final class SessionRestorationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  SessionRestorationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionRestorationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionRestorationHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return sessionRestoration(ref);
  }
}

String _$sessionRestorationHash() =>
    r'81ccaf7b488480bdabf3b728698685394d33e4b9';
