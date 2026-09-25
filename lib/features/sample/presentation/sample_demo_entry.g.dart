// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_demo_entry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A dev-only local session so the in-process sample is usable without login.

@ProviderFor(SampleDemoSessionAction)
final sampleDemoSessionActionProvider = SampleDemoSessionActionProvider._();

/// A dev-only local session so the in-process sample is usable without login.
final class SampleDemoSessionActionProvider
    extends $NotifierProvider<SampleDemoSessionAction, AsyncValue<void>> {
  /// A dev-only local session so the in-process sample is usable without login.
  SampleDemoSessionActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sampleDemoSessionActionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sampleDemoSessionActionHash();

  @$internal
  @override
  SampleDemoSessionAction create() => SampleDemoSessionAction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$sampleDemoSessionActionHash() =>
    r'62469173ea614b4144295312de8283c2bf5d949d';

/// A dev-only local session so the in-process sample is usable without login.

abstract class _$SampleDemoSessionAction extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
