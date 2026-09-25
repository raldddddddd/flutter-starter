// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sampleApiService)
final sampleApiServiceProvider = SampleApiServiceProvider._();

final class SampleApiServiceProvider
    extends
        $FunctionalProvider<
          SampleApiService,
          SampleApiService,
          SampleApiService
        >
    with $Provider<SampleApiService> {
  SampleApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sampleApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sampleApiServiceHash();

  @$internal
  @override
  $ProviderElement<SampleApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SampleApiService create(Ref ref) {
    return sampleApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SampleApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SampleApiService>(value),
    );
  }
}

String _$sampleApiServiceHash() => r'dcfebfc9b0a616f8ebbea10b52a1599a40a224ca';

@ProviderFor(sampleRepository)
final sampleRepositoryProvider = SampleRepositoryProvider._();

final class SampleRepositoryProvider
    extends
        $FunctionalProvider<
          SampleRepository,
          SampleRepository,
          SampleRepository
        >
    with $Provider<SampleRepository> {
  SampleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sampleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sampleRepositoryHash();

  @$internal
  @override
  $ProviderElement<SampleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SampleRepository create(Ref ref) {
    return sampleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SampleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SampleRepository>(value),
    );
  }
}

String _$sampleRepositoryHash() => r'3b3e7442725a8308b230462882d42e89552fba2f';
