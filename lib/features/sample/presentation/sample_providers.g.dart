// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sampleItems)
final sampleItemsProvider = SampleItemsProvider._();

final class SampleItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SampleItem>>,
          List<SampleItem>,
          Stream<List<SampleItem>>
        >
    with $FutureModifier<List<SampleItem>>, $StreamProvider<List<SampleItem>> {
  SampleItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sampleItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sampleItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<SampleItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SampleItem>> create(Ref ref) {
    return sampleItems(ref);
  }
}

String _$sampleItemsHash() => r'6f33529bde215367e1ea99088c4fb4c800b5d834';

@ProviderFor(sampleMetadata)
final sampleMetadataProvider = SampleMetadataProvider._();

final class SampleMetadataProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime?>, DateTime?, Stream<DateTime?>>
    with $FutureModifier<DateTime?>, $StreamProvider<DateTime?> {
  SampleMetadataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sampleMetadataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sampleMetadataHash();

  @$internal
  @override
  $StreamProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime?> create(Ref ref) {
    return sampleMetadata(ref);
  }
}

String _$sampleMetadataHash() => r'322bf8d61a65dca83af1205600333010ac8f2e98';

/// The screen watches this action for the entire refresh operation.

@ProviderFor(SampleRefreshAction)
final sampleRefreshActionProvider = SampleRefreshActionProvider._();

/// The screen watches this action for the entire refresh operation.
final class SampleRefreshActionProvider
    extends $NotifierProvider<SampleRefreshAction, AsyncValue<void>> {
  /// The screen watches this action for the entire refresh operation.
  SampleRefreshActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sampleRefreshActionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sampleRefreshActionHash();

  @$internal
  @override
  SampleRefreshAction create() => SampleRefreshAction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$sampleRefreshActionHash() =>
    r'fa6edf12c844d3666b5ae4079f328109e99aa44d';

/// The screen watches this action for the entire refresh operation.

abstract class _$SampleRefreshAction extends $Notifier<AsyncValue<void>> {
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

/// The write uses the same watched action-state convention as refresh.

@ProviderFor(SampleSaveAction)
final sampleSaveActionProvider = SampleSaveActionProvider._();

/// The write uses the same watched action-state convention as refresh.
final class SampleSaveActionProvider
    extends $NotifierProvider<SampleSaveAction, AsyncValue<SampleItem?>> {
  /// The write uses the same watched action-state convention as refresh.
  SampleSaveActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sampleSaveActionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sampleSaveActionHash();

  @$internal
  @override
  SampleSaveAction create() => SampleSaveAction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SampleItem?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SampleItem?>>(value),
    );
  }
}

String _$sampleSaveActionHash() => r'177c58158ee38fbdc5525a950dd5aaa7c475679f';

/// The write uses the same watched action-state convention as refresh.

abstract class _$SampleSaveAction extends $Notifier<AsyncValue<SampleItem?>> {
  AsyncValue<SampleItem?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SampleItem?>, AsyncValue<SampleItem?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SampleItem?>, AsyncValue<SampleItem?>>,
              AsyncValue<SampleItem?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
